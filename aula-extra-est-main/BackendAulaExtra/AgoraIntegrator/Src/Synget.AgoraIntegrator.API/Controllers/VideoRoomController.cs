using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator.API.Data.Repositories;
using Synget.AgoraIntegrator.API.DTOs;
using Synget.AgoraIntegrator;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for managing video rooms with role-based access control.
/// - Only professors and admins can CREATE rooms
/// - Students can only JOIN rooms where the professor has already entered
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class VideoRoomController : ControllerBase
{
    private readonly IVideoRoomRepository _videoRoomRepository;
    private readonly IUserRepository _userRepository;
    private readonly ISessionRepository _sessionRepository;
    private readonly IAgora _agora;
    private readonly ILogger<VideoRoomController> _logger;

    public VideoRoomController(
        IVideoRoomRepository videoRoomRepository,
        IUserRepository userRepository,
        ISessionRepository sessionRepository,
        IAgora agora,
        ILogger<VideoRoomController> logger)
    {
        _videoRoomRepository = videoRoomRepository;
        _userRepository = userRepository;
        _sessionRepository = sessionRepository;
        _agora = agora;
        _logger = logger;
    }

    /// <summary>
    /// Create a new video room (professor or admin only).
    /// This only creates the room in the database - the professor must then "enter" to allow students.
    /// </summary>
    [HttpPost("create")]
    [ProducesResponseType(typeof(JoinVideoRoomResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(JoinVideoRoomResponse), StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<JoinVideoRoomResponse>> CreateRoom([FromBody] CreateVideoRoomRequest request)
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Unauthorized(new JoinVideoRoomResponse
            {
                Success = false,
                Error = "Authentication required."
            });
        }

        // Only professors and admins can create rooms
        if (user.Role != "admin" && user.Role != "professor")
        {
            _logger.LogWarning("User {Username} with role {Role} attempted to create video room", 
                user.Username, user.Role);

            return StatusCode(403, new JoinVideoRoomResponse
            {
                Success = false,
                Error = "Only professors and administrators can start video calls."
            });
        }

        // Generate channel name if not provided
        var channelName = request.ChannelName;
        if (string.IsNullOrWhiteSpace(channelName))
        {
            channelName = $"room_{DateTime.UtcNow:yyyyMMdd}_{Guid.NewGuid():N}".Substring(0, 32);
        }

        // Check if channel already exists and is active
        var existingRoom = await _videoRoomRepository.GetByChannelNameAsync(channelName);
        if (existingRoom != null && existingRoom.IsActive)
        {
            return BadRequest(new JoinVideoRoomResponse
            {
                Success = false,
                Error = "A room with this channel name already exists and is active."
            });
        }

        // Create the room in database (but professor hasn't entered yet)
        var room = await _videoRoomRepository.CreateAsync(
            channelName,
            user.Id,
            user.Username,
            request.Title,
            request.MaxParticipants
        );

        _logger.LogInformation("User {Username} created video room {ChannelName} (waiting for host to enter)", 
            user.Username, channelName);

        return Ok(new JoinVideoRoomResponse
        {
            Success = true,
            Room = MapToResponse(room),
            RtcToken = null, // Token given when actually entering
            Uid = user.Id.ToString()
        });
    }

    /// <summary>
    /// Professor/Admin enters the room they created.
    /// This sets host_joined = true and generates the RTC token.
    /// Students can only join after this.
    /// </summary>
    [HttpPost("enter")]
    [ProducesResponseType(typeof(JoinVideoRoomResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(JoinVideoRoomResponse), StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<JoinVideoRoomResponse>> EnterRoom([FromBody] JoinVideoRoomRequest request)
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Unauthorized(new JoinVideoRoomResponse
            {
                Success = false,
                Error = "Authentication required."
            });
        }

        // Find the room
        var room = await _videoRoomRepository.GetByChannelNameAsync(request.ChannelName);
        
        if (room == null || !room.IsActive)
        {
            // If room doesn't exist and user is professor/admin, create it on the fly
            if (user.Role == "admin" || user.Role == "professor")
            {
                var createResult = await CreateRoom(new CreateVideoRoomRequest
                {
                    ChannelName = request.ChannelName,
                    Title = request.ChannelName
                });
                
                if (createResult.Result is OkObjectResult okResult && okResult.Value is JoinVideoRoomResponse resp && resp.Success)
                {
                    room = await _videoRoomRepository.GetByChannelNameAsync(request.ChannelName);
                }
                else
                {
                    return createResult;
                }
            }
            else
            {
                return NotFound(new JoinVideoRoomResponse
                {
                    Success = false,
                    Error = "Video room not found. Only professors can start video calls."
                });
            }
        }

        // Only host or admin can "enter" (set host_joined = true)
        if (room!.HostUserId != user.Id && user.Role != "admin")
        {
            // This is not the host - they should use "join" endpoint instead
            return StatusCode(403, new JoinVideoRoomResponse
            {
                Success = false,
                Error = "Only the room creator can enter first. Students should use the join endpoint."
            });
        }

        // Set host as joined
        await _videoRoomRepository.SetHostJoinedAsync(request.ChannelName, true);

        // Add host as participant
        await _videoRoomRepository.AddParticipantAsync(room.Id, user.Id, "host");

        // Generate RTC token
        var uid = (uint)user.Id;
        var rtcToken = _agora.RtcTokenGenerate(room.ChannelName, uid);
        var token = rtcToken?.Token ?? "";

        _logger.LogInformation("Host {Username} entered video room {ChannelName} - students can now join", 
            user.Username, room.ChannelName);

        // Reload room to get updated state
        room = await _videoRoomRepository.GetByIdAsync(room.Id);

        return Ok(new JoinVideoRoomResponse
        {
            Success = true,
            Room = MapToResponse(room!),
            RtcToken = token,
            Uid = uid.ToString()
        });
    }

    /// <summary>
    /// Join an existing video room (for students).
    /// Students can ONLY join if the professor (host) has already entered.
    /// </summary>
    [HttpPost("join")]
    [ProducesResponseType(typeof(JoinVideoRoomResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(JoinVideoRoomResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<JoinVideoRoomResponse>> JoinRoom([FromBody] JoinVideoRoomRequest request)
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Unauthorized(new JoinVideoRoomResponse
            {
                Success = false,
                Error = "Authentication required."
            });
        }

        // Find the room
        var room = await _videoRoomRepository.GetByChannelNameAsync(request.ChannelName);
        
        if (room == null || !room.IsActive)
        {
            // Room doesn't exist
            if (user.Role == "aluno")
            {
                return NotFound(new JoinVideoRoomResponse
                {
                    Success = false,
                    Error = "Video room not found. Wait for your professor to start the video call."
                });
            }
            
            // Professors/admins can use enter endpoint
            return await EnterRoom(request);
        }

        // CRITICAL: Check if host has joined
        if (!room.HostJoined)
        {
            // Host hasn't entered yet
            if (user.Role == "aluno")
            {
                return StatusCode(403, new JoinVideoRoomResponse
                {
                    Success = false,
                    Error = "The professor has not started the call yet. Please wait for the professor to enter first."
                });
            }
            
            // If it's the host trying to join, redirect to enter
            if (room.HostUserId == user.Id || user.Role == "admin")
            {
                return await EnterRoom(request);
            }
        }

        // Check max participants
        var currentCount = await _videoRoomRepository.GetParticipantCountAsync(room.Id);
        if (currentCount >= room.MaxParticipants)
        {
            return BadRequest(new JoinVideoRoomResponse
            {
                Success = false,
                Error = "Room is full."
            });
        }

        // Add as participant
        var participantRole = (user.Role == "professor" || user.Role == "admin") ? "co-host" : "participant";
        await _videoRoomRepository.AddParticipantAsync(room.Id, user.Id, participantRole);

        // Generate RTC token
        var uid = (uint)user.Id;
        var rtcToken = _agora.RtcTokenGenerate(room.ChannelName, uid);
        var token = rtcToken?.Token ?? "";

        _logger.LogInformation("User {Username} ({Role}) joined video room {ChannelName}", 
            user.Username, user.Role, room.ChannelName);

        // Reload room to get updated participant count
        room = await _videoRoomRepository.GetByIdAsync(room.Id);

        return Ok(new JoinVideoRoomResponse
        {
            Success = true,
            Room = MapToResponse(room!),
            RtcToken = token,
            Uid = uid.ToString()
        });
    }

    /// <summary>
    /// Leave a video room.
    /// If the host leaves, the room is ended.
    /// </summary>
    [HttpPost("leave")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult> LeaveRoom([FromBody] JoinVideoRoomRequest request)
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Unauthorized(new { error = "Authentication required." });
        }

        var room = await _videoRoomRepository.GetByChannelNameAsync(request.ChannelName);
        if (room != null)
        {
            await _videoRoomRepository.RemoveParticipantAsync(room.Id, user.Id);

            // If host leaves, end the room entirely
            if (room.HostUserId == user.Id)
            {
                await _videoRoomRepository.EndRoomAsync(request.ChannelName);
                
                // Reload to get duration
                var endedRoom = await _videoRoomRepository.GetByChannelNameAsync(request.ChannelName);
                
                _logger.LogInformation("Host {Username} left, ending room {ChannelName}. Duration: {Duration}s", 
                    user.Username, request.ChannelName, endedRoom?.TotalDurationSeconds ?? 0);
                
                return Ok(new { 
                    success = true, 
                    message = "Room ended because host left.",
                    totalDurationSeconds = endedRoom?.TotalDurationSeconds ?? 0
                });
            }
            else
            {
                _logger.LogInformation("User {Username} left room {ChannelName}", user.Username, request.ChannelName);
            }
        }

        return Ok(new { success = true });
    }

    /// <summary>
    /// End a video room (host or admin only).
    /// </summary>
    [HttpPost("end")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult> EndRoom([FromBody] JoinVideoRoomRequest request)
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Unauthorized(new { error = "Authentication required." });
        }

        var room = await _videoRoomRepository.GetByChannelNameAsync(request.ChannelName);
        if (room == null)
        {
            return NotFound(new { error = "Room not found." });
        }

        // Only host or admin can end the room
        if (room.HostUserId != user.Id && user.Role != "admin")
        {
            return StatusCode(403, new { error = "Only the host or admin can end this room." });
        }

        await _videoRoomRepository.EndRoomAsync(request.ChannelName);
        
        // Get updated room with duration
        var endedRoom = await _videoRoomRepository.GetByChannelNameAsync(request.ChannelName);
        
        _logger.LogInformation("User {Username} ended room {ChannelName}. Total duration: {Duration}s", 
            user.Username, request.ChannelName, endedRoom?.TotalDurationSeconds ?? 0);

        return Ok(new { 
            success = true, 
            message = "Room ended.",
            totalDurationSeconds = endedRoom?.TotalDurationSeconds ?? 0
        });
    }

    /// <summary>
    /// Get all active video rooms.
    /// For students, only shows rooms where professor has joined.
    /// </summary>
    [HttpGet("active")]
    [ProducesResponseType(typeof(List<VideoRoomResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<VideoRoomResponse>>> GetActiveRooms()
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Unauthorized(new { error = "Authentication required." });
        }

        List<Data.Entities.VideoRoomEntity> rooms;
        
        if (user.Role == "aluno")
        {
            // Students only see rooms where host has joined
            rooms = await _videoRoomRepository.GetAvailableRoomsForStudentsAsync();
        }
        else
        {
            // Professors/admins see all active rooms
            rooms = await _videoRoomRepository.GetActiveRoomsAsync();
        }
        
        return Ok(rooms.Select(MapToResponse).ToList());
    }

    /// <summary>
    /// Get room status and participants.
    /// </summary>
    [HttpGet("{channelName}/status")]
    [ProducesResponseType(typeof(VideoRoomResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<VideoRoomResponse>> GetRoomStatus(string channelName)
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Unauthorized(new { error = "Authentication required." });
        }

        var room = await _videoRoomRepository.GetByChannelNameAsync(channelName);
        if (room == null)
        {
            return NotFound(new { error = "Room not found." });
        }

        return Ok(MapToResponse(room));
    }

    /// <summary>
    /// Check if user can start a video call.
    /// </summary>
    [HttpGet("can-start")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    public async Task<ActionResult> CanStartVideoCall()
    {
        var user = await GetAuthenticatedUser();
        if (user == null)
        {
            return Ok(new { canStart = false, reason = "Not authenticated" });
        }

        var canStart = user.Role == "admin" || user.Role == "professor";
        return Ok(new
        {
            canStart,
            role = user.Role,
            reason = canStart ? null : "Only professors and administrators can start video calls."
        });
    }

    #region Helper Methods

    private string? GetTokenFromHeader()
    {
        var authHeader = Request.Headers.Authorization.ToString();
        if (string.IsNullOrEmpty(authHeader)) return null;

        if (authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return authHeader.Substring("Bearer ".Length).Trim();
        }

        return authHeader;
    }

    private async Task<Data.Entities.UserEntity?> GetAuthenticatedUser()
    {
        var token = GetTokenFromHeader();
        if (string.IsNullOrEmpty(token)) return null;

        var session = await _sessionRepository.GetByTokenAsync(token);
        return session?.User;
    }

    private static VideoRoomResponse MapToResponse(Data.Entities.VideoRoomEntity room)
    {
        return new VideoRoomResponse
        {
            Id = room.Id,
            ChannelName = room.ChannelName,
            Title = room.Title,
            HostUserId = room.HostUserId,
            HostUsername = room.HostUsername ?? room.Host?.Username,
            HostDisplayName = room.Host?.DisplayName,
            IsActive = room.IsActive,
            HostJoined = room.HostJoined,
            StartedAt = room.StartedAt,
            EndedAt = room.EndedAt,
            TotalDurationSeconds = room.TotalDurationSeconds,
            MaxParticipants = room.MaxParticipants,
            CurrentParticipants = room.Participants?.Count(p => p.LeftAt == null) ?? 0,
            CreatedAt = room.CreatedAt
        };
    }

    #endregion
}
