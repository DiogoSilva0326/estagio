using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator.API.Data.Repositories;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for managing professor video call rooms.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class ProfessorRoomsController : ControllerBase
{
    private readonly IProfessorRoomRepository _roomRepo;
    private readonly ILogger<ProfessorRoomsController> _logger;

    public ProfessorRoomsController(IProfessorRoomRepository roomRepo, ILogger<ProfessorRoomsController> logger)
    {
        _roomRepo = roomRepo;
        _logger = logger;
    }

    /// <summary>
    /// Gets all professor rooms.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] bool activeOnly = true)
    {
        var rooms = await _roomRepo.GetAllAsync(activeOnly);
        return Ok(rooms.Select(r => MapToResponse(r)));
    }

    /// <summary>
    /// Gets a professor room by ID.
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var room = await _roomRepo.GetByIdAsync(id);
        if (room == null)
        {
            return NotFound(new { message = "Professor room not found" });
        }

        return Ok(MapToResponse(room));
    }

    /// <summary>
    /// Gets a professor room by professor ID.
    /// </summary>
    [HttpGet("professor/{professorId:guid}")]
    public async Task<IActionResult> GetByProfessorId(Guid professorId)
    {
        var room = await _roomRepo.GetByProfessorIdAsync(professorId);
        if (room == null)
        {
            return NotFound(new { message = "Professor room not found" });
        }

        return Ok(MapToResponse(room));
    }

    /// <summary>
    /// Gets a professor room by room name.
    /// </summary>
    [HttpGet("by-name/{roomName}")]
    public async Task<IActionResult> GetByRoomName(string roomName)
    {
        var room = await _roomRepo.GetByRoomNameAsync(roomName);
        if (room == null)
        {
            return NotFound(new { message = "Professor room not found" });
        }

        return Ok(MapToResponse(room));
    }

    /// <summary>
    /// Gets a professor room by professor username.
    /// </summary>
    [HttpGet("by-username/{username}")]
    public async Task<IActionResult> GetByUsername(string username)
    {
        var room = await _roomRepo.GetByUsernameAsync(username);
        if (room == null)
        {
            return NotFound(new { message = "Professor room not found" });
        }

        return Ok(MapToResponse(room));
    }

    /// <summary>
    /// Checks if a room name is available.
    /// </summary>
    [HttpGet("check-name/{roomName}")]
    public async Task<IActionResult> CheckRoomName(string roomName, [FromQuery] Guid? excludeProfessorId = null)
    {
        var isAvailable = await _roomRepo.IsRoomNameAvailableAsync(roomName, excludeProfessorId);
        return Ok(new { roomName, isAvailable });
    }

    /// <summary>
    /// Updates the room name for a professor.
    /// </summary>
    [HttpPut("professor/{professorId:guid}/room-name")]
    public async Task<IActionResult> UpdateRoomName(Guid professorId, [FromBody] UpdateRoomNameRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.NewRoomName))
        {
            return BadRequest(new { message = "Room name is required" });
        }

        // Validate room name format (no special characters except underscore)
        if (!System.Text.RegularExpressions.Regex.IsMatch(request.NewRoomName, @"^[a-zA-Z0-9_]+$"))
        {
            return BadRequest(new { message = "Room name can only contain letters, numbers, and underscores" });
        }

        var room = await _roomRepo.UpdateRoomNameAsync(professorId, request.NewRoomName);
        if (room == null)
        {
            // Check if room exists
            var existing = await _roomRepo.GetByProfessorIdAsync(professorId);
            if (existing == null)
            {
                return NotFound(new { message = "Professor room not found" });
            }

            return Conflict(new { message = "Room name is already taken by another professor" });
        }

        _logger.LogInformation("Professor {ProfessorId} updated room name to {RoomName}", professorId, request.NewRoomName);
        return Ok(MapToResponse(room));
    }

    /// <summary>
    /// Updates a professor room.
    /// </summary>
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateProfessorRoomRequest request)
    {
        // Validate room name format if provided
        if (!string.IsNullOrWhiteSpace(request.RoomName) && 
            !System.Text.RegularExpressions.Regex.IsMatch(request.RoomName, @"^[a-zA-Z0-9_]+$"))
        {
            return BadRequest(new { message = "Room name can only contain letters, numbers, and underscores" });
        }

        var room = await _roomRepo.UpdateAsync(id, request.RoomName, request.Description, request.IsActive);
        if (room == null)
        {
            // Check if room exists
            var existing = await _roomRepo.GetByIdAsync(id);
            if (existing == null)
            {
                return NotFound(new { message = "Professor room not found" });
            }

            return Conflict(new { message = "Room name is already taken by another professor" });
        }

        return Ok(MapToResponse(room));
    }

    private static ProfessorRoomResponse MapToResponse(Data.Entities.ProfessorRoomEntity room)
    {
        return new ProfessorRoomResponse
        {
            Id = room.Id,
            ProfessorId = room.ProfessorId,
            ProfessorName = room.ProfessorName,
            ProfessorUsername = room.Professor?.Username,
            RoomName = room.RoomName,
            Description = room.Description,
            IsActive = room.IsActive,
            CreatedAt = room.CreatedAt,
            UpdatedAt = room.UpdatedAt
        };
    }
}

// DTOs
public record UpdateRoomNameRequest
{
    public string NewRoomName { get; init; } = string.Empty;
}

public record UpdateProfessorRoomRequest
{
    public string? RoomName { get; init; }
    public string? Description { get; init; }
    public bool? IsActive { get; init; }
}

public record ProfessorRoomResponse
{
    public Guid Id { get; init; }
    public Guid ProfessorId { get; init; }
    public string ProfessorName { get; init; } = string.Empty;
    public string? ProfessorUsername { get; init; }
    public string RoomName { get; init; } = string.Empty;
    public string? Description { get; init; }
    public bool IsActive { get; init; }
    public DateTime CreatedAt { get; init; }
    public DateTime UpdatedAt { get; init; }
}
