using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for video call operations.
/// </summary>
public interface IVideoCallRepository
{
    /// <summary>
    /// Start a new video call.
    /// </summary>
    Task<VideoCallEntity> StartCallAsync(string channelName, Guid initiatedByUserId, string callType = "video", Guid? groupRoomId = null, string? callName = null);

    /// <summary>
    /// Get call by ID.
    /// </summary>
    Task<VideoCallEntity?> GetByIdAsync(Guid id, bool includeParticipants = false);

    /// <summary>
    /// Get call by channel name.
    /// </summary>
    Task<VideoCallEntity?> GetByChannelNameAsync(string channelName, bool includeParticipants = false);

    /// <summary>
    /// Get active call for a channel (if any).
    /// </summary>
    Task<VideoCallEntity?> GetActiveCallAsync(string channelName);

    /// <summary>
    /// End a call.
    /// </summary>
    Task<VideoCallEntity?> EndCallAsync(Guid callId);

    /// <summary>
    /// Add a participant to a call.
    /// </summary>
    Task<VideoCallParticipantEntity> JoinCallAsync(Guid callId, Guid userId, string role = "participant", string? deviceType = null);

    /// <summary>
    /// Remove a participant from a call.
    /// </summary>
    Task<VideoCallParticipantEntity?> LeaveCallAsync(Guid callId, Guid userId);

    /// <summary>
    /// Get call participants.
    /// </summary>
    Task<List<VideoCallParticipantEntity>> GetParticipantsAsync(Guid callId, bool activeOnly = true);

    /// <summary>
    /// Get call history for a user.
    /// </summary>
    Task<List<VideoCallEntity>> GetUserCallHistoryAsync(Guid userId, int limit = 50, DateTime? before = null);

    /// <summary>
    /// Get active calls.
    /// </summary>
    Task<List<VideoCallEntity>> GetActiveCallsAsync();

    /// <summary>
    /// Update call max participants count.
    /// </summary>
    Task UpdateMaxParticipantsAsync(Guid callId);
}
