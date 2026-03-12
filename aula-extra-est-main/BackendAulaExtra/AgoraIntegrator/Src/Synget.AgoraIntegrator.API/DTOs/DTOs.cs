namespace Synget.AgoraIntegrator.API.DTOs;

#region Token DTOs

/// <summary>
/// Request for generating an RTC token
/// </summary>
public class RtcTokenRequest
{
    /// <summary>
    /// The channel name
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The user ID (UID)
    /// </summary>
    public string Uid { get; set; } = string.Empty;
}

/// <summary>
/// Request for generating an RTM token
/// </summary>
public class RtmTokenRequest
{
    /// <summary>
    /// The user ID
    /// </summary>
    public string UserId { get; set; } = string.Empty;
}

/// <summary>
/// Response containing a token
/// </summary>
public class TokenResponse
{
    /// <summary>
    /// The generated token
    /// </summary>
    public string Token { get; set; } = string.Empty;
    
    /// <summary>
    /// The channel name (for RTC tokens)
    /// </summary>
    public string? ChannelName { get; set; }
    
    /// <summary>
    /// The user ID
    /// </summary>
    public string? Uid { get; set; }
    
    /// <summary>
    /// The token type (RTC or RTM)
    /// </summary>
    public string TokenType { get; set; } = string.Empty;
}

#endregion

#region Session DTOs

/// <summary>
/// Request for creating a session
/// </summary>
public class CreateSessionRequest
{
    /// <summary>
    /// The channel name for the session
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The host user ID
    /// </summary>
    public string HostUserId { get; set; } = string.Empty;
}

/// <summary>
/// Request for joining a session
/// </summary>
public class JoinSessionRequest
{
    /// <summary>
    /// The channel name to join
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The user ID joining the session
    /// </summary>
    public string UserId { get; set; } = string.Empty;
    /// <summary>
    /// Optional display name for the joining user.
    /// </summary>
    public string? DisplayName { get; set; }
}

/// <summary>
/// Request for leaving a session
/// </summary>
public class LeaveSessionRequest
{
    /// <summary>
    /// The channel name to leave
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The user ID leaving the session
    /// </summary>
    public string UserId { get; set; } = string.Empty;
}

/// <summary>
/// Response containing session information
/// </summary>
public class SessionResponse
{
    /// <summary>
    /// The channel name
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The host user ID
    /// </summary>
    public string? HostUserId { get; set; }
    
    /// <summary>
    /// The RTC token for this session (if applicable)
    /// </summary>
    public string? Token { get; set; }
    
    /// <summary>
    /// When the session was created
    /// </summary>
    public DateTime? CreatedAt { get; set; }
    
    /// <summary>
    /// List of users in the session
    /// </summary>
    public List<SessionUserResponse> Users { get; set; } = new();
    
    /// <summary>
    /// Optional message
    /// </summary>
    public string? Message { get; set; }
}

/// <summary>
/// Response item describing a user in a session
/// </summary>
public class SessionUserResponse
{
    /// <summary>
    /// The user id (string)
    /// </summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>
    /// The display name for the user, if provided.
    /// </summary>
    public string? DisplayName { get; set; }

    /// <summary>
    /// Is audio muted for this user
    /// </summary>
    public bool IsAudioMuted { get; set; } = false;

    /// <summary>
    /// Is video muted for this user
    /// </summary>
    public bool IsVideoMuted { get; set; } = false;

    /// <summary>
    /// When the user joined
    /// </summary>
    public DateTime? JoinedAt { get; set; }
}

/// <summary>
/// Request to set a user's mute state (audio/video)
/// </summary>
public class SetUserMuteRequest
{
    /// <summary>
    /// The user id to modify
    /// </summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>
    /// The desired mute state (true = muted)
    /// </summary>
    public bool Muted { get; set; } = false;
}

#endregion

#region Whiteboard DTOs

/// <summary>
/// Request for creating a whiteboard room
/// </summary>
public class CreateWhiteboardRequest
{
    /// <summary>
    /// The room name
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// Maximum number of users (0 = unlimited)
    /// </summary>
    public int Limit { get; set; } = 0;
}

/// <summary>
/// Request for getting a whiteboard room token
/// </summary>
public class WhiteboardTokenRequest
{
    /// <summary>
    /// The channel name (used to create/get room)
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The user ID
    /// </summary>
    public int Uid { get; set; } = 0;
    
    /// <summary>
    /// The room UUID (optional, if already known)
    /// </summary>
    public string? RoomUuid { get; set; }
    
    /// <summary>
    /// Whether the token should allow write access
    /// </summary>
    public bool IsWritable { get; set; } = true;
}

/// <summary>
/// Response containing whiteboard token
/// </summary>
public class WhiteboardTokenResponse
{
    /// <summary>
    /// The room UUID
    /// </summary>
    public string Uuid { get; set; } = string.Empty;
    
    /// <summary>
    /// The room token
    /// </summary>
    public string Token { get; set; } = string.Empty;
    
    /// <summary>
    /// The channel name
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
}

/// <summary>
/// Response containing whiteboard configuration for client-side setup
/// </summary>
public class WhiteboardConfigResponse
{
    /// <summary>
    /// The Netless App Identifier for client-side SDK
    /// </summary>
    public string AppIdentifier { get; set; } = string.Empty;
    
    /// <summary>
    /// The Netless region
    /// </summary>
    public string Region { get; set; } = string.Empty;
}

/// <summary>
/// Response containing whiteboard information
/// </summary>
public class WhiteboardResponse
{
    /// <summary>
    /// The room UUID
    /// </summary>
    public string RoomUuid { get; set; } = string.Empty;
    
    /// <summary>
    /// The room token
    /// </summary>
    public string RoomToken { get; set; } = string.Empty;
    
    /// <summary>
    /// The app identifier
    /// </summary>
    public string AppIdentifier { get; set; } = string.Empty;
}

#endregion

#region Screen Share DTOs

/// <summary>
/// Request for generating a screen share token
/// </summary>
public class ScreenShareTokenRequest
{
    /// <summary>
    /// The channel name
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The base user UID (screen share UID will be calculated as baseUid * 100 + 99)
    /// </summary>
    public uint BaseUid { get; set; } = 0;
}

/// <summary>
/// Response containing screen share token and UID
/// </summary>
public class ScreenShareTokenResponse
{
    /// <summary>
    /// The generated token for screen sharing
    /// </summary>
    public string Token { get; set; } = string.Empty;
    
    /// <summary>
    /// The channel name
    /// </summary>
    public string ChannelName { get; set; } = string.Empty;
    
    /// <summary>
    /// The screen share UID (calculated from baseUid)
    /// </summary>
    public uint ScreenShareUid { get; set; } = 0;
    
    /// <summary>
    /// The base UID that was used
    /// </summary>
    public uint BaseUid { get; set; } = 0;
}

#endregion

#region Common DTOs

/// <summary>
/// Error response
/// </summary>
public class ErrorResponse
{
    /// <summary>
    /// The error message
    /// </summary>
    public string Message { get; set; } = string.Empty;
}

#endregion
