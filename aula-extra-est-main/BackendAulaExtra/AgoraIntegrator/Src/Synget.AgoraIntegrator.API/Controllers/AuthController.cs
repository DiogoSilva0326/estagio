using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator.API.Data.Repositories;
using Synget.AgoraIntegrator.API.DTOs;
using BCrypt.Net;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for user authentication (login, register, logout).
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IUserRepository _userRepository;
    private readonly ISessionRepository _sessionRepository;
    private readonly IProfessorRoomRepository _professorRoomRepository;
    private readonly ILogger<AuthController> _logger;

    // Session expiration in days
    private const int SessionExpirationDays = 30;

    public AuthController(
        IUserRepository userRepository,
        ISessionRepository sessionRepository,
        IProfessorRoomRepository professorRoomRepository,
        ILogger<AuthController> logger)
    {
        _userRepository = userRepository;
        _sessionRepository = sessionRepository;
        _professorRoomRepository = professorRoomRepository;
        _logger = logger;
    }

    /// <summary>
    /// Register a new user account.
    /// </summary>
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        _logger.LogInformation("Registration attempt for username: {Username}", request.Username);

        // Validate input
        if (string.IsNullOrWhiteSpace(request.Username) || request.Username.Length < 3)
        {
            return BadRequest(new AuthResponse
            {
                Success = false,
                Error = "Username must be at least 3 characters long."
            });
        }

        if (string.IsNullOrWhiteSpace(request.Password) || request.Password.Length < 6)
        {
            return BadRequest(new AuthResponse
            {
                Success = false,
                Error = "Password must be at least 6 characters long."
            });
        }

        // Validate role (only professor and aluno can self-register)
        var role = request.Role?.ToLowerInvariant() ?? "aluno";
        if (role != "professor" && role != "aluno")
        {
            role = "aluno"; // Default to aluno for invalid roles
        }

        // Check if username already exists
        if (await _userRepository.UsernameExistsAsync(request.Username))
        {
            return BadRequest(new AuthResponse
            {
                Success = false,
                Error = "Username already taken."
            });
        }

        // Hash password
        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

        // Create user
        var user = await _userRepository.RegisterAsync(
            request.Username,
            passwordHash,
            role,
            request.DisplayName ?? request.Username,
            request.Email
        );

        if (user == null)
        {
            return BadRequest(new AuthResponse
            {
                Success = false,
                Error = "Failed to create user account."
            });
        }

        // If user is a professor, create their video call room
        if (role == "professor")
        {
            try
            {
                var professorRoom = await _professorRoomRepository.CreateAsync(
                    user.Id,
                    user.DisplayName ?? user.Username,
                    $"Professor_{user.Username}"
                );
                _logger.LogInformation("Professor room created for user {Username}: {RoomName}", user.Username, professorRoom.RoomName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create professor room for user {Username}", user.Username);
                // Don't fail registration if room creation fails
            }
        }

        // Create session
        var token = GenerateToken();
        var expiresAt = DateTime.UtcNow.AddDays(SessionExpirationDays);
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var userAgent = Request.Headers.UserAgent.ToString();

        await _sessionRepository.CreateAsync(user.Id, token, expiresAt, ipAddress, userAgent);
        await _userRepository.UpdateLastLoginAsync(user.Id);

        _logger.LogInformation("User registered successfully: {Username} with role {Role}", user.Username, user.Role);

        return Ok(new AuthResponse
        {
            Success = true,
            Token = token,
            ExpiresAt = expiresAt,
            User = MapToUserInfo(user)
        });
    }

    /// <summary>
    /// Login with username and password.
    /// </summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        _logger.LogInformation("Login attempt for username: {Username}", request.Username);

        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
        {
            return Unauthorized(new AuthResponse
            {
                Success = false,
                Error = "Username and password are required."
            });
        }

        // Find user
        var user = await _userRepository.GetByUsernameAsync(request.Username);
        if (user == null)
        {
            return Unauthorized(new AuthResponse
            {
                Success = false,
                Error = "Invalid username or password."
            });
        }

        // Check if user is active
        if (!user.IsActive)
        {
            return Unauthorized(new AuthResponse
            {
                Success = false,
                Error = "Account is deactivated."
            });
        }

        // Verify password
        if (string.IsNullOrEmpty(user.PasswordHash) || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            return Unauthorized(new AuthResponse
            {
                Success = false,
                Error = "Invalid username or password."
            });
        }

        // Create session
        var token = GenerateToken();
        var expiresAt = DateTime.UtcNow.AddDays(SessionExpirationDays);
        var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
        var userAgent = Request.Headers.UserAgent.ToString();

        await _sessionRepository.CreateAsync(user.Id, token, expiresAt, ipAddress, userAgent);
        await _userRepository.UpdateLastLoginAsync(user.Id);

        _logger.LogInformation("User logged in successfully: {Username}", user.Username);

        return Ok(new AuthResponse
        {
            Success = true,
            Token = token,
            ExpiresAt = expiresAt,
            User = MapToUserInfo(user)
        });
    }

    /// <summary>
    /// Logout (invalidate session token).
    /// </summary>
    [HttpPost("logout")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult> Logout()
    {
        var token = GetTokenFromHeader();
        if (!string.IsNullOrEmpty(token))
        {
            await _sessionRepository.DeleteByTokenAsync(token);
            _logger.LogInformation("User logged out, session invalidated");
        }

        return Ok(new { success = true, message = "Logged out successfully." });
    }

    /// <summary>
    /// Get current authenticated user info.
    /// </summary>
    [HttpGet("me")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AuthResponse>> GetCurrentUser()
    {
        var token = GetTokenFromHeader();
        if (string.IsNullOrEmpty(token))
        {
            return Unauthorized(new AuthResponse
            {
                Success = false,
                Error = "No authentication token provided."
            });
        }

        var session = await _sessionRepository.GetByTokenAsync(token);
        if (session == null || session.User == null)
        {
            return Unauthorized(new AuthResponse
            {
                Success = false,
                Error = "Invalid or expired session."
            });
        }

        return Ok(new AuthResponse
        {
            Success = true,
            Token = token,
            ExpiresAt = session.ExpiresAt,
            User = MapToUserInfo(session.User)
        });
    }

    /// <summary>
    /// Validate a session token.
    /// </summary>
    [HttpGet("validate")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    public async Task<ActionResult> ValidateToken()
    {
        var token = GetTokenFromHeader();
        if (string.IsNullOrEmpty(token))
        {
            return Ok(new { valid = false });
        }

        var isValid = await _sessionRepository.IsValidTokenAsync(token);
        return Ok(new { valid = isValid });
    }

    /// <summary>
    /// Update user role (admin only).
    /// </summary>
    [HttpPut("users/{userId}/role")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult> UpdateUserRole(long userId, [FromBody] UpdateRoleRequest request)
    {
        // Verify caller is admin
        var currentUser = await GetAuthenticatedUser();
        if (currentUser == null)
        {
            return Unauthorized(new { error = "Authentication required." });
        }

        if (currentUser.Role != "admin")
        {
            return Forbid();
        }

        var success = await _userRepository.UpdateRoleAsync(userId, request.Role);
        if (!success)
        {
            return NotFound(new { error = "User not found or invalid role." });
        }

        _logger.LogInformation("Admin {Admin} changed role of user {UserId} to {Role}", 
            currentUser.Username, userId, request.Role);

        return Ok(new { success = true, message = $"User role updated to {request.Role}." });
    }

    /// <summary>
    /// Get all users (admin only).
    /// </summary>
    [HttpGet("users")]
    [ProducesResponseType(typeof(List<UserInfo>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<ActionResult<List<UserInfo>>> GetAllUsers([FromQuery] int limit = 100, [FromQuery] int offset = 0)
    {
        var currentUser = await GetAuthenticatedUser();
        if (currentUser == null)
        {
            return Unauthorized(new { error = "Authentication required." });
        }

        if (currentUser.Role != "admin")
        {
            return Forbid();
        }

        var users = await _userRepository.GetAllAsync(limit, offset);
        return Ok(users.Select(MapToUserInfo).ToList());
    }

    #region Helper Methods

    private string GenerateToken()
    {
        return Convert.ToBase64String(Guid.NewGuid().ToByteArray())
            .Replace("/", "_")
            .Replace("+", "-")
            .Replace("=", "")
            + Convert.ToBase64String(Guid.NewGuid().ToByteArray())
            .Replace("/", "_")
            .Replace("+", "-")
            .Replace("=", "");
    }

    private string? GetTokenFromHeader()
    {
        var authHeader = Request.Headers.Authorization.ToString();
        if (string.IsNullOrEmpty(authHeader))
        {
            return null;
        }

        if (authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return authHeader.Substring("Bearer ".Length).Trim();
        }

        return authHeader;
    }

    private async Task<Data.Entities.UserEntity?> GetAuthenticatedUser()
    {
        var token = GetTokenFromHeader();
        if (string.IsNullOrEmpty(token)) return null;

        var session = await _sessionRepository.GetByTokenAsync(token);
        return session?.User;
    }

    private static UserInfo MapToUserInfo(Data.Entities.UserEntity user)
    {
        return new UserInfo
        {
            Id = user.Id,
            Username = user.Username,
            DisplayName = user.DisplayName,
            Email = user.Email,
            Role = user.Role,
            CreatedAt = user.CreatedAt,
            LastLoginAt = user.LastLoginAt
        };
    }

    #endregion
}

/// <summary>
/// Request to update a user's role.
/// </summary>
public class UpdateRoleRequest
{
    public string Role { get; set; } = "aluno";
}
