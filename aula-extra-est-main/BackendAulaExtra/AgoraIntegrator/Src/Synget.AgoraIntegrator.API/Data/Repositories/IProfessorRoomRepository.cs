using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Interface for professor room repository operations.
/// </summary>
public interface IProfessorRoomRepository
{
    /// <summary>
    /// Creates a new professor room.
    /// </summary>
    Task<ProfessorRoomEntity> CreateAsync(Guid professorId, string professorName, string? roomName = null);

    /// <summary>
    /// Gets a professor room by ID.
    /// </summary>
    Task<ProfessorRoomEntity?> GetByIdAsync(Guid id);

    /// <summary>
    /// Gets a professor room by professor ID.
    /// </summary>
    Task<ProfessorRoomEntity?> GetByProfessorIdAsync(Guid professorId);

    /// <summary>
    /// Gets a professor room by room name.
    /// </summary>
    Task<ProfessorRoomEntity?> GetByRoomNameAsync(string roomName);

    /// <summary>
    /// Gets a professor room by username.
    /// </summary>
    Task<ProfessorRoomEntity?> GetByUsernameAsync(string username);

    /// <summary>
    /// Gets all professor rooms.
    /// </summary>
    Task<List<ProfessorRoomEntity>> GetAllAsync(bool activeOnly = true);

    /// <summary>
    /// Updates the room name for a professor.
    /// Returns null if the new name is already taken by another professor.
    /// </summary>
    Task<ProfessorRoomEntity?> UpdateRoomNameAsync(Guid professorId, string newRoomName);

    /// <summary>
    /// Updates the room details.
    /// </summary>
    Task<ProfessorRoomEntity?> UpdateAsync(Guid id, string? roomName = null, string? description = null, bool? isActive = null);

    /// <summary>
    /// Checks if a room name is available (not already taken).
    /// </summary>
    Task<bool> IsRoomNameAvailableAsync(string roomName, Guid? excludeProfessorId = null);

    /// <summary>
    /// Deletes a professor room.
    /// </summary>
    Task<bool> DeleteAsync(Guid id);
}
