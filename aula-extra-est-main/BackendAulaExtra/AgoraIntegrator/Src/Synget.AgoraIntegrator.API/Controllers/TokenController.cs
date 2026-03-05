using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator;
using Synget.AgoraIntegrator.API.DTOs;
using Synget.AgoraIntegrator.Models;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for generating Agora tokens (RTC and RTM)
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class TokenController : ControllerBase
{
    private readonly IAgora _agora;
    private readonly ILogger<TokenController> _logger;

    public TokenController(IAgora agora, ILogger<TokenController> logger)
    {
        _agora = agora;
        _logger = logger;
    }

    /// <summary>
    /// Generates an RTC token for video/audio communication
    /// </summary>
    /// <param name="request">Token request parameters</param>
    /// <returns>RTC token response</returns>
    [HttpPost("rtc")]
    [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public ActionResult<TokenResponse> GenerateRtcToken([FromBody] RtcTokenRequest request)
    {
        _logger.LogInformation("Generating RTC token for channel: {Channel}, user: {User}", 
            request.ChannelName, request.Uid);

        // Parse UID to uint (0 for dynamic assignment if not a valid number)
        uint.TryParse(request.Uid, out var uid);

        var tokenResult = _agora.RtcTokenGenerate(request.ChannelName, uid, AgoraRtcRole.Publisher);

        if (tokenResult is null || string.IsNullOrEmpty(tokenResult.Token))
        {
            _logger.LogWarning("Failed to generate RTC token: {Message}", _agora.Message);
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        return Ok(new TokenResponse 
        { 
            Token = tokenResult.Token, 
            ChannelName = request.ChannelName,
            Uid = request.Uid,
            TokenType = "RTC"
        });
    }

    /// <summary>
    /// Generates an RTM token for real-time messaging
    /// </summary>
    /// <param name="request">Token request parameters</param>
    /// <returns>RTM token response</returns>
    [HttpPost("rtm")]
    [ProducesResponseType(typeof(TokenResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public ActionResult<TokenResponse> GenerateRtmToken([FromBody] RtmTokenRequest request)
    {
        _logger.LogInformation("Generating RTM token for user: {User}", request.UserId);

        var tokenResult = _agora.RtmTokenGenerate(request.UserId);

        if (tokenResult is null || string.IsNullOrEmpty(tokenResult.Token))
        {
            _logger.LogWarning("Failed to generate RTM token: {Message}", _agora.Message);
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        return Ok(new TokenResponse 
        { 
            Token = tokenResult.Token, 
            Uid = request.UserId,
            TokenType = "RTM"
        });
    }

    /// <summary>
    /// Generates a token for screen sharing.
    /// Uses a special UID convention: screenShareUid = baseUid * 100 + 99
    /// </summary>
    /// <param name="request">Screen share token request</param>
    /// <returns>Screen share token response with calculated UID</returns>
    [HttpPost("screenshare")]
    [ProducesResponseType(typeof(ScreenShareTokenResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public ActionResult<ScreenShareTokenResponse> GenerateScreenShareToken([FromBody] ScreenShareTokenRequest request)
    {
        _logger.LogInformation("Generating screen share token for channel: {Channel}, baseUid: {BaseUid}", 
            request.ChannelName, request.BaseUid);

        var tokenResult = _agora.ScreenShareTokenGenerate(request.ChannelName, request.BaseUid);

        if (tokenResult is null || string.IsNullOrEmpty(tokenResult.Token))
        {
            _logger.LogWarning("Failed to generate screen share token: {Message}", _agora.Message);
            return BadRequest(new ErrorResponse { Message = _agora.Message });
        }

        var screenShareUid = _agora.ScreenShareUidCalculate(request.BaseUid);

        return Ok(new ScreenShareTokenResponse 
        { 
            Token = tokenResult.Token, 
            ChannelName = request.ChannelName,
            ScreenShareUid = screenShareUid,
            BaseUid = request.BaseUid
        });
    }

    /// <summary>
    /// Check if a UID is a screen share UID
    /// </summary>
    /// <param name="uid">The UID to check</param>
    /// <returns>True if the UID is a screen share UID</returns>
    [HttpGet("screenshare/check/{uid}")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    public ActionResult<object> CheckScreenShareUid(uint uid)
    {
        var isScreenShare = _agora.ScreenShareUidCheck(uid);
        return Ok(new { uid, isScreenShare });
    }
}
