using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Synget.AgoraIntegrator.API.Data.Entities;
using Synget.AgoraIntegrator.API.Data.Repositories;
using Synget.AgoraIntegrator.API.Hubs;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// API controller for video call management.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class VideoCallsController : ControllerBase
{
    private readonly IVideoCallRepository _callRepo;
    private readonly IUserRepository _userRepo;
    private readonly IProfessorRoomRepository _professorRoomRepo;
    private readonly IHubContext<ChatHub> _hubContext;
    private readonly ILogger<VideoCallsController> _logger;

    public VideoCallsController(
        IVideoCallRepository callRepo,
        IUserRepository userRepo,
        IProfessorRoomRepository professorRoomRepo,
        IHubContext<ChatHub> hubContext,
        ILogger<VideoCallsController> logger)
    {
        _callRepo = callRepo;
        _userRepo = userRepo;
        _professorRoomRepo = professorRoomRepo;
        _hubContext = hubContext;
        _logger = logger;
    }

    /// <summary>
    /// Start a new video call.
    /// </summary>
    [HttpPost("start")]
    public async Task<IActionResult> StartCall([FromBody] StartCallDto request)
    {
        if (string.IsNullOrWhiteSpace(request.ChannelName))
        {
            return BadRequest(new { error = "Channel name is required." });
        }

        try
        {
            // Check if there's already an active call on this channel
            var existingCall = await _callRepo.GetActiveCallAsync(request.ChannelName);
            if (existingCall != null)
            {
                return Ok(MapToDto(existingCall));
            }

            var call = await _callRepo.StartCallAsync(
                request.ChannelName,
                request.InitiatedByUserId,
                request.CallType ?? "video",
                request.GroupRoomId,
                request.CallName
            );

            return Ok(MapToDto(call));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error starting call");
            return StatusCode(500, new { error = "Failed to start call." });
        }
    }

    /// <summary>
    /// Join an existing call.
    /// </summary>
    [HttpPost("{callId:guid}/join")]
    public async Task<IActionResult> JoinCall(Guid callId, [FromBody] JoinCallDto request)
    {
        try
        {
            var participant = await _callRepo.JoinCallAsync(
                callId,
                request.UserId,
                request.Role ?? "participant",
                request.DeviceType
            );

            var call = await _callRepo.GetByIdAsync(callId, includeParticipants: true);
            return Ok(MapToDto(call!));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error joining call {CallId}", callId);
            return StatusCode(500, new { error = "Failed to join call." });
        }
    }

    /// <summary>
    /// Leave a call.
    /// </summary>
    [HttpPost("{callId:guid}/leave")]
    public async Task<IActionResult> LeaveCall(Guid callId, [FromBody] LeaveCallDto request)
    {
        try
        {
            var participant = await _callRepo.LeaveCallAsync(callId, request.UserId);
            if (participant == null)
            {
                return NotFound(new { error = "Participant not found in call." });
            }

            return Ok(new
            {
                participant.Id,
                participant.UserId,
                participant.JoinedAt,
                participant.LeftAt,
                participant.DurationSeconds
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error leaving call {CallId}", callId);
            return StatusCode(500, new { error = "Failed to leave call." });
        }
    }

    /// <summary>
    /// End a call.
    /// </summary>
    [HttpPost("{callId:guid}/end")]
    public async Task<IActionResult> EndCall(Guid callId)
    {
        try
        {
            var call = await _callRepo.EndCallAsync(callId);
            if (call == null)
            {
                return NotFound(new { error = "Call not found." });
            }

            return Ok(MapToDto(call));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error ending call {CallId}", callId);
            return StatusCode(500, new { error = "Failed to end call." });
        }
    }

    /// <summary>
    /// Get call by ID.
    /// </summary>
    [HttpGet("{callId:guid}")]
    public async Task<IActionResult> GetCall(Guid callId)
    {
        var call = await _callRepo.GetByIdAsync(callId, includeParticipants: true);
        if (call == null)
        {
            return NotFound(new { error = "Call not found." });
        }

        return Ok(MapToDto(call));
    }

    /// <summary>
    /// Get active call for a channel.
    /// </summary>
    [HttpGet("channel/{channelName}")]
    public async Task<IActionResult> GetActiveCall(string channelName)
    {
        var call = await _callRepo.GetActiveCallAsync(channelName);
        if (call == null)
        {
            return NotFound(new { error = "No active call on this channel." });
        }

        return Ok(MapToDto(call));
    }

    /// <summary>
    /// Check if there's an active call on a channel (returns status without 404).
    /// </summary>
    [HttpGet("check/{channelName}")]
    public async Task<IActionResult> CheckActiveCall(string channelName)
    {
        var call = await _callRepo.GetActiveCallAsync(channelName);
        
        return Ok(new
        {
            hasActiveCall = call != null,
            channelName,
            call = call != null ? MapToDto(call) : null
        });
    }

    /// <summary>
    /// Get all active calls.
    /// </summary>
    [HttpGet("active")]
    public async Task<IActionResult> GetActiveCalls()
    {
        var calls = await _callRepo.GetActiveCallsAsync();
        return Ok(calls.Select(MapToDto));
    }

    /// <summary>
    /// Get call history for a user.
    /// </summary>
    [HttpGet("user/{userId:guid}/history")]
    public async Task<IActionResult> GetUserHistory(Guid userId, [FromQuery] int limit = 50, [FromQuery] DateTime? before = null)
    {
        try
        {
            var calls = await _callRepo.GetUserCallHistoryAsync(userId, limit, before);
            return Ok(calls.Select(MapToDto));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting call history for user {UserId}", userId);
            return StatusCode(500, new { error = "Failed to get call history." });
        }
    }

    /// <summary>
    /// Get call participants.
    /// </summary>
    [HttpGet("{callId:guid}/participants")]
    public async Task<IActionResult> GetParticipants(Guid callId, [FromQuery] bool activeOnly = true)
    {
        var participants = await _callRepo.GetParticipantsAsync(callId, activeOnly);
        return Ok(participants.Select(p => new
        {
            p.Id,
            p.UserId,
            UserName = p.User?.DisplayName ?? p.User?.Username,
            p.Role,
            p.JoinedAt,
            p.LeftAt,
            p.DurationSeconds,
            p.HadVideo,
            p.HadAudio,
            p.HadScreenShare,
            p.DeviceType
        }));
    }

    // ==================== USERNAME-BASED ENDPOINTS ====================

    /// <summary>
    /// Start a video call using username (creates/gets user automatically).
    /// Used when a professor starts a call in their room.
    /// </summary>
    [HttpPost("start-by-username")]
    public async Task<IActionResult> StartCallByUsername([FromBody] StartCallByUsernameDto request)
    {
        if (string.IsNullOrWhiteSpace(request.ChannelName))
        {
            return BadRequest(new { error = "Channel name is required." });
        }

        try
        {
            // Get or create user by username
            var user = await _userRepo.GetOrCreateAsync(
                request.Username, 
                request.DisplayName ?? request.Username
            );

            // Check if there's already an active call on this channel
            var existingCall = await _callRepo.GetActiveCallAsync(request.ChannelName);
            if (existingCall != null)
            {
                // Join existing call as participant
                var existingParticipant = existingCall.Participants?.FirstOrDefault(p => p.UserId == user.Id && p.LeftAt == null);
                if (existingParticipant == null)
                {
                    await _callRepo.JoinCallAsync(existingCall.Id, user.Id, "host", request.DeviceType);
                }
                var refreshedCall = await _callRepo.GetByIdAsync(existingCall.Id, includeParticipants: true);
                return Ok(MapToDto(refreshedCall!));
            }

            // Start new call
            var call = await _callRepo.StartCallAsync(
                request.ChannelName,
                user.Id,
                request.CallType ?? "video",
                null, // GroupRoomId
                request.ChannelName // CallName defaults to channel
            );

            // Creator joins as host
            await _callRepo.JoinCallAsync(call.Id, user.Id, "host", request.DeviceType);

            var callWithParticipants = await _callRepo.GetByIdAsync(call.Id, includeParticipants: true);

            // Notify students that the professor room is now online
            await NotifyProfessorRoomOnline(request.ChannelName, request.Username, true);

            _logger.LogInformation("User {Username} started video call on channel {Channel}", request.Username, request.ChannelName);
            return Ok(MapToDto(callWithParticipants!));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error starting call by username");
            return StatusCode(500, new { error = "Failed to start call." });
        }
    }

    /// <summary>
    /// Join an existing video call using username.
    /// Returns 404 if no active call exists (students can only join active calls).
    /// </summary>
    [HttpPost("join-by-username")]
    public async Task<IActionResult> JoinCallByUsername([FromBody] JoinCallByUsernameDto request)
    {
        if (string.IsNullOrWhiteSpace(request.ChannelName))
        {
            return BadRequest(new { error = "Channel name is required." });
        }

        try
        {
            // Check if there's an active call
            var call = await _callRepo.GetActiveCallAsync(request.ChannelName);
            if (call == null)
            {
                return NotFound(new { 
                    error = "No active call on this channel.",
                    message = "The professor has not started the video call yet. Please wait for the call to begin."
                });
            }

            // Get or create user by username
            var user = await _userRepo.GetOrCreateAsync(
                request.Username, 
                request.DisplayName ?? request.Username
            );

            // Check if already a participant
            var existingParticipant = call.Participants?.FirstOrDefault(p => p.UserId == user.Id && p.LeftAt == null);
            if (existingParticipant == null)
            {
                await _callRepo.JoinCallAsync(call.Id, user.Id, "participant", request.DeviceType);
            }

            var callWithParticipants = await _callRepo.GetByIdAsync(call.Id, includeParticipants: true);

            _logger.LogInformation("User {Username} joined video call on channel {Channel}", request.Username, request.ChannelName);
            return Ok(MapToDto(callWithParticipants!));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error joining call by username");
            return StatusCode(500, new { error = "Failed to join call." });
        }
    }

    /// <summary>
    /// Leave a video call using username.
    /// </summary>
    [HttpPost("leave-by-username")]
    public async Task<IActionResult> LeaveCallByUsername([FromBody] LeaveCallByUsernameDto request)
    {
        if (string.IsNullOrWhiteSpace(request.ChannelName))
        {
            return BadRequest(new { error = "Channel name is required." });
        }

        try
        {
            // Get user
            var user = await _userRepo.GetByUsernameAsync(request.Username);
            if (user == null)
            {
                return NotFound(new { error = "User not found." });
            }

            // Get active call
            var call = await _callRepo.GetActiveCallAsync(request.ChannelName);
            if (call == null)
            {
                return NotFound(new { error = "No active call on this channel." });
            }

            // Leave call
            var participant = await _callRepo.LeaveCallAsync(call.Id, user.Id);
            if (participant == null)
            {
                return NotFound(new { error = "User is not a participant in this call." });
            }

            // Check if call should end (no more active participants or host left)
            var remainingParticipants = call.Participants?.Count(p => p.LeftAt == null && p.UserId != user.Id) ?? 0;
            var isHost = participant.Role == "host";

            // If host leaves, end the call
            if (isHost)
            {
                await _callRepo.EndCallAsync(call.Id);
                _logger.LogInformation("Host {Username} left - ending call on channel {Channel}", request.Username, request.ChannelName);
                
                // Notify students that the professor room is now offline
                await NotifyProfessorRoomOnline(request.ChannelName, request.Username, false);
            }

            var updatedCall = await _callRepo.GetByIdAsync(call.Id, includeParticipants: true);

            return Ok(new
            {
                participant = new
                {
                    participant.Id,
                    participant.UserId,
                    username = user.Username,
                    participant.JoinedAt,
                    participant.LeftAt,
                    participant.DurationSeconds
                },
                call = MapToDto(updatedCall!)
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error leaving call by username");
            return StatusCode(500, new { error = "Failed to leave call." });
        }
    }

    /// <summary>
    /// End a video call by channel name.
    /// </summary>
    [HttpPost("end-by-channel/{channelName}")]
    public async Task<IActionResult> EndCallByChannel(string channelName)
    {
        try
        {
            var call = await _callRepo.GetActiveCallAsync(channelName);
            if (call == null)
            {
                return NotFound(new { error = "No active call on this channel." });
            }

            var endedCall = await _callRepo.EndCallAsync(call.Id);
            _logger.LogInformation("Call ended on channel {Channel}", channelName);

            return Ok(MapToDto(endedCall!));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error ending call on channel {Channel}", channelName);
            return StatusCode(500, new { error = "Failed to end call." });
        }
    }

    private static object MapToDto(VideoCallEntity call)
    {
        return new
        {
            call.Id,
            call.ChannelName,
            call.CallName,
            call.CallType,
            call.GroupRoomId,
            call.InitiatedByUserId,
            InitiatedByName = call.InitiatedByUser?.DisplayName ?? call.InitiatedByUser?.Username,
            call.Status,
            call.StartedAt,
            call.EndedAt,
            call.DurationSeconds,
            call.MaxParticipants,
            call.IsRecorded,
            CurrentParticipants = call.Participants?.Where(p => p.LeftAt == null).Select(p => new
            {
                p.Id,
                p.UserId,
                UserName = p.User?.DisplayName ?? p.User?.Username,
                p.Role,
                p.JoinedAt,
                p.DeviceType
            }).ToList()
        };
    }

    /// <summary>
    /// Notify all subscribed students about a professor room status change.
    /// </summary>
    private async Task NotifyProfessorRoomOnline(string channelName, string username, bool isOnline)
    {
        try
        {
            // Check if this is a professor room
            var professorRoom = await _professorRoomRepo.GetByRoomNameAsync(channelName);
            if (professorRoom == null)
            {
                // Also check by username pattern
                professorRoom = await _professorRoomRepo.GetByUsernameAsync(username);
            }

            if (professorRoom != null)
            {
                var participantCount = 0;
                if (isOnline)
                {
                    var activeCall = await _callRepo.GetActiveCallAsync(channelName);
                    participantCount = activeCall?.Participants?.Count(p => p.LeftAt == null) ?? 0;
                }

                await _hubContext.Clients.Group("professor_room_updates").SendAsync("ProfessorRoomStatusChanged", new
                {
                    roomName = professorRoom.RoomName,
                    professorUsername = professorRoom.Professor?.Username ?? username,
                    isOnline = isOnline,
                    participantCount = participantCount,
                    timestamp = DateTime.UtcNow.ToString("o")
                });

                _logger.LogInformation("Notified professor room status change: {RoomName} is {Status}", 
                    professorRoom.RoomName, isOnline ? "online" : "offline");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to notify professor room status change");
        }
    }
}

// DTOs
public class StartCallDto
{
    public string ChannelName { get; set; } = string.Empty;
    public string? CallName { get; set; }
    public string? CallType { get; set; }
    public Guid InitiatedByUserId { get; set; }
    public Guid? GroupRoomId { get; set; }
}

public class JoinCallDto
{
    public Guid UserId { get; set; }
    public string? Role { get; set; }
    public string? DeviceType { get; set; }
}

public class LeaveCallDto
{
    public Guid UserId { get; set; }
}

// Username-based DTOs
public class StartCallByUsernameDto
{
    public string ChannelName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? CallType { get; set; }
    public string? DeviceType { get; set; }
}

public class JoinCallByUsernameDto
{
    public string ChannelName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? DeviceType { get; set; }
}

public class LeaveCallByUsernameDto
{
    public string ChannelName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
}
