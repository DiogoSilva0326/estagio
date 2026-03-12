using Microsoft.AspNetCore.Mvc;
using AgoraBackend.agoraAPI.Models;
using AgoraBackend.agoraAPI.Services;

namespace AgoraBackend.agoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SessionController : ControllerBase
    {
        private readonly ISessionStorageService _sessionService;
        private readonly ILogger<SessionController> _logger;

        public SessionController(ISessionStorageService sessionService, ILogger<SessionController> logger)
        {
            _sessionService = sessionService;
            _logger = logger;
        }

        /// <summary>
        /// Save whiteboard snapshot as image
        /// </summary>
        [HttpPost("whiteboard/snapshot")]
        public async Task<ActionResult<ApiResponse<SaveSnapshotResponse>>> SaveWhiteboardSnapshot(
            [FromBody] SaveWhiteboardSnapshotRequest request)
        {
            try
            {
                var response = await _sessionService.SaveWhiteboardSnapshotAsync(request);

                if (!response.Success)
                {
                    return BadRequest(new ApiResponse<SaveSnapshotResponse>
                    {
                        Success = false,
                        Message = response.Message
                    });
                }

                _logger.LogInformation($"Whiteboard snapshot saved for channel: {request.ChannelName}");

                return Ok(new ApiResponse<SaveSnapshotResponse>
                {
                    Success = true,
                    Message = response.Message,
                    Data = response
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error saving whiteboard snapshot: {ex.Message}");
                return StatusCode(500, new ApiResponse<SaveSnapshotResponse>
                {
                    Success = false,
                    Message = "Failed to save whiteboard snapshot: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Save chat messages to text file
        /// </summary>
        [HttpPost("chat/save")]
        public async Task<ActionResult<ApiResponse<SaveSnapshotResponse>>> SaveChatMessages(
            [FromBody] SaveChatMessagesRequest request)
        {
            try
            {
                var response = await _sessionService.SaveChatMessagesAsync(request);

                if (!response.Success)
                {
                    return BadRequest(new ApiResponse<SaveSnapshotResponse>
                    {
                        Success = false,
                        Message = response.Message
                    });
                }

                _logger.LogInformation($"Chat messages saved for channel: {request.ChannelName}");

                return Ok(new ApiResponse<SaveSnapshotResponse>
                {
                    Success = true,
                    Message = response.Message,
                    Data = response
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error saving chat messages: {ex.Message}");
                return StatusCode(500, new ApiResponse<SaveSnapshotResponse>
                {
                    Success = false,
                    Message = "Failed to save chat messages: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Update session information (user joined, left, session ended)
        /// </summary>
        [HttpPost("info/update")]
        public async Task<ActionResult<ApiResponse<bool>>> UpdateSessionInfo(
            [FromBody] UpdateSessionInfoRequest request)
        {
            try
            {
                var success = await _sessionService.UpdateSessionInfoAsync(request);

                if (!success)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Failed to update session info"
                    });
                }

                _logger.LogInformation($"Session info updated for channel: {request.ChannelName}, action: {request.Action}");

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Session info updated successfully",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating session info: {ex.Message}");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Failed to update session info: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Get session information and files
        /// </summary>
        [HttpGet("info")]
        public async Task<ActionResult<ApiResponse<GetSessionInfoResponse>>> GetSessionInfo(
            [FromQuery] string channelName,
            [FromQuery] string sessionId)
        {
            try
            {
                if (string.IsNullOrEmpty(channelName) || string.IsNullOrEmpty(sessionId))
                {
                    return BadRequest(new ApiResponse<GetSessionInfoResponse>
                    {
                        Success = false,
                        Message = "Channel name and session ID are required"
                    });
                }

                var response = await _sessionService.GetSessionInfoAsync(channelName, sessionId);

                if (!response.Success)
                {
                    return NotFound(new ApiResponse<GetSessionInfoResponse>
                    {
                        Success = false,
                        Message = response.Message
                    });
                }

                return Ok(new ApiResponse<GetSessionInfoResponse>
                {
                    Success = true,
                    Message = response.Message,
                    Data = response
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting session info: {ex.Message}");
                return StatusCode(500, new ApiResponse<GetSessionInfoResponse>
                {
                    Success = false,
                    Message = "Failed to get session info: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Get all sessions for a channel
        /// </summary>
        [HttpGet("channel/sessions")]
        public async Task<ActionResult<ApiResponse<List<string>>>> GetChannelSessions(
            [FromQuery] string channelName)
        {
            try
            {
                if (string.IsNullOrEmpty(channelName))
                {
                    return BadRequest(new ApiResponse<List<string>>
                    {
                        Success = false,
                        Message = "Channel name is required"
                    });
                }

                var sessions = await _sessionService.GetChannelSessionsAsync(channelName);

                return Ok(new ApiResponse<List<string>>
                {
                    Success = true,
                    Message = "Channel sessions retrieved successfully",
                    Data = sessions
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting channel sessions: {ex.Message}");
                return StatusCode(500, new ApiResponse<List<string>>
                {
                    Success = false,
                    Message = "Failed to get channel sessions: " + ex.Message
                });
            }
        }
    }
}
