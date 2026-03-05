namespace Synget.AgoraIntegrator.API.DTOs;

#region Authentication DTOs

/// <summary>
/// Request to register a new user.
/// </summary>
public class RegisterRequest
{
    /// <summary>
    /// Unique username (used for login).
    /// </summary>
    public string Username { get; set; } = string.Empty;

    /// <summary>
    /// User's password.
    /// </summary>
    public string Password { get; set; } = string.Empty;

    /// <summary>
    /// Display name shown in the UI.
    /// </summary>
    public string? DisplayName { get; set; }

    /// <summary>
    /// Optional email address.
    /// </summary>
    public string? Email { get; set; }

    /// <summary>
    /// User role: 'professor' or 'aluno'. Admin can only be assigned by existing admins.
    /// </summary>
    public string Role { get; set; } = "aluno";
}

/// <summary>
/// Request to login.
/// </summary>
public class LoginRequest
{
    /// <summary>
    /// Username to login with.
    /// </summary>
    public string Username { get; set; } = string.Empty;

    /// <summary>
    /// Password to authenticate.
    /// </summary>
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Response after successful authentication.
/// </summary>
public class AuthResponse
{
    /// <summary>
    /// Whether the operation was successful.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Error message if not successful.
    /// </summary>
    public string? Error { get; set; }

    /// <summary>
    /// Session token for authenticated requests.
    /// </summary>
    public string? Token { get; set; }

    /// <summary>
    /// Token expiration timestamp.
    /// </summary>
    public DateTime? ExpiresAt { get; set; }

    /// <summary>
    /// Authenticated user information.
    /// </summary>
    public UserInfo? User { get; set; }
}

/// <summary>
/// User information returned after authentication.
/// </summary>
public class UserInfo
{
    public long Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? Email { get; set; }
    public string Role { get; set; } = "aluno";
    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }

    /// <summary>
    /// Whether user can start video calls (professor or admin).
    /// </summary>
    public bool CanStartVideoCall => Role == "admin" || Role == "professor";

    /// <summary>
    /// Whether user has admin privileges.
    /// </summary>
    public bool IsAdmin => Role == "admin";
}

#endregion

#region Video Room DTOs

/// <summary>
/// Request to create a new video room.
/// </summary>
public class CreateVideoRoomRequest
{
    /// <summary>
    /// Optional channel name. If not provided, one will be generated.
    /// </summary>
    public string? ChannelName { get; set; }

    /// <summary>
    /// Title for the video room.
    /// </summary>
    public string? Title { get; set; }

    /// <summary>
    /// Maximum number of participants.
    /// </summary>
    public int MaxParticipants { get; set; } = 50;
}

/// <summary>
/// Response with video room information.
/// </summary>
public class VideoRoomResponse
{
    public long Id { get; set; }
    public string ChannelName { get; set; } = string.Empty;
    public string? Title { get; set; }
    public long HostUserId { get; set; }
    public string? HostUsername { get; set; }
    public string? HostDisplayName { get; set; }
    public bool IsActive { get; set; }
    public bool HostJoined { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public int TotalDurationSeconds { get; set; }
    public int MaxParticipants { get; set; }
    public int CurrentParticipants { get; set; }
    public DateTime CreatedAt { get; set; }
}

/// <summary>
/// Request to join a video room.
/// </summary>
public class JoinVideoRoomRequest
{
    /// <summary>
    /// Channel name of the room to join.
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
}

/// <summary>
/// Response when joining a video room.
/// </summary>
public class JoinVideoRoomResponse
{
    public bool Success { get; set; }
    public string? Error { get; set; }
    public VideoRoomResponse? Room { get; set; }
    public string? RtcToken { get; set; }
    public string? Uid { get; set; }
}

#endregion
