using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for video call operations.
/// </summary>
public class VideoCallRepository : IVideoCallRepository
{
    private readonly ChatDbContext _db;

    public VideoCallRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<VideoCallEntity> StartCallAsync(string channelName, Guid initiatedByUserId, string callType = "video", Guid? groupRoomId = null, string? callName = null)
    {
        var call = new VideoCallEntity
        {
            ChannelName = channelName,
            CallName = callName,
            CallType = callType,
            GroupRoomId = groupRoomId,
            InitiatedByUserId = initiatedByUserId,
            Status = CallStatus.Active,
            StartedAt = DateTime.UtcNow,
            MaxParticipants = 1
        };

        _db.VideoCalls.Add(call);
        await _db.SaveChangesAsync();

        // Add initiator as first participant (host)
        await JoinCallAsync(call.Id, initiatedByUserId, ParticipantRole.Host);

        return call;
    }

    public async Task<VideoCallEntity?> GetByIdAsync(Guid id, bool includeParticipants = false)
    {
        var query = _db.VideoCalls.AsQueryable();

        if (includeParticipants)
        {
            query = query.Include(c => c.Participants).ThenInclude(p => p.User);
        }

        return await query.FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<VideoCallEntity?> GetByChannelNameAsync(string channelName, bool includeParticipants = false)
    {
        var query = _db.VideoCalls.AsQueryable();

        if (includeParticipants)
        {
            query = query.Include(c => c.Participants).ThenInclude(p => p.User);
        }

        return await query
            .OrderByDescending(c => c.StartedAt)
            .FirstOrDefaultAsync(c => c.ChannelName == channelName);
    }

    public async Task<VideoCallEntity?> GetActiveCallAsync(string channelName)
    {
        return await _db.VideoCalls
            .Include(c => c.Participants.Where(p => p.LeftAt == null))
            .ThenInclude(p => p.User)
            .FirstOrDefaultAsync(c => c.ChannelName == channelName && c.Status == CallStatus.Active);
    }

    public async Task<VideoCallEntity?> EndCallAsync(Guid callId)
    {
        var call = await _db.VideoCalls
            .Include(c => c.Participants)
            .FirstOrDefaultAsync(c => c.Id == callId);

        if (call == null) return null;

        call.Status = CallStatus.Ended;
        call.EndedAt = DateTime.UtcNow;
        call.DurationSeconds = (int)(call.EndedAt.Value - call.StartedAt).TotalSeconds;

        // End all active participations
        foreach (var participant in call.Participants.Where(p => p.LeftAt == null))
        {
            participant.LeftAt = DateTime.UtcNow;
            participant.DurationSeconds = (int)(participant.LeftAt.Value - participant.JoinedAt).TotalSeconds;
        }

        await _db.SaveChangesAsync();
        return call;
    }

    public async Task<VideoCallParticipantEntity> JoinCallAsync(Guid callId, Guid userId, string role = "participant", string? deviceType = null)
    {
        // Check if user already has an active participation
        var existing = await _db.VideoCallParticipants
            .FirstOrDefaultAsync(p => p.CallId == callId && p.UserId == userId && p.LeftAt == null);

        if (existing != null)
        {
            return existing;
        }

        var participant = new VideoCallParticipantEntity
        {
            CallId = callId,
            UserId = userId,
            Role = role,
            DeviceType = deviceType,
            JoinedAt = DateTime.UtcNow,
            HadVideo = true,
            HadAudio = true
        };

        _db.VideoCallParticipants.Add(participant);
        await _db.SaveChangesAsync();

        // Update max participants
        await UpdateMaxParticipantsAsync(callId);

        return participant;
    }

    public async Task<VideoCallParticipantEntity?> LeaveCallAsync(Guid callId, Guid userId)
    {
        var participant = await _db.VideoCallParticipants
            .FirstOrDefaultAsync(p => p.CallId == callId && p.UserId == userId && p.LeftAt == null);

        if (participant == null) return null;

        participant.LeftAt = DateTime.UtcNow;
        participant.DurationSeconds = (int)(participant.LeftAt.Value - participant.JoinedAt).TotalSeconds;

        await _db.SaveChangesAsync();

        // Check if all participants left - if so, end the call
        var activeParticipants = await _db.VideoCallParticipants
            .CountAsync(p => p.CallId == callId && p.LeftAt == null);

        if (activeParticipants == 0)
        {
            await EndCallAsync(callId);
        }

        return participant;
    }

    public async Task<List<VideoCallParticipantEntity>> GetParticipantsAsync(Guid callId, bool activeOnly = true)
    {
        var query = _db.VideoCallParticipants
            .Include(p => p.User)
            .Where(p => p.CallId == callId);

        if (activeOnly)
        {
            query = query.Where(p => p.LeftAt == null);
        }

        return await query.OrderBy(p => p.JoinedAt).ToListAsync();
    }

    public async Task<List<VideoCallEntity>> GetUserCallHistoryAsync(Guid userId, int limit = 50, DateTime? before = null)
    {
        var query = _db.VideoCallParticipants
            .Include(p => p.Call)
            .ThenInclude(c => c!.InitiatedByUser)
            .Where(p => p.UserId == userId);

        if (before.HasValue)
        {
            query = query.Where(p => p.JoinedAt < before.Value);
        }

        var participations = await query
            .OrderByDescending(p => p.JoinedAt)
            .Take(limit)
            .ToListAsync();

        return participations.Select(p => p.Call!).Distinct().ToList();
    }

    public async Task<List<VideoCallEntity>> GetActiveCallsAsync()
    {
        return await _db.VideoCalls
            .Include(c => c.Participants.Where(p => p.LeftAt == null))
            .ThenInclude(p => p.User)
            .Include(c => c.InitiatedByUser)
            .Where(c => c.Status == CallStatus.Active)
            .OrderByDescending(c => c.StartedAt)
            .ToListAsync();
    }

    public async Task UpdateMaxParticipantsAsync(Guid callId)
    {
        var call = await _db.VideoCalls.FindAsync(callId);
        if (call == null) return;

        var currentCount = await _db.VideoCallParticipants
            .CountAsync(p => p.CallId == callId && p.LeftAt == null);

        if (currentCount > call.MaxParticipants)
        {
            call.MaxParticipants = currentCount;
            await _db.SaveChangesAsync();
        }
    }
}
