using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator;
using Synget.AgoraIntegrator.API.DTOs;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for managing Whiteboard rooms and tokens.
/// Acts as an agent that delegates to the IAgora library.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class WhiteboardController : ControllerBase
{
    private readonly IAgora _agora;
    private readonly ILogger<WhiteboardController> _logger;

    public WhiteboardController(IAgora agora, ILogger<WhiteboardController> logger)
    {
        _agora = agora;
        _logger = logger;
    }

    /// <summary>
    /// Get or create a whiteboard room token for a channel
    /// </summary>
    /// <param name="request">Whiteboard token request</param>
    /// <returns>Whiteboard room UUID and token</returns>
    [HttpPost("token")]
    [ProducesResponseType(typeof(WhiteboardTokenResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public async Task<ActionResult<WhiteboardTokenResponse>> GetWhiteboardToken([FromBody] WhiteboardTokenRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.ChannelName))
        {
            return BadRequest(new ErrorResponse { Message = "Channel name is required" });
        }

        _logger.LogInformation("Getting whiteboard token for channel: {Channel}, uid: {Uid}", 
            request.ChannelName, request.Uid);

        try
        {
            // Use the library method directly
            var room = await _agora.WhiteboardGetOrCreateRoomAsync(request.ChannelName);

            if (room == null)
            {
                _logger.LogWarning("Failed to get whiteboard room: {Message}", _agora.Message);
                return StatusCode(500, new ErrorResponse { Message = _agora.Message });
            }

            return Ok(new WhiteboardTokenResponse
            {
                Uuid = room.Uuid,
                Token = room.RoomToken,
                ChannelName = request.ChannelName
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get whiteboard token for channel: {Channel}", request.ChannelName);
            return StatusCode(500, new ErrorResponse { Message = ex.Message });
        }
    }

    /// <summary>
    /// Get whiteboard configuration for client-side setup
    /// </summary>
    /// <returns>Whiteboard config with AppIdentifier and Region</returns>
    [HttpGet("config")]
    [ProducesResponseType(typeof(WhiteboardConfigResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status500InternalServerError)]
    public ActionResult<WhiteboardConfigResponse> GetWhiteboardConfig()
    {
        _logger.LogInformation("Getting whiteboard config");

        var config = _agora.WhiteboardGetConfig();

        if (config == null)
        {
            return StatusCode(500, new ErrorResponse { Message = _agora.Message });
        }

        return Ok(new WhiteboardConfigResponse
        {
            AppIdentifier = config.AppIdentifier,
            Region = config.Region
        });
    }

    /// <summary>
    /// Legacy endpoint for backward compatibility with existing clients
    /// </summary>
    [HttpPost("/fetch_whiteboard_token")]
    [ProducesResponseType(typeof(WhiteboardTokenResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<WhiteboardTokenResponse>> FetchWhiteboardTokenLegacy([FromBody] WhiteboardTokenRequest request)
    {
        return await GetWhiteboardToken(request);
    }
}
