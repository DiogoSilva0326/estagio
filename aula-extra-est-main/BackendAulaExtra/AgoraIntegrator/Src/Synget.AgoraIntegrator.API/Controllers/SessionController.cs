using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator;
using Synget.AgoraIntegrator.API.DTOs;
using Synget.AgoraIntegrator.Models;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for managing Agora sessions
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class SessionController : ControllerBase
{
    private readonly IAgora _agora;
    private readonly ILogger<SessionController> _logger;

    public SessionController(IAgora agora, ILogger<SessionController> logger)
    {
        _agora = agora;
        _logger = logger;
    }

    /// <summary>
    /// Creates a new session (channel)
    /// </summary>
    /// <param name="request">Session creation request</param>
    /// <returns>Session details with RTC token</returns>
    [HttpPost("create")]
    [ProducesResponseType(typeof(SessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public ActionResult<SessionResponse> CreateSession([FromBody] CreateSessionRequest request)
    {
        _logger.LogInformation("Creating session: {Channel} for host: {Host}", 
            request.ChannelName, request.HostUserId);

        var session = _agora.SessionCreate(request.ChannelName);

        if (session is null)
        {
            _logger.LogWarning("Failed to create session: {Message}", _agora.Message);
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        // Add the host to the session
        _agora.SessionUserJoin(request.ChannelName, request.HostUserId);

        // Generate RTC token for the host
        uint.TryParse(request.HostUserId, out var uid);
        var tokenResult = _agora.RtcTokenGenerate(request.ChannelName, uid, AgoraRtcRole.Publisher);

        // Get updated session
        session = _agora.SessionGet(request.ChannelName);

        return Ok(MapSessionToResponse(session!, tokenResult?.Token));
    }

    /// <summary>
    /// Gets session information by channel name
    /// </summary>
    /// <param name="channelName">The channel name</param>
    /// <returns>Session details</returns>
    [HttpGet("{channelName}")]
    [ProducesResponseType(typeof(SessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult<SessionResponse> GetSession(string channelName)
    {
        _logger.LogInformation("Getting session: {Channel}", channelName);

        var session = _agora.SessionGet(channelName);

        if (session is null)
        {
            _logger.LogWarning("Session not found: {Channel}", channelName);
            return NotFound(new ErrorResponse { Message = $"Session '{channelName}' not found." });
        }

        return Ok(MapSessionToResponse(session));
    }

    /// <summary>
    /// Gets all active sessions
    /// </summary>
    /// <returns>List of all sessions</returns>
    [HttpGet]
    [ProducesResponseType(typeof(List<SessionResponse>), StatusCodes.Status200OK)]
    public ActionResult<List<SessionResponse>> GetAllSessions()
    {
        _logger.LogInformation("Getting all sessions");

        var sessions = _agora.SessionGetList();

        var response = sessions.Select(s => MapSessionToResponse(s)).ToList();

        return Ok(response);
    }

    /// <summary>
    /// Joins a user to a session
    /// </summary>
    /// <param name="request">Join session request</param>
    /// <returns>Session details with token for the joining user</returns>
    [HttpPost("join")]
    [ProducesResponseType(typeof(SessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult<SessionResponse> JoinSession([FromBody] JoinSessionRequest request)
    {
        _logger.LogInformation("User {User} joining session: {Channel}", 
            request.UserId, request.ChannelName);

        // Check if session exists
        var session = _agora.SessionGet(request.ChannelName);
        if (session is null)
        {
            return NotFound(new ErrorResponse { Message = $"Session '{request.ChannelName}' not found." });
        }

        // Add user to session
        var success = _agora.SessionUserJoin(request.ChannelName, request.UserId, request.DisplayName);
        if (!success)
        {
            _logger.LogWarning("Failed to join session: {Message}", _agora.Message);
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        // Generate RTC token for the joining user
        uint.TryParse(request.UserId, out var uid);
        var tokenResult = _agora.RtcTokenGenerate(request.ChannelName, uid, AgoraRtcRole.Publisher);

        // Get updated session
        session = _agora.SessionGet(request.ChannelName);

        return Ok(MapSessionToResponse(session!, tokenResult?.Token));
    }

    /// <summary>
    /// Removes a user from a session
    /// </summary>
    /// <param name="request">Leave session request</param>
    /// <returns>Updated session details</returns>
    [HttpPost("leave")]
    [ProducesResponseType(typeof(SessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult<SessionResponse> LeaveSession([FromBody] LeaveSessionRequest request)
    {
        _logger.LogInformation("User {User} leaving session: {Channel}", 
            request.UserId, request.ChannelName);

        // Check if session exists
        var session = _agora.SessionGet(request.ChannelName);
        if (session is null)
        {
            return NotFound(new ErrorResponse { Message = $"Session '{request.ChannelName}' not found." });
        }

        // Remove user from session
        var success = _agora.SessionUserLeave(request.ChannelName, request.UserId);
        if (!success)
        {
            _logger.LogWarning("Failed to leave session: {Message}", _agora.Message);
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        // Get updated session (might be null if it was ended)
        session = _agora.SessionGet(request.ChannelName);

        if (session is null)
        {
            return Ok(new SessionResponse
            {
                ChannelName = request.ChannelName,
                Message = "Session ended as last user left."
            });
        }

        return Ok(MapSessionToResponse(session));
    }

    /// <summary>
    /// Set a user's audio mute state in a session
    /// </summary>
    [HttpPost("{channelName}/mute/audio")]
    [ProducesResponseType(typeof(SessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult<SessionResponse> SetUserAudioMute(string channelName, [FromBody] SetUserMuteRequest request)
    {
        _logger.LogInformation("Setting audio mute for user {User} in {Channel} -> {Muted}", request.UserId, channelName, request.Muted);

        var session = _agora.SessionGet(channelName);
        if (session is null)
        {
            return NotFound(new ErrorResponse { Message = $"Session '{channelName}' not found." });
        }

        var success = _agora.SessionSetUserAudioMuted(channelName, request.UserId, request.Muted);
        if (!success)
        {
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        session = _agora.SessionGet(channelName);
        return Ok(MapSessionToResponse(session!));
    }

    /// <summary>
    /// Set a user's video mute state in a session
    /// </summary>
    [HttpPost("{channelName}/mute/video")]
    [ProducesResponseType(typeof(SessionResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult<SessionResponse> SetUserVideoMute(string channelName, [FromBody] SetUserMuteRequest request)
    {
        _logger.LogInformation("Setting video mute for user {User} in {Channel} -> {Muted}", request.UserId, channelName, request.Muted);

        var session = _agora.SessionGet(channelName);
        if (session is null)
        {
            return NotFound(new ErrorResponse { Message = $"Session '{channelName}' not found." });
        }

        var success = _agora.SessionSetUserVideoMuted(channelName, request.UserId, request.Muted);
        if (!success)
        {
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        session = _agora.SessionGet(channelName);
        return Ok(MapSessionToResponse(session!));
    }

    /// <summary>
    /// Get a participant's state in a session
    /// </summary>
    [HttpGet("{channelName}/user/{userId}")]
    [ProducesResponseType(typeof(SessionUserResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult<SessionUserResponse> GetUser(string channelName, string userId)
    {
        var session = _agora.SessionGet(channelName);
        if (session is null)
        {
            return NotFound(new ErrorResponse { Message = $"Session '{channelName}' not found." });
        }

        var user = _agora.SessionGetUser(channelName, userId);
        if (user is null)
        {
            return NotFound(new ErrorResponse { Message = $"User '{userId}' not found in session '{channelName}'." });
        }

            return Ok(new SessionUserResponse
        {
            UserId = user.UserId,
            DisplayName = user.DisplayName,
            IsAudioMuted = user.IsAudioMuted,
            IsVideoMuted = user.IsVideoMuted,
            JoinedAt = user.JoinedAt
        });
    }

    private SessionResponse MapSessionToResponse(AgoraSession session, string? token = null)
    {
        return new SessionResponse
        {
            ChannelName = session.ChannelName,
            HostUserId = session.Users.FirstOrDefault()?.UserId,
            Token = token ?? string.Empty,
            CreatedAt = session.CreatedAt,
                Users = session.Users.Select(u => new SessionUserResponse
                {
                    UserId = u.UserId,
                    DisplayName = u.DisplayName,
                    IsAudioMuted = u.IsAudioMuted,
                    IsVideoMuted = u.IsVideoMuted,
                    JoinedAt = u.JoinedAt
                }).ToList()
        };
    }

    /// <summary>
    /// Ends a session
    /// </summary>
    /// <param name="channelName">The channel name to end</param>
    /// <returns>Success status</returns>
    [HttpDelete("{channelName}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult EndSession(string channelName)
    {
        _logger.LogInformation("Ending session: {Channel}", channelName);

        var success = _agora.SessionEnd(channelName);

        if (!success)
        {
            return NotFound(new ErrorResponse { Message = $"Session '{channelName}' not found." });
        }

        return Ok(new { Message = $"Session '{channelName}' ended successfully." });
    }
}
