using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator.API.Data.Repositories;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// API controller for message history.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class MessagesController : ControllerBase
{
    private readonly IMessageRepository _messageRepo;
    private readonly IUserRepository _userRepo;
    private readonly ILogger<MessagesController> _logger;

    public MessagesController(
        IMessageRepository messageRepo,
        IUserRepository userRepo,
        ILogger<MessagesController> logger)
    {
        _messageRepo = messageRepo;
        _userRepo = userRepo;
        _logger = logger;
    }

    /// <summary>
    /// Get message history for a room/channel.
    /// </summary>
    [HttpGet("room/{roomId}")]
    public async Task<IActionResult> GetRoomHistory(
        string roomId,
        [FromQuery] int limit = 50,
        [FromQuery] DateTime? before = null)
    {
        try
        {
            var messages = await _messageRepo.GetByRoomAsync(roomId, limit, before);

            var result = messages.Select(m => new MessageDto
            {
                Id = m.Id,
                RoomId = m.RoomId,
                SenderId = m.SenderUserId?.ToString() ?? m.SenderId ?? "",
                SenderName = m.SenderUser?.DisplayName ?? m.SenderUser?.Username ?? "Unknown",
                Content = m.Content,
                Metadata = m.Metadata,
                CreatedAt = m.CreatedAt
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching room history for {RoomId}", roomId);
            return StatusCode(500, new { error = "Failed to fetch message history." });
        }
    }

    /// <summary>
    /// Get direct message history between two users.
    /// </summary>
    [HttpGet("dm/{userId1:long}/{userId2:long}")]
    public async Task<IActionResult> GetDmHistory(
        long userId1,
        long userId2,
        [FromQuery] int limit = 50,
        [FromQuery] DateTime? before = null)
    {
        try
        {
            var messages = await _messageRepo.GetDirectMessagesAsync(userId1, userId2, limit, before);

            var result = messages.Select(m => new MessageDto
            {
                Id = m.Id,
                RoomId = m.RoomId,
                SenderId = m.SenderUserId?.ToString() ?? m.SenderId ?? "",
                SenderName = m.SenderUser?.DisplayName ?? m.SenderUser?.Username ?? "Unknown",
                Content = m.Content,
                Metadata = m.Metadata,
                CreatedAt = m.CreatedAt
            }).ToList();

            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching DM history for users {User1} and {User2}", userId1, userId2);
            return StatusCode(500, new { error = "Failed to fetch message history." });
        }
    }
}

// DTOs
public class MessageDto
{
    public long Id { get; set; }
    public string? RoomId { get; set; }
    public string SenderId { get; set; } = string.Empty;
    public string SenderName { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? Metadata { get; set; }
    public DateTime CreatedAt { get; set; }
}
