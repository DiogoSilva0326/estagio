using AgoraBackend.agoraAPI.Models;
using System.Text;
using System.Text.Json;

namespace AgoraBackend.agoraAPI.Services
{
    public interface ISessionStorageService
    {
        Task<SaveSnapshotResponse> SaveWhiteboardSnapshotAsync(SaveWhiteboardSnapshotRequest request);
        Task<SaveSnapshotResponse> SaveChatMessagesAsync(SaveChatMessagesRequest request);
        Task<bool> UpdateSessionInfoAsync(UpdateSessionInfoRequest request);
        Task<GetSessionInfoResponse> GetSessionInfoAsync(string channelName, string sessionId);
        Task<List<string>> GetChannelSessionsAsync(string channelName);
    }

    public class SessionStorageService : ISessionStorageService
    {
        private readonly ILogger<SessionStorageService> _logger;
        private readonly string _baseStoragePath;
        private readonly Dictionary<string, SessionInfo> _activeSessions = new();

        public SessionStorageService(ILogger<SessionStorageService> logger, IConfiguration configuration)
        {
            _logger = logger;
            
            // Base path for storage (simulating database with file system)
            var basePath = configuration["SessionStorage:BasePath"];
            _baseStoragePath = string.IsNullOrEmpty(basePath) 
                ? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "sessions")
                : basePath;

            // Ensure base directory exists
            if (!Directory.Exists(_baseStoragePath))
            {
                Directory.CreateDirectory(_baseStoragePath);
                _logger.LogInformation($"Created session storage directory: {_baseStoragePath}");
            }
        }

        private string GetSessionDirectory(string channelName, string sessionId)
        {
            // Structure: wwwroot/sessions/{channelName}/{sessionId}/
            var channelDir = Path.Combine(_baseStoragePath, SanitizeFileName(channelName));
            var sessionDir = Path.Combine(channelDir, sessionId);
            
            if (!Directory.Exists(sessionDir))
            {
                Directory.CreateDirectory(sessionDir);
                _logger.LogInformation($"Created session directory: {sessionDir}");
            }
            
            return sessionDir;
        }

        private string GetOrCreateSessionId(string channelName)
        {
            var activeKey = $"{channelName}_active";
            
            if (_activeSessions.ContainsKey(activeKey))
            {
                return _activeSessions[activeKey].SessionId;
            }

            // Create new session
            var sessionId = $"{DateTime.UtcNow:yyyyMMdd_HHmmss}";
            var sessionInfo = new SessionInfo
            {
                SessionId = sessionId,
                ChannelName = channelName,
                StartTime = DateTime.UtcNow,
                Users = new List<string>(),
                UserJoinedTimes = new List<string>(),
                UserLeftTimes = new List<string>()
            };

            _activeSessions[activeKey] = sessionInfo;
            _logger.LogInformation($"Created new session: {sessionId} for channel: {channelName}");

            return sessionId;
        }

