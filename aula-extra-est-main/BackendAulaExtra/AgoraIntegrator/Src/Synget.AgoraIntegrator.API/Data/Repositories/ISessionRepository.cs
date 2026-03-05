using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for session operations.
/// </summary>
public interface ISessionRepository
{
    /// <summary>
    /// Create a new session for a user.
    /// </summary>
    Task<SessionEntity> CreateAsync(long userId, string token, DateTime expiresAt, string? ipAddress = null, string? userAgent = null);

    /// <summary>
    /// Get session by token.
    /// </summary>
    Task<SessionEntity?> GetByTokenAsync(string token);

    /// <summary>
    /// Delete a session by token.
    /// </summary>
    Task<bool> DeleteByTokenAsync(string token);

    /// <summary>
    /// Delete all sessions for a user.
    /// </summary>
    Task<int> DeleteAllByUserAsync(long userId);

    /// <summary>
    /// Delete expired sessions.
    /// </summary>
    Task<int> DeleteExpiredAsync();

    /// <summary>
    /// Check if a token is valid (exists and not expired).
    /// </summary>
    Task<bool> IsValidTokenAsync(string token);
}
