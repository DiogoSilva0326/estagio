using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for video room operations.
/// </summary>
public class VideoRoomRepository : IVideoRoomRepository
{
    private readonly ChatDbContext _db;

    public VideoRoomRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<VideoRoomEntity> CreateAsync(string channelName, Guid hostUserId, string hostUsername, string? title = null, int maxParticipants = 50)
    {
        var room = new VideoRoomEntity
        {
            ChannelName = channelName,
            HostUserId = hostUserId,
            HostUsername = hostUsername,
            Title = title,
            MaxParticipants = maxParticipants,
            IsActive = true,
            HostJoined = false, // Host hasn't joined yet, just created the room
            StartedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow,
            TotalDurationSeconds = 0
        };

        _db.VideoRooms.Add(room);
        await _db.SaveChangesAsync();
        return room;
    }

    public async Task<VideoRoomEntity?> GetByChannelNameAsync(string channelName)
    {
        return await _db.VideoRooms
            .Include(r => r.Host)
            .Include(r => r.Participants.Where(p => p.LeftAt == null))
                .ThenInclude(p => p.User)
            .FirstOrDefaultAsync(r => r.ChannelName == channelName);
    }

    public async Task<VideoRoomEntity?> GetByIdAsync(Guid id)
    {
        return await _db.VideoRooms
            .Include(r => r.Host)
            .Include(r => r.Participants.Where(p => p.LeftAt == null))
                .ThenInclude(p => p.User)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<List<VideoRoomEntity>> GetActiveRoomsAsync()
    {
        return await _db.VideoRooms
            .Include(r => r.Host)
            .Include(r => r.Participants.Where(p => p.LeftAt == null))
            .Where(r => r.IsActive)
            .OrderByDescending(r => r.StartedAt)
            .ToListAsync();
    }

    public async Task<List<VideoRoomEntity>> GetAvailableRoomsForStudentsAsync()
    {
        // Only rooms where host has already joined
        return await _db.VideoRooms
            .Include(r => r.Host)
            .Include(r => r.Participants.Where(p => p.LeftAt == null))
            .Where(r => r.IsActive && r.HostJoined)
            .OrderByDescending(r => r.StartedAt)
            .ToListAsync();
    }

    public async Task<bool> SetHostJoinedAsync(string channelName, bool joined = true)
    {
        var room = await _db.VideoRooms.FirstOrDefaultAsync(r => r.ChannelName == channelName);
        if (room == null) return false;

        room.HostJoined = joined;
        
        // If host is joining, update the started_at to now (actual call start)
        if (joined && room.StartedAt == room.CreatedAt)
        {
            room.StartedAt = DateTime.UtcNow;
        }
        
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> IsHostJoinedAsync(string channelName)
    {
        var room = await _db.VideoRooms.FirstOrDefaultAsync(r => r.ChannelName == channelName && r.IsActive);
        return room?.HostJoined ?? false;
    }

    public async Task<bool> EndRoomAsync(string channelName)
    {
        var room = await _db.VideoRooms.FirstOrDefaultAsync(r => r.ChannelName == channelName);
        if (room == null) return false;

        room.IsActive = false;
        room.HostJoined = false;
        room.EndedAt = DateTime.UtcNow;
        
        // Calculate total duration in seconds
        if (room.StartedAt != default)
        {
            room.TotalDurationSeconds = (int)(room.EndedAt.Value - room.StartedAt).TotalSeconds;
        }

        // Mark all participants as left
        var participants = await _db.VideoRoomParticipants
            .Where(p => p.VideoRoomId == room.Id && p.LeftAt == null)
            .ToListAsync();

        foreach (var p in participants)
        {
            p.LeftAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<VideoRoomParticipantEntity?> AddParticipantAsync(Guid roomId, Guid userId, string role = "participant")
    {
        // Check if already a participant
        var existing = await _db.VideoRoomParticipants
            .FirstOrDefaultAsync(p => p.VideoRoomId == roomId && p.UserId == userId && p.LeftAt == null);

        if (existing != null)
        {
            return existing;
        }

        var participant = new VideoRoomParticipantEntity
        {
            VideoRoomId = roomId,
            UserId = userId,
            Role = role,
            JoinedAt = DateTime.UtcNow
        };

        _db.VideoRoomParticipants.Add(participant);
        await _db.SaveChangesAsync();
        return participant;
    }

    public async Task<bool> RemoveParticipantAsync(Guid roomId, Guid userId)
    {
        var participant = await _db.VideoRoomParticipants
            .FirstOrDefaultAsync(p => p.VideoRoomId == roomId && p.UserId == userId && p.LeftAt == null);

        if (participant == null) return false;

        participant.LeftAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<int> GetParticipantCountAsync(Guid roomId)
    {
        return await _db.VideoRoomParticipants
            .CountAsync(p => p.VideoRoomId == roomId && p.LeftAt == null);
    }

    public async Task<bool> IsActiveRoomAsync(string channelName)
    {
        return await _db.VideoRooms.AnyAsync(r => r.ChannelName == channelName && r.IsActive);
    }

    public async Task<List<VideoRoomParticipantEntity>> GetParticipantsAsync(Guid roomId)
    {
        return await _db.VideoRoomParticipants
            .Include(p => p.User)
            .Where(p => p.VideoRoomId == roomId)
            .OrderBy(p => p.JoinedAt)
            .ToListAsync();
    }
}
