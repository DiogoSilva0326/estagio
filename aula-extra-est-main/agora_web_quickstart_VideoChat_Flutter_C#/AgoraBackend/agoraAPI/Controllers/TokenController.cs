namespace AgoraBackend.agoraAPI.Controllers;

using System.Text;
using System.Text.Json;
using AgoraBackend.agoraAPI.Models;
using AgoraBackend.agoraAPI.Services;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("")]
public class TokenController : ControllerBase
{
    private readonly IRtcTokenService _rtcTokenService;
    private readonly IWhiteboardService _whiteboardService;
    private readonly IRtmTokenService _rtmTokenService;
    private readonly AppConfig _config;

    public TokenController(IRtcTokenService rtcTokenService, IWhiteboardService whiteboardService, IRtmTokenService rtmTokenService, AppConfig config)
    {
        _rtcTokenService = rtcTokenService;
        _whiteboardService = whiteboardService;
        _rtmTokenService = rtmTokenService;
        _config = config;
    }

    [HttpPost("/fetch_rtc_token")]
    public IActionResult FetchRtcToken([FromBody] RtcTokenRequest body)
    {
        try
        {
            if (body is null || string.IsNullOrWhiteSpace(body.ChannelName))
                return BadRequest(new { token = "Bad request: channelName is required", code = StatusCodes.Status400BadRequest.ToString() });

            var role = body.Role switch
            {
                2 => RtcRole.Subscriber,
                _ => RtcRole.Publisher,
            };

            var token = _rtcTokenService.GenerateToken(
                _config.AgoraAppId,
                _config.AgoraAppCertificate,
                body.ChannelName,
                body.Uid,
                role);

            return Ok(new { token, code = StatusCodes.Status200OK.ToString() });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { token = "Erro ao gerar token: " + ex.Message, code = StatusCodes.Status500InternalServerError.ToString() });
        }
    }

    [HttpPost("/fetch_whiteboard_token")]
    public async Task<IActionResult> FetchWhiteboardToken([FromBody] WhiteboardTokenRequest body)
    {
        try
        {
            if (body is null || string.IsNullOrWhiteSpace(body.ChannelName))
                return BadRequest(new { error = "Bad request: channelName is required" });

            var (uuid, roomToken) = await _whiteboardService.GenerateTokenAsync(body.ChannelName);
            return Ok(new { uuid, token = roomToken });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }

    [HttpGet("/fetch_rtm_token")]
    public IActionResult FetchRtmToken([FromQuery] string account)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(account))
                return BadRequest(new { error = "Bad request: account is required" });

            var token = _rtmTokenService.GenerateToken(
                _config.AgoraAppId,
                _config.AgoraAppCertificate,
                account);

            return Ok(new { token });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }
}
