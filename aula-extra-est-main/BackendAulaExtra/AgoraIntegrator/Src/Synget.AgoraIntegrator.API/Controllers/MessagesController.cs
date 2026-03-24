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
                RoomId = roomId,
                SenderId = m.SenderUser?.Username ?? m.SenderUserId.ToString(),
                SenderName = m.SenderUser?.DisplayName ?? m.SenderUser?.Username ?? "Unknown",
                Content = m.Content ?? string.Empty,
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
    [HttpGet("dm/{userId1}/{userId2}")]
    public async Task<IActionResult> GetDmHistory(
        string userId1,
        string userId2,
        [FromQuery] int limit = 50,
        [FromQuery] DateTime? before = null)
    {
        try
        {
            var resolved1 = await ResolveUserIdAsync(userId1);
            var resolved2 = await ResolveUserIdAsync(userId2);

            if (!resolved1.HasValue || !resolved2.HasValue)
            {
                return Ok(new List<MessageDto>());
            }

            var messages = await _messageRepo.GetDirectMessagesAsync(resolved1.Value, resolved2.Value, limit, before);

            var result = messages.Select(m => new MessageDto
            {
                Id = m.Id,
                RoomId = null,
                SenderId = m.SenderUser?.Username ?? m.SenderUserId.ToString(),
                SenderName = m.SenderUser?.DisplayName ?? m.SenderUser?.Username ?? "Unknown",
                Content = m.Content ?? string.Empty,
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

    private async Task<Guid?> ResolveUserIdAsync(string userIdOrUsername)
    {
        if (Guid.TryParse(userIdOrUsername, out var guid))
        {
            return guid;
        }

        var user = await _userRepo.GetByUsernameAsync(userIdOrUsername);
        return user?.Id;
    }
}

// DTOs
public class MessageDto
{
    public Guid Id { get; set; }
    public string? RoomId { get; set; }
    public string SenderId { get; set; } = string.Empty;
    public string SenderName { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? Metadata { get; set; }
    public DateTime CreatedAt { get; set; }
}
