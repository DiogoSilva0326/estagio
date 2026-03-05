using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for professor room operations.
/// </summary>
public class ProfessorRoomRepository : IProfessorRoomRepository
{
    private readonly ChatDbContext _db;

    public ProfessorRoomRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<ProfessorRoomEntity> CreateAsync(long professorId, string professorName, string? roomName = null)
    {
        // Get the professor's username for default room name
        var professor = await _db.Users.FindAsync(professorId);
        var defaultRoomName = roomName ?? $"Professor_{professor?.Username ?? professorId.ToString()}";

        // Ensure unique room name
        var finalRoomName = defaultRoomName;
        var counter = 1;
        while (await _db.ProfessorRooms.AnyAsync(r => r.RoomName == finalRoomName))
        {
            finalRoomName = $"{defaultRoomName}_{counter++}";
        }

        var room = new ProfessorRoomEntity
        {
            ProfessorId = professorId,
            ProfessorName = professorName,
            RoomName = finalRoomName,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _db.ProfessorRooms.Add(room);
        await _db.SaveChangesAsync();

        return room;
    }

    public async Task<ProfessorRoomEntity?> GetByIdAsync(long id)
    {
        return await _db.ProfessorRooms
            .Include(r => r.Professor)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<ProfessorRoomEntity?> GetByProfessorIdAsync(long professorId)
    {
        return await _db.ProfessorRooms
            .Include(r => r.Professor)
            .FirstOrDefaultAsync(r => r.ProfessorId == professorId);
    }

    public async Task<ProfessorRoomEntity?> GetByRoomNameAsync(string roomName)
    {
        return await _db.ProfessorRooms
            .Include(r => r.Professor)
            .FirstOrDefaultAsync(r => r.RoomName == roomName);
    }

    public async Task<ProfessorRoomEntity?> GetByUsernameAsync(string username)
    {
        return await _db.ProfessorRooms
            .Include(r => r.Professor)
            .FirstOrDefaultAsync(r => r.Professor != null && r.Professor.Username == username);
    }

    public async Task<List<ProfessorRoomEntity>> GetAllAsync(bool activeOnly = true)
    {
        var query = _db.ProfessorRooms.Include(r => r.Professor).AsQueryable();

        if (activeOnly)
        {
            query = query.Where(r => r.IsActive);
        }

        return await query.OrderBy(r => r.ProfessorName).ToListAsync();
    }

    public async Task<ProfessorRoomEntity?> UpdateRoomNameAsync(long professorId, string newRoomName)
    {
        // Check if the name is available
        if (!await IsRoomNameAvailableAsync(newRoomName, professorId))
        {
            return null; // Name is already taken
        }

        var room = await _db.ProfessorRooms.FirstOrDefaultAsync(r => r.ProfessorId == professorId);
        if (room == null) return null;

        room.RoomName = newRoomName;
        room.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        return room;
    }

    public async Task<ProfessorRoomEntity?> UpdateAsync(long id, string? roomName = null, string? description = null, bool? isActive = null)
    {
        var room = await _db.ProfessorRooms.FindAsync(id);
        if (room == null) return null;

        if (roomName != null)
        {
            // Check if the name is available
            if (!await IsRoomNameAvailableAsync(roomName, room.ProfessorId))
            {
                return null; // Name is already taken
            }
            room.RoomName = roomName;
        }

        if (description != null)
        {
            room.Description = description;
        }

        if (isActive.HasValue)
        {
            room.IsActive = isActive.Value;
        }

        room.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();

        return room;
    }

    public async Task<bool> IsRoomNameAvailableAsync(string roomName, long? excludeProfessorId = null)
    {
        var query = _db.ProfessorRooms.Where(r => r.RoomName == roomName);

        if (excludeProfessorId.HasValue)
        {
            query = query.Where(r => r.ProfessorId != excludeProfessorId.Value);
        }

        return !await query.AnyAsync();
    }

    public async Task<bool> DeleteAsync(long id)
    {
        var room = await _db.ProfessorRooms.FindAsync(id);
        if (room == null) return false;

        _db.ProfessorRooms.Remove(room);
        await _db.SaveChangesAsync();

        return true;
    }
}
