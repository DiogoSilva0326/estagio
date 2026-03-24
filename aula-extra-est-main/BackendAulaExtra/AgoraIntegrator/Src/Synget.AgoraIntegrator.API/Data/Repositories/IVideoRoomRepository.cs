using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for video room operations.
/// </summary>
public interface IVideoRoomRepository
{
    /// <summary>
    /// Create a new video room.
    /// </summary>
    Task<VideoRoomEntity> CreateAsync(string channelName, Guid hostUserId, string hostUsername, string? title = null, int maxParticipants = 50);

    /// <summary>
    /// Get video room by channel name.
    /// </summary>
    Task<VideoRoomEntity?> GetByChannelNameAsync(string channelName);

    /// <summary>
    /// Get video room by ID.
    /// </summary>
    Task<VideoRoomEntity?> GetByIdAsync(Guid id);

    /// <summary>
    /// Get all active video rooms.
    /// </summary>
    Task<List<VideoRoomEntity>> GetActiveRoomsAsync();

    /// <summary>
    /// Get all active video rooms where host has joined (available for students).
    /// </summary>
    Task<List<VideoRoomEntity>> GetAvailableRoomsForStudentsAsync();

    /// <summary>
    /// Set the host as joined in the room.
    /// </summary>
    Task<bool> SetHostJoinedAsync(string channelName, bool joined = true);

    /// <summary>
    /// Check if host has joined the room.
    /// </summary>
    Task<bool> IsHostJoinedAsync(string channelName);

    /// <summary>
    /// End a video room and calculate duration.
    /// </summary>
    Task<bool> EndRoomAsync(string channelName);

    /// <summary>
    /// Add a participant to a video room.
    /// </summary>
    Task<VideoRoomParticipantEntity?> AddParticipantAsync(Guid roomId, Guid userId, string role = "participant");

    /// <summary>
    /// Remove a participant from a video room.
    /// </summary>
    Task<bool> RemoveParticipantAsync(Guid roomId, Guid userId);

    /// <summary>
    /// Get participant count for a room.
    /// </summary>
    Task<int> GetParticipantCountAsync(Guid roomId);

    /// <summary>
    /// Check if a channel name exists and is active.
    /// </summary>
    Task<bool> IsActiveRoomAsync(string channelName);

    /// <summary>
    /// Get all participants for a room.
    /// </summary>
    Task<List<VideoRoomParticipantEntity>> GetParticipantsAsync(Guid roomId);
}
