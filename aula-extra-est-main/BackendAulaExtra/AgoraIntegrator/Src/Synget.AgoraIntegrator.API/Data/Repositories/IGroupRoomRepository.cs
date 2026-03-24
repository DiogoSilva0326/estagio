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
    Task<GroupRoomEntity> CreateAsync(string name, Guid createdByUserId, string roomType = "group", string? description = null);

    /// <summary>
    /// Get room by ID.
    /// </summary>
    Task<GroupRoomEntity?> GetByIdAsync(Guid id, bool includeMembers = false);

    /// <summary>
    /// Get room by room code.
    /// </summary>
    Task<GroupRoomEntity?> GetByRoomCodeAsync(string roomCode, bool includeMembers = false);

    /// <summary>
    /// Get or create a direct message room between two users.
    /// </summary>
    Task<GroupRoomEntity> GetOrCreateDirectRoomAsync(Guid userId1, Guid userId2);

    /// <summary>
    /// Get all rooms for a user.
    /// </summary>
    Task<List<GroupRoomEntity>> GetByUserAsync(Guid userId, bool includeInactive = false);

    /// <summary>
    /// Add a member to a room.
    /// </summary>
    Task<GroupRoomMemberEntity> AddMemberAsync(Guid roomId, Guid userId, string role = "member");

    /// <summary>
    /// Remove a member from a room.
    /// </summary>
    Task<bool> RemoveMemberAsync(Guid roomId, Guid userId);

    /// <summary>
    /// Update member role.
    /// </summary>
    Task<GroupRoomMemberEntity?> UpdateMemberRoleAsync(Guid roomId, Guid userId, string role);

    /// <summary>
    /// Get room members.
    /// </summary>
    Task<List<GroupRoomMemberEntity>> GetMembersAsync(Guid roomId);

    /// <summary>
    /// Update room details.
    /// </summary>
    Task<GroupRoomEntity?> UpdateAsync(Guid roomId, string? name = null, string? description = null, string? avatarUrl = null);

    /// <summary>
    /// Deactivate a room.
    /// </summary>
    Task<bool> DeactivateAsync(Guid roomId);
}
