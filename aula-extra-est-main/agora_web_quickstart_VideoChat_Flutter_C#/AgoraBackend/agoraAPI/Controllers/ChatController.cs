using Microsoft.AspNetCore.Mvc;
using AgoraBackend.agoraAPI.Models;
using AgoraBackend.agoraAPI.Services;

namespace AgoraBackend.agoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private readonly IAgoraChatService _chatService;
        private readonly ILogger<ChatController> _logger;

        public ChatController(IAgoraChatService chatService, ILogger<ChatController> logger)
        {
            _chatService = chatService;
            _logger = logger;
        }

        /// <summary>
        /// Login user to Agora Chat
        /// </summary>
        [HttpPost("login")]
        public async Task<ActionResult<ApiResponse<LoginResponse>>> Login([FromBody] LoginRequest request)
        {
            try
            {
                var response = await _chatService.LoginAsync(request);
                
                if (!response.Success)
                {
                    return BadRequest(new ApiResponse<LoginResponse>
                    {
                        Success = false,
                        Message = response.Message
                    });
                }

                _logger.LogInformation($"User {request.UserId} logged in successfully");

                return Ok(new ApiResponse<LoginResponse>
                {
                    Success = true,
                    Message = response.Message,
                    Data = response
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Login error: {ex.Message}");
                return StatusCode(500, new ApiResponse<LoginResponse>
                {
                    Success = false,
                    Message = "Login failed: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Send a message to another user
        /// </summary>
        [HttpPost("send")]
        public async Task<ActionResult<ApiResponse<SendMessageResponse>>> SendMessage(
            [FromQuery] string userId,
            [FromBody] SendMessageRequest request)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    return BadRequest(new ApiResponse<SendMessageResponse>
                    {
                        Success = false,
                        Message = "UserId is required"
                    });
                }

                var response = await _chatService.SendMessageAsync(userId, request);

                if (!response.Success)
                {
                    return BadRequest(new ApiResponse<SendMessageResponse>
                    {
                        Success = false,
                        Message = response.Message
                    });
                }

                _logger.LogInformation($"Message sent from {userId} to {request.To}");

                return Ok(new ApiResponse<SendMessageResponse>
                {
                    Success = true,
                    Message = response.Message,
                    Data = response
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Send message error: {ex.Message}");
                return StatusCode(500, new ApiResponse<SendMessageResponse>
                {
                    Success = false,
                    Message = "Send failed: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Get all messages for a user
        /// </summary>
        [HttpGet("messages")]
        public async Task<ActionResult<ApiResponse<List<ChatMessage>>>> GetMessages([FromQuery] string userId)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    return BadRequest(new ApiResponse<List<ChatMessage>>
                    {
                        Success = false,
                        Message = "UserId is required"
                    });
                }

                var messages = await _chatService.GetMessagesAsync(userId);

                return Ok(new ApiResponse<List<ChatMessage>>
                {
                    Success = true,
                    Message = "Messages retrieved successfully",
                    Data = messages
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Get messages error: {ex.Message}");
                return StatusCode(500, new ApiResponse<List<ChatMessage>>
                {
                    Success = false,
                    Message = "Failed to retrieve messages: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Logout user
        /// </summary>
        [HttpPost("logout")]
        public async Task<ActionResult<ApiResponse<bool>>> Logout([FromQuery] string userId)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "UserId is required"
                    });
                }

                var result = await _chatService.LogoutAsync(userId);

                _logger.LogInformation($"User {userId} logged out");

                return Ok(new ApiResponse<bool>
                {
                    Success = result,
                    Message = "Logged out successfully",
                    Data = result
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Logout error: {ex.Message}");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Logout failed: " + ex.Message
                });
            }
        }
    }
}
