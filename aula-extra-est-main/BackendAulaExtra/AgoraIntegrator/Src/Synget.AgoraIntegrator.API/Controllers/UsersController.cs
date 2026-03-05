using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator.API.Data.Repositories;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// API controller for user management.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserRepository _userRepo;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserRepository userRepo, ILogger<UsersController> logger)
    {
        _userRepo = userRepo;
        _logger = logger;
    }

    /// <summary>
    /// Get or create a user by username.
    /// </summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterUserRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Username))
        {
            return BadRequest(new { error = "Username is required." });
        }

        try
        {
            var user = await _userRepo.GetOrCreateAsync(
                request.Username,
                request.DisplayName,
                request.ExternalId
            );

            return Ok(new UserDto
            {
                Id = user.Id,
                Username = user.Username,
                DisplayName = user.DisplayName ?? user.Username,
                ExternalId = user.ExternalId,
                CreatedAt = user.CreatedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error registering user {Username}", request.Username);
            return StatusCode(500, new { error = "Failed to register user." });
        }
    }

    /// <summary>
    /// Get user by ID.
    /// </summary>
    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id)
    {
        var user = await _userRepo.GetByIdAsync(id);
        if (user == null)
        {
            return NotFound(new { error = "User not found." });
        }

        return Ok(new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName ?? user.Username,
            ExternalId = user.ExternalId,
            CreatedAt = user.CreatedAt
        });
    }

    /// <summary>
    /// Get user by username.
    /// </summary>
    [HttpGet("by-username/{username}")]
    public async Task<IActionResult> GetByUsername(string username)
    {
        var user = await _userRepo.GetByUsernameAsync(username);
        if (user == null)
        {
            return NotFound(new { error = "User not found." });
        }

        return Ok(new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName ?? user.Username,
            ExternalId = user.ExternalId,
            CreatedAt = user.CreatedAt
        });
    }

    /// <summary>
    /// Update user display name.
    /// </summary>
    [HttpPut("{id:long}/display-name")]
    public async Task<IActionResult> UpdateDisplayName(long id, [FromBody] UpdateDisplayNameRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.DisplayName))
        {
            return BadRequest(new { error = "Display name is required." });
        }

        var user = await _userRepo.UpdateDisplayNameAsync(id, request.DisplayName);
        if (user == null)
        {
            return NotFound(new { error = "User not found." });
        }

        return Ok(new UserDto
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName ?? user.Username,
            ExternalId = user.ExternalId,
            CreatedAt = user.CreatedAt
        });
    }

    /// <summary>
    /// Get all users (paginated).
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] int limit = 100, [FromQuery] int offset = 0)
    {
        var users = await _userRepo.GetAllAsync(limit, offset);
        return Ok(users.Select(u => new UserDto
        {
            Id = u.Id,
            Username = u.Username,
            DisplayName = u.DisplayName ?? u.Username,
            ExternalId = u.ExternalId,
            CreatedAt = u.CreatedAt
        }));
    }
}

// DTOs
public class RegisterUserRequest
{
    public string Username { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? ExternalId { get; set; }
}

public class UpdateDisplayNameRequest
{
    public string DisplayName { get; set; } = string.Empty;
}

public class UserDto
{
    public long Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string? ExternalId { get; set; }
    public DateTime CreatedAt { get; set; }
}
