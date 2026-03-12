using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for user operations.
/// </summary>
public interface IUserRepository
{
    /// <summary>
    /// Get or create a user by username. If not exists, creates with given display name.
    /// </summary>
    Task<UserEntity> GetOrCreateAsync(string username, string? displayName = null, string? externalId = null);

    /// <summary>
    /// Get user by ID.
    /// </summary>
    Task<UserEntity?> GetByIdAsync(long id);

    /// <summary>
    /// Get user by username.
    /// </summary>
    Task<UserEntity?> GetByUsernameAsync(string username);

    /// <summary>
    /// Get user by external ID.
    /// </summary>
    Task<UserEntity?> GetByExternalIdAsync(string externalId);

    /// <summary>
    /// Update user display name.
    /// </summary>
    Task<UserEntity?> UpdateDisplayNameAsync(long id, string displayName);

    /// <summary>
    /// Get all users (for admin/debug).
    /// </summary>
    Task<List<UserEntity>> GetAllAsync(int limit = 100, int offset = 0);

    #region Authentication Methods

    /// <summary>
    /// Register a new user with password.
    /// </summary>
    Task<UserEntity?> RegisterAsync(string username, string passwordHash, string role, string? displayName = null, string? email = null);

    /// <summary>
    /// Check if username is already taken.
    /// </summary>
    Task<bool> UsernameExistsAsync(string username);

    /// <summary>
    /// Update user's last login timestamp.
    /// </summary>
    Task UpdateLastLoginAsync(long userId);

    /// <summary>
    /// Update user's role (admin only).
    /// </summary>
    Task<bool> UpdateRoleAsync(long userId, string newRole);

    /// <summary>
    /// Deactivate a user account.
    /// </summary>
    Task<bool> DeactivateAsync(long userId);

    /// <summary>
    /// Get users by role.
    /// </summary>
    Task<List<UserEntity>> GetByRoleAsync(string role, int limit = 100, int offset = 0);

    #endregion
}
