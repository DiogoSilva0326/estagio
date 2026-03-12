using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for group room operations.
/// </summary>
public class GroupRoomRepository : IGroupRoomRepository
{
    private readonly ChatDbContext _db;

    public GroupRoomRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<GroupRoomEntity> CreateAsync(string name, long createdByUserId, string roomType = "group", string? description = null)
    {
        var room = new GroupRoomEntity
        {
            RoomCode = Guid.NewGuid().ToString("N"),
            Name = name,
            Description = description,
            RoomType = roomType,
            CreatedByUserId = createdByUserId,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _db.GroupRooms.Add(room);
        await _db.SaveChangesAsync();

        // Add creator as owner
        await AddMemberAsync(room.Id, createdByUserId, MemberRole.Owner);

        return room;
    }

    public async Task<GroupRoomEntity?> GetByIdAsync(long id, bool includeMembers = false)
    {
        var query = _db.GroupRooms.AsQueryable();

        if (includeMembers)
        {
            query = query.Include(r => r.Members).ThenInclude(m => m.User);
        }

        return await query.FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<GroupRoomEntity?> GetByRoomCodeAsync(string roomCode, bool includeMembers = false)
    {
        var query = _db.GroupRooms.AsQueryable();

        if (includeMembers)
        {
            query = query.Include(r => r.Members).ThenInclude(m => m.User);
        }

        return await query.FirstOrDefaultAsync(r => r.RoomCode == roomCode);
    }

    public async Task<GroupRoomEntity> GetOrCreateDirectRoomAsync(long userId1, long userId2)
    {
        // Ensure consistent ordering
        var (user1, user2) = userId1 < userId2 ? (userId1, userId2) : (userId2, userId1);

        // Look for existing direct room with these two users
        var existingRoom = await _db.GroupRooms
            .Include(r => r.Members)
            .Where(r => r.RoomType == RoomType.Direct && r.IsActive)
            .Where(r => r.Members.Count == 2)
            .Where(r => r.Members.Any(m => m.UserId == user1) && r.Members.Any(m => m.UserId == user2))
            .FirstOrDefaultAsync();

        if (existingRoom != null)
        {
            return existingRoom;
        }

        // Create new direct room
        var room = new GroupRoomEntity
        {
            RoomCode = $"dm_{user1}_{user2}_{Guid.NewGuid().ToString("N")[..8]}",
            Name = "Direct Message",
            RoomType = RoomType.Direct,
            CreatedByUserId = user1,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _db.GroupRooms.Add(room);
        await _db.SaveChangesAsync();

        // Add both users as members
        await AddMemberAsync(room.Id, user1, MemberRole.Member);
        await AddMemberAsync(room.Id, user2, MemberRole.Member);

        return room;
    }

    public async Task<List<GroupRoomEntity>> GetByUserAsync(long userId, bool includeInactive = false)
    {
        var query = _db.GroupRooms
            .Include(r => r.Members.Where(m => m.Status == MemberStatus.Active))
            .ThenInclude(m => m.User)
            .Where(r => r.Members.Any(m => m.UserId == userId && m.Status == MemberStatus.Active));

        if (!includeInactive)
        {
            query = query.Where(r => r.IsActive);
        }

        return await query.OrderByDescending(r => r.UpdatedAt).ToListAsync();
    }

    public async Task<GroupRoomMemberEntity> AddMemberAsync(long roomId, long userId, string role = "member")
    {
        var existing = await _db.GroupRoomMembers
            .FirstOrDefaultAsync(m => m.RoomId == roomId && m.UserId == userId);

        if (existing != null)
        {
            if (existing.Status != MemberStatus.Active)
            {
                existing.Status = MemberStatus.Active;
                existing.JoinedAt = DateTime.UtcNow;
                existing.LeftAt = null;
                await _db.SaveChangesAsync();
            }
            return existing;
        }

        var member = new GroupRoomMemberEntity
        {
            RoomId = roomId,
            UserId = userId,
            Role = role,
            Status = MemberStatus.Active,
            JoinedAt = DateTime.UtcNow
        };

        _db.GroupRoomMembers.Add(member);
        await _db.SaveChangesAsync();
        return member;
    }

    public async Task<bool> RemoveMemberAsync(long roomId, long userId)
    {
        var member = await _db.GroupRoomMembers
            .FirstOrDefaultAsync(m => m.RoomId == roomId && m.UserId == userId);

        if (member == null) return false;

        member.Status = MemberStatus.Left;
        member.LeftAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<GroupRoomMemberEntity?> UpdateMemberRoleAsync(long roomId, long userId, string role)
    {
        var member = await _db.GroupRoomMembers
            .FirstOrDefaultAsync(m => m.RoomId == roomId && m.UserId == userId);

        if (member == null) return null;

        member.Role = role;
        await _db.SaveChangesAsync();
        return member;
    }

    public async Task<List<GroupRoomMemberEntity>> GetMembersAsync(long roomId)
    {
        return await _db.GroupRoomMembers
            .Include(m => m.User)
            .Where(m => m.RoomId == roomId && m.Status == MemberStatus.Active)
            .OrderBy(m => m.JoinedAt)
            .ToListAsync();
    }

    public async Task<GroupRoomEntity?> UpdateAsync(long roomId, string? name = null, string? description = null, string? avatarUrl = null)
    {
        var room = await _db.GroupRooms.FindAsync(roomId);
        if (room == null) return null;

        if (name != null) room.Name = name;
        if (description != null) room.Description = description;
        if (avatarUrl != null) room.AvatarUrl = avatarUrl;
        room.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        return room;
    }

    public async Task<bool> DeactivateAsync(long roomId)
    {
        var room = await _db.GroupRooms.FindAsync(roomId);
        if (room == null) return false;

        room.IsActive = false;
        room.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return true;
    }
}
