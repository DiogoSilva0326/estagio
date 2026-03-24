using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for chat file operations.
/// </summary>
public interface IChatFileRepository
{
    /// <summary>
    /// Create a new file record.
    /// </summary>
    Task<ChatFileEntity> CreateAsync(ChatFileEntity file);

    /// <summary>
    /// Get file by file ID (GUID).
    /// </summary>
    Task<ChatFileEntity?> GetByFileIdAsync(string fileId);

    /// <summary>
    /// Get file by database ID.
    /// </summary>
    Task<ChatFileEntity?> GetByIdAsync(Guid id);

    /// <summary>
    /// Get files uploaded by a user.
    /// </summary>
    Task<List<ChatFileEntity>> GetByUserAsync(Guid userId, int limit = 50);

    /// <summary>
    /// Get files in a room.
    /// </summary>
    Task<List<ChatFileEntity>> GetByRoomAsync(string roomId, int limit = 50);

    /// <summary>
    /// Get files accessible to a user (uploaded by them OR in rooms they are a member of).
    /// For DM rooms (dm_user1_user2), only participants can see the files.
    /// </summary>
    Task<List<ChatFileEntity>> GetAccessibleFilesAsync(string username, int limit = 100);

    /// <summary>
    /// Get files shared in a specific conversation (DM or group).
    /// </summary>
    Task<List<ChatFileEntity>> GetFilesInConversationAsync(string roomId, int limit = 100);

    /// <summary>
    /// Update file (e.g., associate with message).
    /// </summary>
    Task<ChatFileEntity?> UpdateAsync(ChatFileEntity file);

    /// <summary>
    /// Soft delete a file.
    /// </summary>
    Task<bool> DeleteAsync(string fileId);

    /// <summary>
    /// Check if a user has access to a file (uploaded by them OR participant in the room).
    /// </summary>
    Task<bool> UserHasAccessAsync(string username, string fileId);
}
