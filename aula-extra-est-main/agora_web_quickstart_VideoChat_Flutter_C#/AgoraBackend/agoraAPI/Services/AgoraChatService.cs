using AgoraBackend.agoraAPI.Models;

namespace AgoraBackend.agoraAPI.Services
{
    /// <summary>
    /// Agora Chat Service with support for real Agora Chat API
    /// Falls back to in-memory storage if Agora Chat is not configured
    /// </summary>
    public interface IAgoraChatService
    {
        Task<LoginResponse> LoginAsync(LoginRequest request);
        Task<AutoLoginResponse> AutoLoginAsync(string userId);
        Task<SendMessageResponse> SendMessageAsync(string userId, SendMessageRequest request);
        Task<bool> LogoutAsync(string userId);
        Task<List<ChatMessage>> GetMessagesAsync(string userId);
        Task<List<ChatConversation>> GetConversationsAsync(string userId);
    }

    public class AgoraChatService : IAgoraChatService
    {
        private readonly IAgoraChatRestClient? _agoraChatClient;
        private readonly List<ChatMessage> _messageStore = new();
        private readonly Dictionary<string, string> _activeUsers = new();
        private readonly HashSet<string> _registeredUsers = new();
        private readonly ILogger<AgoraChatService> _logger;

        public AgoraChatService(
            ILogger<AgoraChatService> logger,
            IAgoraChatRestClient? agoraChatClient = null)
        {
            _logger = logger;
            _agoraChatClient = agoraChatClient;
            
            if (_agoraChatClient != null)
            {
                _logger.LogInformation("✅ AgoraChatService initialized with REAL Agora Chat API");
            }
            else
            {
                _logger.LogWarning("📌 AgoraChatService initialized with IN-MEMORY storage (demo mode)");
            }
        }

