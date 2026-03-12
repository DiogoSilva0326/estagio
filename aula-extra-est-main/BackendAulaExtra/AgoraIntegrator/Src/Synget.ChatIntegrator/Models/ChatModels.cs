namespace Synget.ChatIntegrator
{
    /// <summary>
    /// Configuration for the chat service.
    /// </summary>
    public class ChatConfig
    {
        /// <summary>
        /// Maximum number of messages to retain per room.
        /// </summary>
        public int MaxMessagesPerRoom { get; set; } = 1000;

        /// <summary>
        /// Whether to persist messages (future: database storage).
        /// </summary>
        public bool PersistMessages { get; set; } = false;

        /// <summary>
        /// Message retention period in hours (0 = indefinite while room is active).
        /// </summary>
        public int MessageRetentionHours { get; set; } = 24;
    }

    /// <summary>
    /// Represents a chat room associated with a video call channel.
    /// </summary>
    public class ChatRoom
    {
        /// <summary>
        /// Unique room ID (auto-generated).
        /// </summary>
        public string RoomId { get; set; } = Guid.NewGuid().ToString("N");

        /// <summary>
        /// The channel name this room is associated with.
        /// </summary>
        public string ChannelName { get; set; } = string.Empty;

        /// <summary>
        /// When the room was created.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Current participants in the room.
        /// </summary>
        public List<ChatParticipant> Participants { get; set; } = new();

        /// <summary>
        /// Message history for this room.
        /// </summary>
        public List<ChatMessage> Messages { get; set; } = new();

        /// <summary>
        /// Whether the room is currently active.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Total number of messages sent in this room.
        /// </summary>
        public int TotalMessageCount { get; set; } = 0;
    }

    /// <summary>
    /// Represents a participant in a chat room.
    /// </summary>
    public class ChatParticipant
    {
        /// <summary>
        /// The user's unique identifier.
        /// </summary>
        public string UserId { get; set; } = string.Empty;

        /// <summary>
        /// The user's display name.
        /// </summary>
        public string DisplayName { get; set; } = string.Empty;

        /// <summary>
        /// The SignalR connection ID for this participant.
        /// </summary>
        public string ConnectionId { get; set; } = string.Empty;

        /// <summary>
        /// When the participant joined.
        /// </summary>
        public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Whether the participant is currently connected.
        /// </summary>
        public bool IsConnected { get; set; } = true;

        /// <summary>
        /// The channel name this participant is in.
        /// </summary>
        public string ChannelName { get; set; } = string.Empty;
    }

    /// <summary>
    /// Represents a chat message.
    /// </summary>
    public class ChatMessage
    {
        /// <summary>
        /// Unique message ID.
        /// </summary>
        public string MessageId { get; set; } = Guid.NewGuid().ToString("N");

        /// <summary>
        /// The channel/room this message belongs to.
        /// </summary>
        public string ChannelName { get; set; } = string.Empty;

        /// <summary>
        /// The sender's user ID.
        /// </summary>
        public string SenderId { get; set; } = string.Empty;

        /// <summary>
        /// The sender's display name at time of sending.
        /// </summary>
        public string SenderName { get; set; } = string.Empty;

        /// <summary>
        /// The message content.
        /// </summary>
        public string Content { get; set; } = string.Empty;

        /// <summary>
        /// When the message was sent.
        /// </summary>
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Message type (text, system, etc.).
        /// </summary>
        public ChatMessageType Type { get; set; } = ChatMessageType.Text;

        /// <summary>
        /// Optional metadata (e.g., reply-to message ID).
        /// </summary>
        public Dictionary<string, string> Metadata { get; set; } = new();

        /// <summary>
        /// File attachment (if Type is Attachment).
        /// </summary>
        public FileAttachment? Attachment { get; set; }
    }

    /// <summary>
    /// Types of chat messages.
    /// </summary>
    public enum ChatMessageType
    {
        /// <summary>
        /// Regular text message.
        /// </summary>
        Text = 0,

        /// <summary>
        /// System message (user joined, left, etc.).
        /// </summary>
        System = 1,

        /// <summary>
        /// File/media attachment.
        /// </summary>
        Attachment = 2,

        /// <summary>
        /// Reaction/emoji to another message.
        /// </summary>
        Reaction = 3
    }

    /// <summary>
    /// Types of chat rooms.
    /// </summary>
    public enum ChatRoomType
    {
        /// <summary>
        /// Associated with a video call channel.
        /// </summary>
        VideoCall = 0,

        /// <summary>
        /// Direct message (1-to-1) conversation.
        /// </summary>
        DirectMessage = 1,

        /// <summary>
        /// Group chat with multiple participants.
        /// </summary>
        Group = 2
    }

    /// <summary>
    /// Represents a user contact.
    /// </summary>
    public class Contact
    {
        /// <summary>
        /// The owner of this contact entry.
        /// </summary>
        public string OwnerId { get; set; } = string.Empty;

        /// <summary>
        /// The contact's user ID.
        /// </summary>
        public string ContactUserId { get; set; } = string.Empty;

        /// <summary>
        /// Display name for this contact.
        /// </summary>
        public string DisplayName { get; set; } = string.Empty;

        /// <summary>
        /// Optional nickname for this contact.
        /// </summary>
        public string? Nickname { get; set; }

        /// <summary>
        /// When this contact was added.
        /// </summary>
        public DateTime AddedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Whether this contact is blocked.
        /// </summary>
        public bool IsBlocked { get; set; } = false;

        /// <summary>
        /// Whether this contact request is pending acceptance.
        /// </summary>
        public bool IsPending { get; set; } = false;
    }

    /// <summary>
    /// Extended room with type information for standalone chats.
    /// </summary>
    public class StandaloneChatRoom : ChatRoom
    {
        /// <summary>
        /// Type of chat room.
        /// </summary>
        public ChatRoomType RoomType { get; set; } = ChatRoomType.DirectMessage;

        /// <summary>
        /// For group chats, the name of the group.
        /// </summary>
        public string? GroupName { get; set; }

        /// <summary>
        /// For group chats, optional description.
        /// </summary>
        public string? GroupDescription { get; set; }

        /// <summary>
        /// The user who created this room.
        /// </summary>
        public string CreatorUserId { get; set; } = string.Empty;

        /// <summary>
        /// Participant user IDs for this room (persisted even when not connected).
        /// </summary>
        public List<string> MemberUserIds { get; set; } = new();

        /// <summary>
        /// Get a unique room ID for a 1-to-1 chat between two users.
        /// </summary>
        public static string GetDirectMessageRoomId(string userId1, string userId2)
        {
            // Sort to ensure consistent room ID regardless of order
            var sorted = new[] { userId1, userId2 }.OrderBy(x => x).ToArray();
            return $"dm_{sorted[0]}_{sorted[1]}";
        }
    }

    #region Result DTOs for Hub Operations

    /// <summary>
    /// Result returned when a user joins a room.
    /// Contains everything needed to send to the caller and broadcast to others.
    /// </summary>
    public class JoinRoomResult
    {
        /// <summary>
        /// Whether the join was successful.
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Error message if not successful.
        /// </summary>
        public string? Error { get; set; }

        /// <summary>
        /// The channel name.
        /// </summary>
        public string ChannelName { get; set; } = string.Empty;

        /// <summary>
        /// Message history to send to the joining user.
        /// </summary>
        public List<MessageDto> Messages { get; set; } = new();

        /// <summary>
        /// Current participants in the room.
        /// </summary>
        public List<ParticipantDto> Participants { get; set; } = new();

        /// <summary>
        /// Info about the user who joined (for broadcast to others).
        /// </summary>
        public UserEventDto? UserEvent { get; set; }
    }

    /// <summary>
    /// Result returned when a user leaves a room.
    /// </summary>
    public class LeaveRoomResult
    {
        /// <summary>
        /// Whether the leave was successful.
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Info about the user who left (for broadcast).
        /// </summary>
        public UserEventDto? UserEvent { get; set; }
    }

    /// <summary>
    /// Result returned when a message is sent.
    /// </summary>
    public class SendMessageResult
    {
        /// <summary>
        /// Whether the message was sent successfully.
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Error message if not successful.
        /// </summary>
        public string? Error { get; set; }

        /// <summary>
        /// The message DTO to broadcast.
        /// </summary>
        public MessageDto? Message { get; set; }
    }

    /// <summary>
    /// DTO for a chat message (ready for JSON serialization).
    /// </summary>
    public class MessageDto
    {
        public string MessageId { get; set; } = string.Empty;
        public string SenderId { get; set; } = string.Empty;
        public string SenderName { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
        public string Type { get; set; } = "text";
        public FileAttachmentDto? Attachment { get; set; }

        public static MessageDto FromChatMessage(ChatMessage m) => new()
        {
            MessageId = m.MessageId,
            SenderId = m.SenderId,
            SenderName = m.SenderName,
            Content = m.Content,
            Timestamp = m.Timestamp,
            Type = m.Type.ToString().ToLowerInvariant(),
            Attachment = m.Attachment != null ? FileAttachmentDto.FromFileAttachment(m.Attachment) : null
        };
    }

    /// <summary>
    /// DTO for a participant (ready for JSON serialization).
    /// </summary>
    public class ParticipantDto
    {
        public string UserId { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public bool IsConnected { get; set; }

        public static ParticipantDto FromChatParticipant(ChatParticipant p) => new()
        {
            UserId = p.UserId,
            DisplayName = p.DisplayName,
            IsConnected = p.IsConnected
        };
    }

    /// <summary>
    /// DTO for user events (join/leave/typing).
    /// </summary>
    public class UserEventDto
    {
        public string UserId { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
        public bool? IsTyping { get; set; }
    }

    /// <summary>
    /// Result for getting message history.
    /// </summary>
    public class HistoryResult
    {
        public string ChannelName { get; set; } = string.Empty;
        public List<MessageDto> Messages { get; set; } = new();
    }

    /// <summary>
    /// Result for getting participants.
    /// </summary>
    public class ParticipantsResult
    {
        public List<ParticipantDto> Participants { get; set; } = new();
    }

    #endregion

    #region Contact Request System

    /// <summary>
    /// Status of a contact request.
    /// </summary>
    public enum ContactRequestStatus
    {
        /// <summary>
        /// Request is pending acceptance.
        /// </summary>
        Pending = 0,

        /// <summary>
        /// Request was accepted.
        /// </summary>
        Accepted = 1,

        /// <summary>
        /// Request was rejected.
        /// </summary>
        Rejected = 2,

        /// <summary>
        /// Request was cancelled by sender.
        /// </summary>
        Cancelled = 3
    }

    /// <summary>
    /// Represents a contact request between two users.
    /// </summary>
    public class ContactRequest
    {
        /// <summary>
        /// Unique request ID.
        /// </summary>
        public string RequestId { get; set; } = Guid.NewGuid().ToString("N");

        /// <summary>
        /// The user who sent the request.
        /// </summary>
        public string FromUserId { get; set; } = string.Empty;

        /// <summary>
        /// Display name of the sender.
        /// </summary>
        public string FromDisplayName { get; set; } = string.Empty;

        /// <summary>
        /// The user who receives the request.
        /// </summary>
        public string ToUserId { get; set; } = string.Empty;

        /// <summary>
        /// Optional message with the request.
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// When the request was sent.
        /// </summary>
        public DateTime SentAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// When the request was responded to.
        /// </summary>
        public DateTime? RespondedAt { get; set; }

        /// <summary>
        /// Current status of the request.
        /// </summary>
        public ContactRequestStatus Status { get; set; } = ContactRequestStatus.Pending;
    }

    /// <summary>
    /// DTO for contact request events.
    /// </summary>
    public class ContactRequestDto
    {
        public string RequestId { get; set; } = string.Empty;
        public string FromUserId { get; set; } = string.Empty;
        public string FromDisplayName { get; set; } = string.Empty;
        public string ToUserId { get; set; } = string.Empty;
        public string? Message { get; set; }
        public DateTime SentAt { get; set; }
        public string Status { get; set; } = "pending";

        public static ContactRequestDto FromContactRequest(ContactRequest r) => new()
        {
            RequestId = r.RequestId,
            FromUserId = r.FromUserId,
            FromDisplayName = r.FromDisplayName,
            ToUserId = r.ToUserId,
            Message = r.Message,
            SentAt = r.SentAt,
            Status = r.Status.ToString().ToLowerInvariant()
        };
    }

    /// <summary>
    /// Result of sending a contact request.
    /// </summary>
    public class SendContactRequestResult
    {
        public bool Success { get; set; }
        public string? Error { get; set; }
        public ContactRequestDto? Request { get; set; }
    }

    /// <summary>
    /// Result of responding to a contact request.
    /// </summary>
    public class ContactRequestResponseResult
    {
        public bool Success { get; set; }
        public string? Error { get; set; }
        public ContactRequestDto? Request { get; set; }
        /// <summary>
        /// If accepted, the contacts that were created for both users.
        /// </summary>
        public Contact? SenderContact { get; set; }
        public Contact? ReceiverContact { get; set; }
    }

    #endregion

    #region File Attachment System

    /// <summary>
    /// Represents a file attachment in a chat message.
    /// </summary>
    public class FileAttachment
    {
        /// <summary>
        /// Unique file ID.
        /// </summary>
        public string FileId { get; set; } = Guid.NewGuid().ToString("N");

        /// <summary>
        /// Original filename.
        /// </summary>
        public string FileName { get; set; } = string.Empty;

        /// <summary>
        /// File MIME type.
        /// </summary>
        public string ContentType { get; set; } = "application/octet-stream";

        /// <summary>
        /// File size in bytes.
        /// </summary>
        public long FileSize { get; set; }

        /// <summary>
        /// Storage path or URL.
        /// </summary>
        public string StoragePath { get; set; } = string.Empty;

        /// <summary>
        /// Download URL (relative or absolute).
        /// </summary>
        public string DownloadUrl { get; set; } = string.Empty;

        /// <summary>
        /// When the file was uploaded.
        /// </summary>
        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// User who uploaded the file.
        /// </summary>
        public string UploadedByUserId { get; set; } = string.Empty;

        /// <summary>
        /// Optional thumbnail URL for images/videos.
        /// </summary>
        public string? ThumbnailUrl { get; set; }

        /// <summary>
        /// For images: width in pixels.
        /// </summary>
        public int? Width { get; set; }

        /// <summary>
        /// For images: height in pixels.
        /// </summary>
        public int? Height { get; set; }

        /// <summary>
        /// For audio/video: duration in seconds.
        /// </summary>
        public double? DurationSeconds { get; set; }
    }

    /// <summary>
    /// DTO for file attachment in messages.
    /// </summary>
    public class FileAttachmentDto
    {
        public string FileId { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = string.Empty;
        public long FileSize { get; set; }
        public string DownloadUrl { get; set; } = string.Empty;
        public string? ThumbnailUrl { get; set; }
        public int? Width { get; set; }
        public int? Height { get; set; }
        public double? DurationSeconds { get; set; }

        public static FileAttachmentDto FromFileAttachment(FileAttachment f) => new()
        {
            FileId = f.FileId,
            FileName = f.FileName,
            ContentType = f.ContentType,
            FileSize = f.FileSize,
            DownloadUrl = f.DownloadUrl,
            ThumbnailUrl = f.ThumbnailUrl,
            Width = f.Width,
            Height = f.Height,
            DurationSeconds = f.DurationSeconds
        };
    }

    /// <summary>
    /// Result of uploading a file.
    /// </summary>
    public class FileUploadResult
    {
        public bool Success { get; set; }
        public string? Error { get; set; }
        public FileAttachmentDto? File { get; set; }
    }

    /// <summary>
    /// Result of sending a file message.
    /// </summary>
    public class SendFileMessageResult
    {
        public bool Success { get; set; }
        public string? Error { get; set; }
        public MessageDto? Message { get; set; }
        public FileAttachmentDto? File { get; set; }
    }

    /// <summary>
    /// Permission check result for messaging.
    /// </summary>
    public class MessagePermissionResult
    {
        public bool CanSendMessage { get; set; }
        public string? Reason { get; set; }
    }

    #endregion
}
