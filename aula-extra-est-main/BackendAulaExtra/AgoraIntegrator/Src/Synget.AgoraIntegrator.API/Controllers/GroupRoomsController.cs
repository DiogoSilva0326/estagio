using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator.API.Data.Entities;
using Synget.AgoraIntegrator.API.Data.Repositories;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// API controller for group room management.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class GroupRoomsController : ControllerBase
{
    private readonly IGroupRoomRepository _roomRepo;
    private readonly IMessageRepository _messageRepo;
    private readonly ILogger<GroupRoomsController> _logger;

    public GroupRoomsController(
        IGroupRoomRepository roomRepo,
        IMessageRepository messageRepo,
        ILogger<GroupRoomsController> logger)
    {
        _roomRepo = roomRepo;
        _messageRepo = messageRepo;
        _logger = logger;
    }

    /// <summary>
    /// Create a new group room.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> CreateRoom([FromBody] CreateRoomDto request)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return BadRequest(new { error = "Room name is required." });
        }

        try
        {
            var room = await _roomRepo.CreateAsync(
                request.Name,
                request.CreatedByUserId,
                request.RoomType ?? "group",
                request.Description
            );

            // Add additional members if provided
            if (request.MemberUserIds?.Any() == true)
            {
                foreach (var memberId in request.MemberUserIds.Where(id => id != request.CreatedByUserId))
                {
                    await _roomRepo.AddMemberAsync(room.Id, memberId);
                }
            }

            return Ok(await MapToDto(room));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating room");
            return StatusCode(500, new { error = "Failed to create room." });
        }
    }

    /// <summary>
    /// Get or create a direct message room between two users.
    /// </summary>
    [HttpPost("direct")]
    public async Task<IActionResult> GetOrCreateDirectRoom([FromBody] DirectRoomDto request)
    {
        try
        {
            var room = await _roomRepo.GetOrCreateDirectRoomAsync(request.UserId1, request.UserId2);
            return Ok(await MapToDto(room));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating direct room");
            return StatusCode(500, new { error = "Failed to create direct room." });
        }
    }

    /// <summary>
    /// Get room by ID.
    /// </summary>
    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id)
    {
        var room = await _roomRepo.GetByIdAsync(id, includeMembers: true);
        if (room == null)
        {
            return NotFound(new { error = "Room not found." });
        }

        return Ok(await MapToDto(room));
    }

    /// <summary>
    /// Get room by room code.
    /// </summary>
    [HttpGet("by-code/{roomCode}")]
    public async Task<IActionResult> GetByRoomCode(string roomCode)
    {
        var room = await _roomRepo.GetByRoomCodeAsync(roomCode, includeMembers: true);
        if (room == null)
        {
            return NotFound(new { error = "Room not found." });
        }

        return Ok(await MapToDto(room));
    }

    /// <summary>
    /// Get rooms for a user.
    /// </summary>
    [HttpGet("user/{userId:long}")]
    public async Task<IActionResult> GetUserRooms(long userId)
    {
        try
        {
            var rooms = await _roomRepo.GetByUserAsync(userId);
            var result = new List<object>();
            foreach (var room in rooms)
            {
                result.Add(await MapToDto(room));
            }
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting rooms for user {UserId}", userId);
            return StatusCode(500, new { error = "Failed to get rooms." });
        }
    }

    /// <summary>
    /// Add a member to a room.
    /// </summary>
    [HttpPost("{roomId:long}/members")]
    public async Task<IActionResult> AddMember(long roomId, [FromBody] AddMemberDto request)
    {
        try
        {
            var member = await _roomRepo.AddMemberAsync(roomId, request.UserId, request.Role ?? "member");
            return Ok(new
            {
                member.Id,
                member.RoomId,
                member.UserId,
                member.Role,
                member.Status,
                member.JoinedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding member to room {RoomId}", roomId);
            return StatusCode(500, new { error = "Failed to add member." });
        }
    }

    /// <summary>
    /// Remove a member from a room.
    /// </summary>
    [HttpDelete("{roomId:long}/members/{userId:long}")]
    public async Task<IActionResult> RemoveMember(long roomId, long userId)
    {
        var success = await _roomRepo.RemoveMemberAsync(roomId, userId);
        if (!success)
        {
            return NotFound(new { error = "Member not found." });
        }

        return Ok(new { message = "Member removed." });
    }

    /// <summary>
    /// Get room members.
    /// </summary>
    [HttpGet("{roomId:long}/members")]
    public async Task<IActionResult> GetMembers(long roomId)
    {
        var members = await _roomRepo.GetMembersAsync(roomId);
        return Ok(members.Select(m => new
        {
            m.Id,
            m.UserId,
            UserName = m.User?.DisplayName ?? m.User?.Username,
            m.Role,
            m.Nickname,
            m.Status,
            m.JoinedAt
        }));
    }

    /// <summary>
    /// Get message history for a room.
    /// </summary>
    [HttpGet("{roomId:long}/messages")]
    public async Task<IActionResult> GetMessages(long roomId, [FromQuery] int limit = 50, [FromQuery] DateTime? before = null)
    {
        var room = await _roomRepo.GetByIdAsync(roomId);
        if (room == null)
        {
            return NotFound(new { error = "Room not found." });
        }

        var messages = await _messageRepo.GetByRoomAsync(room.RoomCode, limit, before);
        return Ok(messages.Select(m => new
        {
            m.Id,
            m.RoomId,
            SenderId = m.SenderUserId?.ToString() ?? m.SenderId,
            SenderName = m.SenderUser?.DisplayName ?? m.SenderUser?.Username ?? "Unknown",
            m.Content,
            m.Metadata,
            m.CreatedAt
        }));
    }

    /// <summary>
    /// Update room details.
    /// </summary>
    [HttpPut("{roomId:long}")]
    public async Task<IActionResult> UpdateRoom(long roomId, [FromBody] UpdateRoomDto request)
    {
        var room = await _roomRepo.UpdateAsync(roomId, request.Name, request.Description, request.AvatarUrl);
        if (room == null)
        {
            return NotFound(new { error = "Room not found." });
        }

        return Ok(await MapToDto(room));
    }

    /// <summary>
    /// Deactivate a room.
    /// </summary>
    [HttpDelete("{roomId:long}")]
    public async Task<IActionResult> DeactivateRoom(long roomId)
    {
        var success = await _roomRepo.DeactivateAsync(roomId);
        if (!success)
        {
            return NotFound(new { error = "Room not found." });
        }

        return Ok(new { message = "Room deactivated." });
    }

    private async Task<object> MapToDto(GroupRoomEntity room)
    {
        var members = room.Members?.ToList() ?? await _roomRepo.GetMembersAsync(room.Id);

        return new
        {
            room.Id,
            room.RoomCode,
            room.Name,
            room.Description,
            room.RoomType,
            room.CreatedByUserId,
            room.IsActive,
            room.AvatarUrl,
            room.CreatedAt,
            room.UpdatedAt,
            MemberCount = members.Count,
            Members = members.Select(m => new
            {
                m.UserId,
                UserName = m.User?.DisplayName ?? m.User?.Username,
                m.Role
            })
        };
    }
}

// DTOs
public class CreateRoomDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? RoomType { get; set; }
    public long CreatedByUserId { get; set; }
    public List<long>? MemberUserIds { get; set; }
}

public class DirectRoomDto
{
    public long UserId1 { get; set; }
    public long UserId2 { get; set; }
}

public class AddMemberDto
{
    public long UserId { get; set; }
    public string? Role { get; set; }
}

public class UpdateRoomDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    public string? AvatarUrl { get; set; }
}
