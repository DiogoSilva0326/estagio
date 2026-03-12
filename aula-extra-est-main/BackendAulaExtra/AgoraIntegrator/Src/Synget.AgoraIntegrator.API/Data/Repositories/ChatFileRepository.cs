using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for chat file operations.
/// </summary>
public class ChatFileRepository : IChatFileRepository
{
    private readonly ChatDbContext _db;

    public ChatFileRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<ChatFileEntity> CreateAsync(ChatFileEntity file)
    {
        file.CreatedAt = DateTime.UtcNow;
        _db.ChatFiles.Add(file);
        await _db.SaveChangesAsync();
        return file;
    }

    public async Task<ChatFileEntity?> GetByFileIdAsync(string fileId)
    {
        return await _db.ChatFiles
            .Include(f => f.UploadedByUser)
            .FirstOrDefaultAsync(f => f.FileId == fileId && f.IsActive);
    }

    public async Task<ChatFileEntity?> GetByIdAsync(long id)
    {
        return await _db.ChatFiles
            .Include(f => f.UploadedByUser)
            .FirstOrDefaultAsync(f => f.Id == id && f.IsActive);
    }

    public async Task<List<ChatFileEntity>> GetByUserAsync(long userId, int limit = 50)
    {
        return await _db.ChatFiles
            .Include(f => f.UploadedByUser)
            .Where(f => f.UploadedByUserId == userId && f.IsActive)
            .OrderByDescending(f => f.CreatedAt)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<List<ChatFileEntity>> GetByRoomAsync(string roomId, int limit = 50)
    {
        return await _db.ChatFiles
            .Include(f => f.UploadedByUser)
            .Where(f => f.RoomId == roomId && f.IsActive)
            .OrderByDescending(f => f.CreatedAt)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<List<ChatFileEntity>> GetAccessibleFilesAsync(string username, int limit = 100)
    {
        // Get user's DB id
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Username == username);
        if (user == null)
            return new List<ChatFileEntity>();

        // Get all room IDs where user is a participant
        // DM rooms: dm_user1_user2 format
        // Group rooms: check group_room_members
        // Video call rooms: any room containing username that's not dm_ or group_

        // Get DM rooms where user is participant
        var dmRoomsQuery = _db.ChatFiles
            .Where(f => f.IsActive && f.RoomId != null && f.RoomId.StartsWith("dm_") && f.RoomId.Contains(username));

        // Get group rooms where user is member
        var userGroupRoomIds = await _db.GroupRoomMembers
            .Where(m => m.UserId == user.Id)
            .Select(m => m.Room!.RoomCode)
            .ToListAsync();

        var groupRoomsQuery = _db.ChatFiles
            .Where(f => f.IsActive && f.RoomId != null && userGroupRoomIds.Contains(f.RoomId));

        // Files uploaded by user (regardless of room) - this includes video call files
        var uploadedByUserQuery = _db.ChatFiles
            .Where(f => f.IsActive && f.UploadedByUserId == user.Id);

        // Video call rooms where user is participant (rooms containing username that are NOT dm_ or group_)
        var videoCallRoomsQuery = _db.ChatFiles
            .Where(f => f.IsActive && 
                        f.RoomId != null && 
                        !f.RoomId.StartsWith("dm_") && 
                        !f.RoomId.StartsWith("group_") &&
                        f.RoomId.Contains(username));

        // Combine and get unique files
        var allFiles = await dmRoomsQuery
            .Union(groupRoomsQuery)
            .Union(uploadedByUserQuery)
            .Union(videoCallRoomsQuery)
            .Include(f => f.UploadedByUser)
            .OrderByDescending(f => f.CreatedAt)
            .Take(limit)
            .ToListAsync();

        return allFiles;
    }

    public async Task<List<ChatFileEntity>> GetFilesInConversationAsync(string roomId, int limit = 100)
    {
        return await _db.ChatFiles
            .Include(f => f.UploadedByUser)
            .Where(f => f.RoomId == roomId && f.IsActive)
            .OrderByDescending(f => f.CreatedAt)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<ChatFileEntity?> UpdateAsync(ChatFileEntity file)
    {
        var existing = await _db.ChatFiles.FindAsync(file.Id);
        if (existing == null) return null;

        existing.RoomId = file.RoomId;
        existing.MessageId = file.MessageId;
        existing.ThumbnailUrl = file.ThumbnailUrl;
        
        await _db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(string fileId)
    {
        var file = await _db.ChatFiles.FirstOrDefaultAsync(f => f.FileId == fileId);
        if (file == null) return false;

        file.IsActive = false;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> UserHasAccessAsync(string username, string fileId)
    {
        var file = await GetByFileIdAsync(fileId);
        if (file == null) return false;

        // Check if user uploaded the file
        if (file.UploadedByUser?.Username == username) return true;

        // Check if file is in a room where user is participant
        if (string.IsNullOrEmpty(file.RoomId)) return false;

        // DM room check
        if (file.RoomId.StartsWith("dm_") && file.RoomId.Contains(username))
            return true;

        // Video call room check (rooms containing username that are NOT dm_ or group_)
        if (!file.RoomId.StartsWith("dm_") && !file.RoomId.StartsWith("group_") && file.RoomId.Contains(username))
            return true;

        // Group room check
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Username == username);
        if (user == null) return false;

        var isGroupMember = await _db.GroupRoomMembers
            .AnyAsync(m => m.UserId == user.Id && m.Room!.RoomCode == file.RoomId);

        return isGroupMember;
    }
}
