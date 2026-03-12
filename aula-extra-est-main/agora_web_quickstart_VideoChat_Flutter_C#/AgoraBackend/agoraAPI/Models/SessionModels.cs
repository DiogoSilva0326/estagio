namespace AgoraBackend.agoraAPI.Models
{
    // Request Models
    public class SaveWhiteboardSnapshotRequest
    {
        public string ChannelName { get; set; } = string.Empty;
        public string ImageDataBase64 { get; set; } = string.Empty;
        public int PageNumber { get; set; } = 1;
        public string Reason { get; set; } = string.Empty; // "page_change", "clear", "session_end"
        public List<string> ActiveUsers { get; set; } = new();
    }

    public class SaveChatMessagesRequest
    {
        public string ChannelName { get; set; } = string.Empty;
        public List<ChatMessageEntry> Messages { get; set; } = new();
        public List<string> ActiveUsers { get; set; } = new();
    }

    public class ChatMessageEntry
    {
        public string UserId { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
    }

    public class UpdateSessionInfoRequest
    {
        public string ChannelName { get; set; } = string.Empty;
        public List<string> Users { get; set; } = new();
        public string Action { get; set; } = string.Empty; // "user_joined", "user_left", "session_started", "session_ended"
    }

    // Response Models
    public class SaveSnapshotResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string FilePath { get; set; } = string.Empty;
        public string SessionId { get; set; } = string.Empty;
    }

    public class SessionInfo
    {
        public string SessionId { get; set; } = string.Empty;
        public string ChannelName { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public List<string> Users { get; set; } = new();
        public List<string> UserJoinedTimes { get; set; } = new();
        public List<string> UserLeftTimes { get; set; } = new();
        public int WhiteboardPagesCount { get; set; }
        public int ChatMessagesCount { get; set; }
    }

    public class GetSessionInfoResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public SessionInfo? SessionInfo { get; set; }
        public List<string> WhiteboardImages { get; set; } = new();
        public List<string> ChatFiles { get; set; } = new();
    }
}
