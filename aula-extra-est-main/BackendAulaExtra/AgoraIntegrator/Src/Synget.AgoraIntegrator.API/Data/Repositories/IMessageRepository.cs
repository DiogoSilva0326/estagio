using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for message operations.
/// </summary>
public interface IMessageRepository
{
    /// <summary>
    /// Store a new message.
    /// </summary>
    Task<MessageEntity> CreateAsync(MessageEntity message);

    /// <summary>
    /// Get messages for a room, ordered by creation date descending.
    /// </summary>
    Task<List<MessageEntity>> GetByRoomAsync(string roomId, int limit = 50, DateTime? before = null);

    /// <summary>
    /// Get messages between two users (DM history).
    /// </summary>
    Task<List<MessageEntity>> GetDirectMessagesAsync(long userId1, long userId2, int limit = 50, DateTime? before = null);

    /// <summary>
    /// Get message by ID.
    /// </summary>
    Task<MessageEntity?> GetByIdAsync(long id);

    /// <summary>
    /// Get the last message timestamp for a room.
    /// </summary>
    Task<DateTime?> GetLastMessageTimeAsync(string roomId);

    /// <summary>
    /// Get the last message timestamps for multiple rooms.
    /// </summary>
    Task<Dictionary<string, DateTime>> GetLastMessageTimesAsync(IEnumerable<string> roomIds);
}
