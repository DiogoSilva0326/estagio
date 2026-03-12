using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for message operations.
/// </summary>
public class MessageRepository : IMessageRepository
{
    private readonly ChatDbContext _db;

    public MessageRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<MessageEntity> CreateAsync(MessageEntity message)
    {
        message.CreatedAt = DateTime.UtcNow;
        _db.Messages.Add(message);
        await _db.SaveChangesAsync();
        return message;
    }

    public async Task<List<MessageEntity>> GetByRoomAsync(string roomId, int limit = 50, DateTime? before = null)
    {
        var query = _db.Messages
            .Include(m => m.SenderUser)
            .Where(m => m.RoomId == roomId);

        if (before.HasValue)
        {
            query = query.Where(m => m.CreatedAt < before.Value);
        }

        // Get most recent messages first, then reverse for chronological order in UI
        var messages = await query
            .OrderByDescending(m => m.CreatedAt)
            .Take(limit)
            .ToListAsync();

        // Return in chronological order (oldest first)
        messages.Reverse();
        return messages;
    }

    public async Task<List<MessageEntity>> GetDirectMessagesAsync(long userId1, long userId2, int limit = 50, DateTime? before = null)
    {
        var query = _db.Messages
            .Include(m => m.SenderUser)
            .Where(m =>
                (m.SenderUserId == userId1 && m.ReceiverUserId == userId2) ||
                (m.SenderUserId == userId2 && m.ReceiverUserId == userId1));

        if (before.HasValue)
        {
            query = query.Where(m => m.CreatedAt < before.Value);
        }

        var messages = await query
            .OrderByDescending(m => m.CreatedAt)
            .Take(limit)
            .ToListAsync();

        messages.Reverse();
        return messages;
    }

    public async Task<MessageEntity?> GetByIdAsync(long id)
    {
        return await _db.Messages
            .Include(m => m.SenderUser)
            .FirstOrDefaultAsync(m => m.Id == id);
    }

    public async Task<DateTime?> GetLastMessageTimeAsync(string roomId)
    {
        return await _db.Messages
            .Where(m => m.RoomId == roomId)
            .OrderByDescending(m => m.CreatedAt)
            .Select(m => (DateTime?)m.CreatedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<Dictionary<string, DateTime>> GetLastMessageTimesAsync(IEnumerable<string> roomIds)
    {
        var roomIdList = roomIds.ToList();
        
        var lastMessages = await _db.Messages
            .Where(m => m.RoomId != null && roomIdList.Contains(m.RoomId))
            .GroupBy(m => m.RoomId!)
            .Select(g => new { RoomId = g.Key, LastMessageAt = g.Max(m => m.CreatedAt) })
            .ToListAsync();

        return lastMessages.ToDictionary(x => x.RoomId, x => x.LastMessageAt);
    }
}
