using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for user operations.
/// </summary>
public class UserRepository : IUserRepository
{
    private readonly ChatDbContext _db;

    public UserRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<UserEntity> GetOrCreateAsync(string username, string? displayName = null, string? externalId = null)
    {
        var normalizedUsername = username.Trim().ToLowerInvariant();

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Username == normalizedUsername);
        if (user != null)
        {
            // Update display name if provided and different
            if (!string.IsNullOrWhiteSpace(displayName) && user.DisplayName != displayName)
            {
                user.DisplayName = displayName;
                await _db.SaveChangesAsync();
            }
            return user;
        }

        // In this project, users are managed by the main API and already exist in public.users.
        // Creating users here would fail because `email` is required and additional domain fields exist.
        throw new InvalidOperationException($"User '{normalizedUsername}' not found in database.");
    }

    public async Task<UserEntity?> GetByIdAsync(Guid id)
    {
        return await _db.Users.FindAsync(id);
    }

    public async Task<UserEntity?> GetByUsernameAsync(string username)
    {
        var normalized = username.Trim().ToLowerInvariant();
        return await _db.Users.FirstOrDefaultAsync(u => u.Username == normalized);
    }

    public async Task<UserEntity?> GetByExternalIdAsync(string externalId)
    {
        // Confidant schema does not have external_id on public.users.
        return await Task.FromResult<UserEntity?>(null);
    }

    public async Task<UserEntity?> UpdateDisplayNameAsync(Guid id, string displayName)
    {
        var user = await _db.Users.FindAsync(id);
        if (user == null) return null;

        user.DisplayName = displayName;
        await _db.SaveChangesAsync();
        return user;
    }

    public async Task<List<UserEntity>> GetAllAsync(int limit = 100, int offset = 0)
    {
        return await _db.Users
            .OrderBy(u => u.Username)
            .Skip(offset)
            .Take(limit)
            .ToListAsync();
    }

    #region Authentication Methods

    public async Task<UserEntity?> RegisterAsync(string username, string passwordHash, string role, string? displayName = null, string? email = null)
    {
        // Registration is handled by the main BackendAulaExtra API.
        return await Task.FromResult<UserEntity?>(null);
    }

    public async Task<bool> UsernameExistsAsync(string username)
    {
        var normalized = username.Trim().ToLowerInvariant();
        return await _db.Users.AnyAsync(u => u.Username == normalized);
    }

    public async Task UpdateLastLoginAsync(Guid userId)
    {
        var user = await _db.Users.FindAsync(userId);
        if (user != null)
        {
            // Confidant schema does not track last_login_at in users.
            await _db.SaveChangesAsync();
        }
    }

    public async Task<bool> UpdateRoleAsync(Guid userId, string newRole)
    {
        // Role is managed outside of public.users (e.g., via user_role table) in Confidant.
        return await Task.FromResult(false);
    }

    public async Task<bool> DeactivateAsync(Guid userId)
    {
        var user = await _db.Users.FindAsync(userId);
        if (user == null) return false;

        user.Inactive = true;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<List<UserEntity>> GetByRoleAsync(string role, int limit = 100, int offset = 0)
    {
        // Role is not stored on public.users in Confidant.
        return await Task.FromResult(new List<UserEntity>());
    }

    #endregion
}
