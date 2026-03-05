using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for session operations.
/// </summary>
public class SessionRepository : ISessionRepository
{
    private readonly ChatDbContext _db;

    public SessionRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<SessionEntity> CreateAsync(long userId, string token, DateTime expiresAt, string? ipAddress = null, string? userAgent = null)
    {
        var session = new SessionEntity
        {
            UserId = userId,
            Token = token,
            ExpiresAt = expiresAt,
            IpAddress = ipAddress,
            UserAgent = userAgent,
            CreatedAt = DateTime.UtcNow
        };

        _db.Sessions.Add(session);
        await _db.SaveChangesAsync();
        return session;
    }

    public async Task<SessionEntity?> GetByTokenAsync(string token)
    {
        return await _db.Sessions
            .Include(s => s.User)
            .FirstOrDefaultAsync(s => s.Token == token && s.ExpiresAt > DateTime.UtcNow);
    }

    public async Task<bool> DeleteByTokenAsync(string token)
    {
        var session = await _db.Sessions.FirstOrDefaultAsync(s => s.Token == token);
        if (session == null) return false;

        _db.Sessions.Remove(session);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<int> DeleteAllByUserAsync(long userId)
    {
        var sessions = await _db.Sessions.Where(s => s.UserId == userId).ToListAsync();
        _db.Sessions.RemoveRange(sessions);
        await _db.SaveChangesAsync();
        return sessions.Count;
    }

    public async Task<int> DeleteExpiredAsync()
    {
        var expired = await _db.Sessions.Where(s => s.ExpiresAt <= DateTime.UtcNow).ToListAsync();
        _db.Sessions.RemoveRange(expired);
        await _db.SaveChangesAsync();
        return expired.Count;
    }

    public async Task<bool> IsValidTokenAsync(string token)
    {
        return await _db.Sessions.AnyAsync(s => s.Token == token && s.ExpiresAt > DateTime.UtcNow);
    }
}