        public async Task<SaveSnapshotResponse> SaveWhiteboardSnapshotAsync(SaveWhiteboardSnapshotRequest request)
        {
            try
            {
                if (string.IsNullOrEmpty(request.ChannelName) || string.IsNullOrEmpty(request.ImageDataBase64))
                {
                    return new SaveSnapshotResponse
                    {
                        Success = false,
                        Message = "Channel name and image data are required"
                    };
                }

                var sessionId = GetOrCreateSessionId(request.ChannelName);
                var sessionDir = GetSessionDirectory(request.ChannelName, sessionId);
                
                // Create whiteboard subdirectory
                var whiteboardDir = Path.Combine(sessionDir, "whiteboard");
                if (!Directory.Exists(whiteboardDir))
                {
                    Directory.CreateDirectory(whiteboardDir);
                }

                // Generate filename with timestamp and reason
                var timestamp = DateTime.UtcNow.ToString("HHmmss_fff");
                var reason = string.IsNullOrEmpty(request.Reason) ? "manual" : request.Reason;
                var filename = $"page_{request.PageNumber}_{reason}_{timestamp}.png";
                var filePath = Path.Combine(whiteboardDir, filename);

                // Decode base64 and save image
                var imageData = Convert.FromBase64String(request.ImageDataBase64);
                await File.WriteAllBytesAsync(filePath, imageData);

                // Update session info
                await UpdateWhiteboardCountAsync(request.ChannelName, sessionId);

                _logger.LogInformation($"Saved whiteboard snapshot: {filename} for channel: {request.ChannelName}");

                return new SaveSnapshotResponse
                {
                    Success = true,
                    Message = "Whiteboard snapshot saved successfully",
                    FilePath = filePath,
                    SessionId = sessionId
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error saving whiteboard snapshot: {ex.Message}");
                return new SaveSnapshotResponse
                {
                    Success = false,
                    Message = $"Failed to save snapshot: {ex.Message}"
                };
            }
        }

        public async Task<SaveSnapshotResponse> SaveChatMessagesAsync(SaveChatMessagesRequest request)
        {
            try
            {
                if (string.IsNullOrEmpty(request.ChannelName) || request.Messages == null || !request.Messages.Any())
                {
                    return new SaveSnapshotResponse
                    {
                        Success = false,
                        Message = "Channel name and messages are required"
                    };
                }

                var sessionId = GetOrCreateSessionId(request.ChannelName);
                var sessionDir = GetSessionDirectory(request.ChannelName, sessionId);
                
                // Create chat subdirectory
                var chatDir = Path.Combine(sessionDir, "chat");
                if (!Directory.Exists(chatDir))
                {
                    Directory.CreateDirectory(chatDir);
                }

                // Generate filename with timestamp
                var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss");
                var filename = $"chat_messages_{timestamp}.txt";
                var filePath = Path.Combine(chatDir, filename);

                // Format messages as text
                var sb = new StringBuilder();
                sb.AppendLine($"=== Chat Messages - {request.ChannelName} ===");
                sb.AppendLine($"Session ID: {sessionId}");
                sb.AppendLine($"Saved at: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");
                sb.AppendLine($"Active Users: {string.Join(", ", request.ActiveUsers)}");
                sb.AppendLine($"Total Messages: {request.Messages.Count}");
                sb.AppendLine(new string('=', 60));
                sb.AppendLine();

                foreach (var msg in request.Messages.OrderBy(m => m.Timestamp))
                {
                    sb.AppendLine($"[{msg.Timestamp:yyyy-MM-dd HH:mm:ss}] {msg.UserId}:");
                    sb.AppendLine($"  {msg.Message}");
                    sb.AppendLine();
                }

                await File.WriteAllTextAsync(filePath, sb.ToString());

                // Update session info
                await UpdateChatCountAsync(request.ChannelName, sessionId, request.Messages.Count);

                _logger.LogInformation($"Saved {request.Messages.Count} chat messages to: {filename} for channel: {request.ChannelName}");

                return new SaveSnapshotResponse
                {
                    Success = true,
                    Message = "Chat messages saved successfully",
                    FilePath = filePath,
                    SessionId = sessionId
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error saving chat messages: {ex.Message}");
                return new SaveSnapshotResponse
                {
                    Success = false,
                    Message = $"Failed to save chat: {ex.Message}"
                };
            }
        }

        public async Task<bool> UpdateSessionInfoAsync(UpdateSessionInfoRequest request)
        {
            try
            {
                var sessionId = GetOrCreateSessionId(request.ChannelName);
                var activeKey = $"{request.ChannelName}_active";

                if (!_activeSessions.ContainsKey(activeKey))
                {
                    _logger.LogWarning($"Session not found for channel: {request.ChannelName}");
                    return false;
                }

                var sessionInfo = _activeSessions[activeKey];
                var timestamp = DateTime.UtcNow;

                switch (request.Action)
                {
                    case "user_joined":
                        foreach (var user in request.Users.Where(u => !sessionInfo.Users.Contains(u)))
                        {
                            sessionInfo.Users.Add(user);
                            sessionInfo.UserJoinedTimes.Add($"{user}: {timestamp:yyyy-MM-dd HH:mm:ss}");
                        }
                        break;

                    case "user_left":
                        foreach (var user in request.Users)
                        {
                            sessionInfo.UserLeftTimes.Add($"{user}: {timestamp:yyyy-MM-dd HH:mm:ss}");
                        }
                        break;

                    case "session_ended":
                        sessionInfo.EndTime = timestamp;
                        await SaveSessionInfoToFileAsync(request.ChannelName, sessionInfo);
                        _activeSessions.Remove(activeKey);
                        break;
                }

                // Save updated session info
                await SaveSessionInfoToFileAsync(request.ChannelName, sessionInfo);

                _logger.LogInformation($"Updated session info for channel: {request.ChannelName}, action: {request.Action}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating session info: {ex.Message}");
                return false;
            }
        }

        private async Task SaveSessionInfoToFileAsync(string channelName, SessionInfo sessionInfo)
        {
            try
            {
                var sessionDir = GetSessionDirectory(channelName, sessionInfo.SessionId);
                var infoPath = Path.Combine(sessionDir, "session_info.json");

                var json = JsonSerializer.Serialize(sessionInfo, new JsonSerializerOptions 
                { 
                    WriteIndented = true 
                });

                await File.WriteAllTextAsync(infoPath, json);

                // Also create a readable text version
                var txtPath = Path.Combine(sessionDir, "session_info.txt");
                var sb = new StringBuilder();
                sb.AppendLine($"=== Session Information ===");
                sb.AppendLine($"Session ID: {sessionInfo.SessionId}");
                sb.AppendLine($"Channel: {sessionInfo.ChannelName}");
                sb.AppendLine($"Start Time: {sessionInfo.StartTime:yyyy-MM-dd HH:mm:ss} UTC");
                if (sessionInfo.EndTime.HasValue)
                {
                    sb.AppendLine($"End Time: {sessionInfo.EndTime.Value:yyyy-MM-dd HH:mm:ss} UTC");
                    var duration = sessionInfo.EndTime.Value - sessionInfo.StartTime;
                    sb.AppendLine($"Duration: {duration.Hours}h {duration.Minutes}m {duration.Seconds}s");
                }
                sb.AppendLine();
                sb.AppendLine($"Participants ({sessionInfo.Users.Count}):");
                foreach (var user in sessionInfo.Users)
                {
                    sb.AppendLine($"  - {user}");
                }
                sb.AppendLine();
                if (sessionInfo.UserJoinedTimes.Any())
                {
                    sb.AppendLine("Join History:");
                    foreach (var entry in sessionInfo.UserJoinedTimes)
                    {
                        sb.AppendLine($"  {entry}");
                    }
                    sb.AppendLine();
                }
                if (sessionInfo.UserLeftTimes.Any())
                {
                    sb.AppendLine("Leave History:");
                    foreach (var entry in sessionInfo.UserLeftTimes)
                    {
                        sb.AppendLine($"  {entry}");
                    }
                    sb.AppendLine();
                }
                sb.AppendLine($"Whiteboard Pages Saved: {sessionInfo.WhiteboardPagesCount}");
                sb.AppendLine($"Chat Messages Saved: {sessionInfo.ChatMessagesCount}");

                await File.WriteAllTextAsync(txtPath, sb.ToString());
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error saving session info to file: {ex.Message}");
            }
        }

        private async Task UpdateWhiteboardCountAsync(string channelName, string sessionId)
        {
            var activeKey = $"{channelName}_active";
            if (_activeSessions.ContainsKey(activeKey))
            {
                _activeSessions[activeKey].WhiteboardPagesCount++;
                await SaveSessionInfoToFileAsync(channelName, _activeSessions[activeKey]);
            }
        }

        private async Task UpdateChatCountAsync(string channelName, string sessionId, int messageCount)
        {
            var activeKey = $"{channelName}_active";
            if (_activeSessions.ContainsKey(activeKey))
            {
                _activeSessions[activeKey].ChatMessagesCount += messageCount;
                await SaveSessionInfoToFileAsync(channelName, _activeSessions[activeKey]);
            }
        }

        public async Task<GetSessionInfoResponse> GetSessionInfoAsync(string channelName, string sessionId)
        {
            try
            {
                var sessionDir = GetSessionDirectory(channelName, sessionId);
                var infoPath = Path.Combine(sessionDir, "session_info.json");

                if (!File.Exists(infoPath))
                {
                    return new GetSessionInfoResponse
                    {
                        Success = false,
                        Message = "Session info not found"
                    };
                }

                var json = await File.ReadAllTextAsync(infoPath);
                var sessionInfo = JsonSerializer.Deserialize<SessionInfo>(json);

                // Get whiteboard images
                var whiteboardDir = Path.Combine(sessionDir, "whiteboard");
                var whiteboardImages = Directory.Exists(whiteboardDir)
                    ? Directory.GetFiles(whiteboardDir, "*.png").Select(Path.GetFileName).ToList()
                    : new List<string>();

                // Get chat files
                var chatDir = Path.Combine(sessionDir, "chat");
                var chatFiles = Directory.Exists(chatDir)
                    ? Directory.GetFiles(chatDir, "*.txt").Select(Path.GetFileName).ToList()
                    : new List<string>();

                return new GetSessionInfoResponse
                {
                    Success = true,
                    Message = "Session info retrieved successfully",
                    SessionInfo = sessionInfo,
                    WhiteboardImages = whiteboardImages,
                    ChatFiles = chatFiles
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting session info: {ex.Message}");
                return new GetSessionInfoResponse
                {
                    Success = false,
                    Message = $"Failed to get session info: {ex.Message}"
                };
            }
        }

        public async Task<List<string>> GetChannelSessionsAsync(string channelName)
        {
            try
            {
                var channelDir = Path.Combine(_baseStoragePath, SanitizeFileName(channelName));
                
                if (!Directory.Exists(channelDir))
                {
                    return new List<string>();
                }

                var sessions = Directory.GetDirectories(channelDir)
                    .Select(Path.GetFileName)
                    .OrderByDescending(s => s)
                    .ToList();

                return await Task.FromResult(sessions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting channel sessions: {ex.Message}");
                return new List<string>();
            }
        }

        private string SanitizeFileName(string fileName)
        {
            var invalidChars = Path.GetInvalidFileNameChars();
            return new string(fileName.Select(c => invalidChars.Contains(c) ? '_' : c).ToArray());
        }
    }
}