        public async Task<AutoLoginResponse> AutoLoginAsync(string userId)
        {
            if (string.IsNullOrEmpty(userId))
            {
                _logger.LogWarning("Auto-login attempt with empty userId");
                return new AutoLoginResponse
                {
                    Success = false,
                    Message = "Invalid userId"
                };
            }

            // ONLY use Agora Chat API - no fallback to local storage
            if (_agoraChatClient == null)
            {
                _logger.LogError("❌ Agora Chat API not configured. Login failed.");
                return new AutoLoginResponse
                {
                    Success = false,
                    Message = "Agora Chat API not configured"
                };
            }

            try
            {
                // Use a default password for authentication
                // (assuming user already exists in Agora with this password)
                var password = $"Pass_{userId}_2026";
                var agoraUser = await _agoraChatClient.AuthenticateUserAsync(userId, password);
                
                if (agoraUser != null)
                {
                    var token = Guid.NewGuid().ToString();
                    var isNewUser = !_registeredUsers.Contains(userId);
                    var message = "User logged in via Agora";
                    
                    // Register user locally for session tracking
                    if (isNewUser)
                    {
                        _registeredUsers.Add(userId);
                    }
                    
                    _activeUsers[userId] = token;
                    
                    _logger.LogInformation($"✅ User {userId} authenticated with Agora Chat API");
                    
                    return new AutoLoginResponse
                    {
                        Success = true,
                        Message = message,
                        UserId = userId,
                        Token = token,
                        IsNewUser = isNewUser
                    };
                }
                else
                {
                    _logger.LogError($"❌ User {userId} authentication failed - invalid credentials or user does not exist in Agora");
                    return new AutoLoginResponse
                    {
                        Success = false,
                        Message = "Authentication failed - user does not exist or invalid password in Agora Chat"
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"❌ Exception during Agora Chat authentication for user {userId}");
                return new AutoLoginResponse
                {
                    Success = false,
                    Message = $"Authentication error: {ex.Message}"
                };
            }
        }

        public Task<LoginResponse> LoginAsync(LoginRequest request)
        {
            // Validate input
            if (string.IsNullOrEmpty(request.UserId) || string.IsNullOrEmpty(request.Token))
            {
                _logger.LogWarning("Login attempt with invalid userId or token");
                return Task.FromResult(new LoginResponse
                {
                    Success = false,
                    Message = "Invalid userId or token"
                });
            }

            // Store active user session
            _activeUsers[request.UserId] = request.Token;
            _logger.LogInformation($"User {request.UserId} logged in successfully");

            return Task.FromResult(new LoginResponse
            {
                Success = true,
                Message = $"User {request.UserId} logged in successfully",
                UserId = request.UserId,
                Token = request.Token
            });
        }

        public async Task<SendMessageResponse> SendMessageAsync(string userId, SendMessageRequest request)
        {
            // Validate
            if (string.IsNullOrEmpty(request.To) || string.IsNullOrEmpty(request.Message))
            {
                _logger.LogWarning($"Invalid send message attempt from {userId}");
                return new SendMessageResponse
                {
                    Success = false,
                    Message = "Invalid recipient or message content"
                };
            }

            // ONLY use Agora Chat API - no fallback to local storage
            if (_agoraChatClient == null)
            {
                _logger.LogError("❌ Agora Chat API not configured. Cannot send message.");
                return new SendMessageResponse
                {
                    Success = false,
                    Message = "Agora Chat API not configured"
                };
            }

            try
            {
                var agoraMessage = await _agoraChatClient.SendMessageAsync(userId, request.To, request.Message);
                
                if (agoraMessage?.Success == true)
                {
                    _logger.LogInformation($"✅ Message sent via Agora Chat API from {userId} to {request.To}");
                    return new SendMessageResponse
                    {
                        Success = true,
                        Message = "Message sent via Agora API",
                        MessageId = agoraMessage.MessageId,
                        Timestamp = DateTime.UtcNow
                    };
                }
                else
                {
                    _logger.LogError($"❌ Failed to send message via Agora Chat API from {userId} to {request.To}");
                    return new SendMessageResponse
                    {
                        Success = false,
                        Message = "Failed to send message via Agora API"
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"❌ Exception sending message via Agora Chat API from {userId} to {request.To}");
                return new SendMessageResponse
                {
                    Success = false,
                    Message = $"Error sending message: {ex.Message}"
                };
            }
        }

        public Task<bool> LogoutAsync(string userId)
        {
            _activeUsers.Remove(userId);
            _logger.LogInformation($"User {userId} logged out");
            return Task.FromResult(true);
        }

        public Task<List<ChatMessage>> GetMessagesAsync(string userId)
        {
            var messages = _messageStore
                .Where(m => m.From == userId || m.To == userId)
                .OrderByDescending(m => m.Timestamp)
                .Take(100)
                .ToList();

            _logger.LogInformation($"Retrieved {messages.Count} messages for user {userId}");
            return Task.FromResult(messages);
        }

        public Task<List<ChatConversation>> GetConversationsAsync(string userId)
        {
            // Get all unique users this user has chatted with
            var conversations = _messageStore
                .Where(m => m.From == userId || m.To == userId)
                .Select(m => m.From == userId ? m.To : m.From)
                .Distinct()
                .Select(otherUserId =>
                {
                    // Get last message with this user
                    var lastMessage = _messageStore
                        .Where(m => (m.From == userId && m.To == otherUserId) || (m.From == otherUserId && m.To == userId))
                        .OrderByDescending(m => m.Timestamp)
                        .FirstOrDefault();

                    // Count unread messages (messages from other user to this user)
                    var unreadCount = _messageStore
                        .Count(m => m.From == otherUserId && m.To == userId);

                    return new ChatConversation
                    {
                        UserId = otherUserId,
                        LastMessage = lastMessage?.Content ?? "",
                        LastMessageTime = lastMessage?.Timestamp ?? DateTime.UtcNow,
                        UnreadCount = unreadCount
                    };
                })
                .OrderByDescending(c => c.LastMessageTime)
                .ToList();

            _logger.LogInformation($"Retrieved {conversations.Count} conversations for user {userId}");
            return Task.FromResult(conversations);
        }
    }
}
