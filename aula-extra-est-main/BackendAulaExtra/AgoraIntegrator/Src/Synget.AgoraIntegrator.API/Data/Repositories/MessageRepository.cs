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
        if (message.CreatedAt == default)
        {
            message.CreatedAt = DateTime.UtcNow;
        }
        _db.Messages.Add(message);
        await _db.SaveChangesAsync();
        return message;
    }

    public async Task<List<MessageEntity>> GetByRoomAsync(string roomId, int limit = 50, DateTime? before = null)
    {
        if (roomId.StartsWith("dm_", StringComparison.OrdinalIgnoreCase))
        {
            var (u1, u2) = ParseDmRoom(roomId);
            var users = await _db.Users
                .Where(u => u.Username == u1 || u.Username == u2)
                .ToListAsync();

            var user1 = users.FirstOrDefault(u => u.Username == u1);
            var user2 = users.FirstOrDefault(u => u.Username == u2);
            if (user1 == null || user2 == null)
            {
                return new List<MessageEntity>();
            }

            return await GetDirectMessagesAsync(user1.Id, user2.Id, limit, before);
        }

        if (roomId.StartsWith("group_", StringComparison.OrdinalIgnoreCase))
        {
            var groupCode = roomId.Substring("group_".Length);
            var group = await _db.GroupRooms.FirstOrDefaultAsync(g => g.RoomCode == groupCode);
            if (group == null)
            {
                return new List<MessageEntity>();
            }

            var query = _db.Messages
                .Include(m => m.SenderUser)
                .Where(m => m.GroupRoomId == group.Id);

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

        return new List<MessageEntity>();
    }

    public async Task<List<MessageEntity>> GetDirectMessagesAsync(Guid userId1, Guid userId2, int limit = 50, DateTime? before = null)
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

    public async Task<MessageEntity?> GetByIdAsync(Guid id)
    {
        return await _db.Messages
            .Include(m => m.SenderUser)
            .FirstOrDefaultAsync(m => m.Id == id);
    }

    public async Task<DateTime?> GetLastMessageTimeAsync(string roomId)
    {
        var messages = await GetByRoomAsync(roomId, limit: 1);
        return messages.LastOrDefault()?.CreatedAt;
    }

    public async Task<Dictionary<string, DateTime>> GetLastMessageTimesAsync(IEnumerable<string> roomIds)
    {
        var result = new Dictionary<string, DateTime>();
        foreach (var roomId in roomIds)
        {
            var last = await GetLastMessageTimeAsync(roomId);
            if (last.HasValue)
            {
                result[roomId] = last.Value;
            }
        }
        return result;
    }

    public async Task<List<Guid>> MarkDirectMessagesReadAsync(Guid readerUserId, Guid otherUserId, DateTime readAtUtc)
    {
        var unread = await _db.Messages
            .Where(m =>
                m.SenderUserId == otherUserId &&
                m.ReceiverUserId == readerUserId &&
                !m.IsRead)
            .ToListAsync();

        if (unread.Count == 0)
        {
            return new List<Guid>();
        }

        foreach (var message in unread)
        {
            message.IsRead = true;
            message.ReadAt = readAtUtc;
        }

        await _db.SaveChangesAsync();
        return unread.Select(m => m.Id).ToList();
    }

    private static (string user1, string user2) ParseDmRoom(string roomId)
    {
        // Expected format: dm_user1_user2 where usernames are already normalized (lowercase)
        var parts = roomId.Split('_', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length < 3)
        {
            return (string.Empty, string.Empty);
        }

        return (parts[1].Trim().ToLowerInvariant(), parts[2].Trim().ToLowerInvariant());
    }
}
