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

        // Create new user
        user = new UserEntity
        {
            Username = normalizedUsername,
            DisplayName = displayName ?? username,
            ExternalId = externalId,
            CreatedAt = DateTime.UtcNow
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return user;
    }

    public async Task<UserEntity?> GetByIdAsync(long id)
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
        return await _db.Users.FirstOrDefaultAsync(u => u.ExternalId == externalId);
    }

    public async Task<UserEntity?> UpdateDisplayNameAsync(long id, string displayName)
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
        var normalizedUsername = username.Trim().ToLowerInvariant();

        // Check if username already exists
        if (await UsernameExistsAsync(normalizedUsername))
        {
            return null;
        }

        // Validate role
        if (role != "admin" && role != "professor" && role != "aluno")
        {
            role = "aluno";
        }

        var user = new UserEntity
        {
            Username = normalizedUsername,
            DisplayName = displayName ?? username,
            Email = email,
            PasswordHash = passwordHash,
            Role = role,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return user;
    }

    public async Task<bool> UsernameExistsAsync(string username)
    {
        var normalized = username.Trim().ToLowerInvariant();
        return await _db.Users.AnyAsync(u => u.Username == normalized);
    }

    public async Task UpdateLastLoginAsync(long userId)
    {
        var user = await _db.Users.FindAsync(userId);
        if (user != null)
        {
            user.LastLoginAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
        }
    }

    public async Task<bool> UpdateRoleAsync(long userId, string newRole)
    {
        if (newRole != "admin" && newRole != "professor" && newRole != "aluno")
        {
            return false;
        }

        var user = await _db.Users.FindAsync(userId);
        if (user == null) return false;

        user.Role = newRole;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeactivateAsync(long userId)
    {
        var user = await _db.Users.FindAsync(userId);
        if (user == null) return false;

        user.IsActive = false;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<List<UserEntity>> GetByRoleAsync(string role, int limit = 100, int offset = 0)
    {
        return await _db.Users
            .Where(u => u.Role == role && u.IsActive)
            .OrderBy(u => u.Username)
            .Skip(offset)
            .Take(limit)
            .ToListAsync();
    }

    #endregion
}
