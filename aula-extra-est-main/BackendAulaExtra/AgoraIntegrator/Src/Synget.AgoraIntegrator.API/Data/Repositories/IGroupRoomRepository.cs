using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for group room operations.
/// </summary>
public interface IGroupRoomRepository
{
    /// <summary>
    /// Create a new group room.
    /// </summary>
    Task<GroupRoomEntity> CreateAsync(string name, long createdByUserId, string roomType = "group", string? description = null);

    /// <summary>
    /// Get room by ID.
    /// </summary>
    Task<GroupRoomEntity?> GetByIdAsync(long id, bool includeMembers = false);

    /// <summary>
    /// Get room by room code.
    /// </summary>
    Task<GroupRoomEntity?> GetByRoomCodeAsync(string roomCode, bool includeMembers = false);

    /// <summary>
    /// Get or create a direct message room between two users.
    /// </summary>
    Task<GroupRoomEntity> GetOrCreateDirectRoomAsync(long userId1, long userId2);

    /// <summary>
    /// Get all rooms for a user.
    /// </summary>
    Task<List<GroupRoomEntity>> GetByUserAsync(long userId, bool includeInactive = false);

    /// <summary>
    /// Add a member to a room.
    /// </summary>
    Task<GroupRoomMemberEntity> AddMemberAsync(long roomId, long userId, string role = "member");

    /// <summary>
    /// Remove a member from a room.
    /// </summary>
    Task<bool> RemoveMemberAsync(long roomId, long userId);

    /// <summary>
    /// Update member role.
    /// </summary>
    Task<GroupRoomMemberEntity?> UpdateMemberRoleAsync(long roomId, long userId, string role);

    /// <summary>
    /// Get room members.
    /// </summary>
    Task<List<GroupRoomMemberEntity>> GetMembersAsync(long roomId);

    /// <summary>
    /// Update room details.
    /// </summary>
    Task<GroupRoomEntity?> UpdateAsync(long roomId, string? name = null, string? description = null, string? avatarUrl = null);

    /// <summary>
    /// Deactivate a room.
    /// </summary>
    Task<bool> DeactivateAsync(long roomId);
}
