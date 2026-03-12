using Microsoft.AspNetCore.Mvc;
using Synget.ChatIntegrator;
using Synget.AgoraIntegrator.API.DTOs;
using Synget.AgoraIntegrator.API.Data.Repositories;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for managing standalone chat rooms (DMs and groups)
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class StandaloneChatController : ControllerBase
{
    private readonly IChat _chat;
    private readonly IUserRepository _userRepository;
    private readonly IGroupRoomRepository _groupRoomRepository;
    private readonly IMessageRepository _messageRepository;
    private readonly ILogger<StandaloneChatController> _logger;

    public StandaloneChatController(
        IChat chat, 
        IUserRepository userRepository, 
        IGroupRoomRepository groupRoomRepository,
        IMessageRepository messageRepository,
        ILogger<StandaloneChatController> logger)
    {
        _chat = chat;
        _userRepository = userRepository;
        _groupRoomRepository = groupRoomRepository;
        _messageRepository = messageRepository;
        _logger = logger;
    }

    /// <summary>
    /// Get all chat rooms for a user
    /// </summary>
    [HttpGet("rooms/{userId}")]
    [ProducesResponseType(typeof(List<ChatRoomResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<ChatRoomResponse>>> GetUserRooms(string userId)
    {
        _logger.LogInformation("Getting chat rooms for user: {UserId}", userId);

        // Get numeric user ID
        var numericUserId = await GetNumericUserId(userId);
        if (numericUserId == null)
        {
            _logger.LogWarning("User not found: {UserId}", userId);
            return Ok(new List<ChatRoomResponse>());
        }

        // Get rooms from database
        var rooms = await _groupRoomRepository.GetByUserAsync(numericUserId.Value);
        
        // Get last message times for all rooms
        // Messages are stored with channelName which includes the "group_" prefix for group rooms
        var channelNames = rooms.Select(r => r.RoomType == RoomType.Group ? $"group_{r.RoomCode}" : r.RoomCode).ToList();
        var lastMessageTimes = await _messageRepository.GetLastMessageTimesAsync(channelNames);
        
        var response = rooms.Select(room => {
            var channelName = room.RoomType == RoomType.Group ? $"group_{room.RoomCode}" : room.RoomCode;
            lastMessageTimes.TryGetValue(channelName, out var time);
            return MapEntityToResponse(room, time);
        }).ToList();

        return Ok(response);
    }

    /// <summary>
    /// Get a specific chat room
    /// </summary>
    [HttpGet("room/{roomId}")]
    [ProducesResponseType(typeof(ChatRoomResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ChatRoomResponse>> GetRoom(string roomId)
    {
        _logger.LogInformation("Getting chat room: {RoomId}", roomId);

        // Try to get by ID first (if numeric)
        if (long.TryParse(roomId, out var numericId))
        {
            var roomById = await _groupRoomRepository.GetByIdAsync(numericId, includeMembers: true);
            if (roomById != null)
            {
                return Ok(MapEntityToResponse(roomById));
            }
        }

        // Try to get by room code
        var room = await _groupRoomRepository.GetByRoomCodeAsync(roomId, includeMembers: true);
        
        if (room is null)
        {
            return NotFound();
        }

        return Ok(MapEntityToResponse(room));
    }

    /// <summary>
    /// Create or get a direct message room between two users
    /// </summary>
    [HttpPost("dm")]
    [ProducesResponseType(typeof(ChatRoomResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ChatRoomResponse>> CreateDirectMessage([FromBody] CreateDMRequest request)
    {
        _logger.LogInformation("Creating DM between {User1} and {User2}", 
            request.UserId1, request.UserId2);

        // Get numeric user IDs
        var userId1 = await GetNumericUserId(request.UserId1);
        var userId2 = await GetNumericUserId(request.UserId2);

        if (userId1 == null || userId2 == null)
        {
            var missingUser = userId1 == null ? request.UserId1 : request.UserId2;
            return BadRequest(new ErrorResponse { Message = $"User not found: {missingUser}" });
        }

        _logger.LogInformation("Normalized user IDs: {User1} -> {NormUser1}, {User2} -> {NormUser2}", 
            request.UserId1, userId1, request.UserId2, userId2);

        // Create or get the room from database
        var roomEntity = await _groupRoomRepository.GetOrCreateDirectRoomAsync(userId1.Value, userId2.Value);

        // Also create in memory for SignalR chat functionality
        var normalizedUser1 = await NormalizeToUsername(request.UserId1);
        var normalizedUser2 = await NormalizeToUsername(request.UserId2);
        _chat.DirectMessageGetOrCreate(normalizedUser1, normalizedUser2);

        // Reload with members to get full data
        var roomWithMembers = await _groupRoomRepository.GetByIdAsync(roomEntity.Id, includeMembers: true);

        return Ok(MapEntityToResponse(roomWithMembers!));
    }

    /// <summary>
    /// Create a group chat
    /// </summary>
    [HttpPost("group")]
    [ProducesResponseType(typeof(ChatRoomResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ChatRoomResponse>> CreateGroup([FromBody] CreateGroupRequest request)
    {
        _logger.LogInformation("User {Creator} creating group {Name}", 
            request.CreatorUserId, request.GroupName);

        // Get numeric creator ID
        var creatorId = await GetNumericUserId(request.CreatorUserId);
        if (creatorId == null)
        {
            return BadRequest(new ErrorResponse { Message = $"Creator user not found: {request.CreatorUserId}" });
        }

        // Create group in database
        var roomEntity = await _groupRoomRepository.CreateAsync(
            request.GroupName, 
            creatorId.Value, 
            RoomType.Group);

        // Add all members to the group
        foreach (var memberId in request.MemberUserIds)
        {
            var numericMemberId = await GetNumericUserId(memberId);
            if (numericMemberId != null && numericMemberId != creatorId)
            {
                await _groupRoomRepository.AddMemberAsync(roomEntity.Id, numericMemberId.Value, MemberRole.Member);
            }
        }

        // Also create in memory for SignalR chat functionality
        var normalizedCreator = await NormalizeToUsername(request.CreatorUserId);
        var memberUsernames = new List<string>();
        foreach (var memberId in request.MemberUserIds)
        {
            memberUsernames.Add(await NormalizeToUsername(memberId));
        }
        _chat.GroupCreate(normalizedCreator, request.GroupName, memberUsernames);

        // Reload with members to get full data
        var roomWithMembers = await _groupRoomRepository.GetByIdAsync(roomEntity.Id, includeMembers: true);

        return Ok(MapEntityToResponse(roomWithMembers!));
    }

    /// <summary>
    /// Add a member to a group
    /// </summary>
    [HttpPost("group/{roomId}/members")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> AddGroupMember(string roomId, [FromBody] AddGroupMemberRequest request)
    {
        _logger.LogInformation("Adding user {UserId} to group {RoomId}", request.UserId, roomId);

        // Get numeric room ID
        if (!long.TryParse(roomId, out var numericRoomId))
        {
            // Try to find by room code
            var roomByCode = await _groupRoomRepository.GetByRoomCodeAsync(roomId);
            if (roomByCode == null)
            {
                return BadRequest(new ErrorResponse { Message = "Room not found." });
            }
            numericRoomId = roomByCode.Id;
        }

        // Get numeric user ID
        var numericUserId = await GetNumericUserId(request.UserId);
        if (numericUserId == null)
        {
            return BadRequest(new ErrorResponse { Message = $"User not found: {request.UserId}" });
        }

        // Add to database
        await _groupRoomRepository.AddMemberAsync(numericRoomId, numericUserId.Value, MemberRole.Member);

        // Also add to in-memory for SignalR
        var normalizedUserId = await NormalizeToUsername(request.UserId);
        _chat.GroupAddMember(roomId, normalizedUserId);

        return Ok();
    }

    /// <summary>
    /// Remove a member from a group
    /// </summary>
    [HttpDelete("group/{roomId}/members/{userId}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> RemoveGroupMember(string roomId, string userId)
    {
        _logger.LogInformation("Removing user {UserId} from group {RoomId}", userId, roomId);

        // Get numeric room ID
        if (!long.TryParse(roomId, out var numericRoomId))
        {
            // Try to find by room code
            var roomByCode = await _groupRoomRepository.GetByRoomCodeAsync(roomId);
            if (roomByCode == null)
            {
                return BadRequest(new ErrorResponse { Message = "Room not found." });
            }
            numericRoomId = roomByCode.Id;
        }

        // Get numeric user ID
        var numericUserId = await GetNumericUserId(userId);
        if (numericUserId == null)
        {
            return BadRequest(new ErrorResponse { Message = $"User not found: {userId}" });
        }

        // Remove from database
        var success = await _groupRoomRepository.RemoveMemberAsync(numericRoomId, numericUserId.Value);
        
        if (!success)
        {
            return BadRequest(new ErrorResponse { Message = "Failed to remove member." });
        }

        // Also remove from in-memory for SignalR
        var normalizedUserId = await NormalizeToUsername(userId);
        _chat.GroupRemoveMember(roomId, normalizedUserId);

        return Ok();
    }

    /// <summary>
    /// Get message history for a room
    /// </summary>
    [HttpGet("room/{roomId}/messages")]
    [ProducesResponseType(typeof(List<MessageResponse>), StatusCodes.Status200OK)]
    public ActionResult<List<MessageResponse>> GetMessages(
        string roomId, 
        [FromQuery] int limit = 50,
        [FromQuery] DateTime? before = null)
    {
        _logger.LogInformation("Getting messages for room: {RoomId}", roomId);

        var room = _chat.StandaloneChatGetRoom(roomId);
        if (room is null)
        {
            return NotFound();
        }

        var messages = _chat.MessageGetHistory(room.ChannelName, limit, before);
        var response = messages.Select(m => new MessageResponse
        {
            MessageId = m.MessageId,
            SenderId = m.SenderId,
            SenderName = m.SenderName,
            Content = m.Content,
            Timestamp = m.Timestamp,
            Type = m.Type.ToString().ToLower()
        }).ToList();

        return Ok(response);
    }

    /// <summary>
    /// Gets a numeric user ID from a string (which could be numeric ID or username)
    /// </summary>
    private async Task<long?> GetNumericUserId(string userId)
    {
        // If it's already a numeric ID
        if (long.TryParse(userId, out var numericId))
        {
            return numericId;
        }
        
        // Look up by username
        var user = await _userRepository.GetByUsernameAsync(userId);
        return user?.Id;
    }

    /// <summary>
    /// Normalizes a user ID (which could be numeric ID or username) to always return username
    /// </summary>
    private async Task<string> NormalizeToUsername(string userId)
    {
        // If it's a numeric ID, look up the username
        if (long.TryParse(userId, out var numericId))
        {
            var user = await _userRepository.GetByIdAsync(numericId);
            return user?.Username ?? userId;
        }
        // Already a username
        return userId;
    }

    /// <summary>
    /// Maps a database entity to the response DTO
    /// </summary>
    private static ChatRoomResponse MapEntityToResponse(GroupRoomEntity room, DateTime? lastMessageAt = null)
    {
        var memberNames = new Dictionary<string, string>();
        if (room.Members != null)
        {
            foreach (var member in room.Members)
            {
                var displayName = member.User?.DisplayName ?? member.User?.Username ?? member.UserId.ToString();
                memberNames[member.UserId.ToString()] = displayName;
            }
        }

        return new ChatRoomResponse
        {
            RoomId = room.Id.ToString(),
            // For groups, prefix with "group_" to ensure message persistence works correctly
            // For direct messages, prefix with "dm_"
            ChannelName = room.RoomType == RoomType.Group 
                ? $"group_{room.RoomCode}" 
                : room.RoomCode,
            RoomType = room.RoomType,
            GroupName = room.RoomType == RoomType.Direct ? "Direct Message" : room.Name,
            GroupDescription = room.Description,
            CreatorUserId = room.CreatedByUserId?.ToString() ?? string.Empty,
            MemberUserIds = room.Members?.Select(m => m.UserId.ToString()).ToList() ?? new List<string>(),
            MemberNames = memberNames,
            CreatedAt = room.CreatedAt,
            IsActive = room.IsActive,
            LastMessageAt = lastMessageAt ?? room.UpdatedAt
        };
    }

    private static ChatRoomResponse MapRoomToResponse(StandaloneChatRoom room)
    {
        return new ChatRoomResponse
        {
            RoomId = room.RoomId,
            ChannelName = room.ChannelName,
            RoomType = room.RoomType.ToString(),
            GroupName = room.GroupName,
            GroupDescription = room.GroupDescription,
            CreatorUserId = room.CreatorUserId,
            MemberUserIds = room.MemberUserIds,
            CreatedAt = room.CreatedAt,
            IsActive = room.IsActive,
            LastMessageAt = room.Messages.LastOrDefault()?.Timestamp
        };
    }
}

// Request/Response DTOs
public class CreateDMRequest
{
    public string UserId1 { get; set; } = string.Empty;
    public string UserId2 { get; set; } = string.Empty;
}

public class CreateGroupRequest
{
    public string CreatorUserId { get; set; } = string.Empty;
    public string GroupName { get; set; } = string.Empty;
    public List<string> MemberUserIds { get; set; } = new();
}

public class AddGroupMemberRequest
{
    public string UserId { get; set; } = string.Empty;
}

public class ChatRoomResponse
{
    public string RoomId { get; set; } = string.Empty;
    public string ChannelName { get; set; } = string.Empty;
    public string RoomType { get; set; } = string.Empty;
    public string? GroupName { get; set; }
    public string? GroupDescription { get; set; }
    public string CreatorUserId { get; set; } = string.Empty;
    public List<string> MemberUserIds { get; set; } = new();
    /// <summary>
    /// Dictionary mapping user IDs to display names
    /// </summary>
    public Dictionary<string, string> MemberNames { get; set; } = new();
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastMessageAt { get; set; }
}

public class MessageResponse
{
    public string MessageId { get; set; } = string.Empty;
    public string SenderId { get; set; } = string.Empty;
    public string SenderName { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string Type { get; set; } = string.Empty;
}
