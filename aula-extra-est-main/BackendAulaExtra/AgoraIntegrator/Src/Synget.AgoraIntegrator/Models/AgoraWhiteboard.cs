namespace Synget.AgoraIntegrator.Models
{
    /// <summary>
    /// Represents a whiteboard room in Agora/Netless.
    /// </summary>
    public class AgoraWhiteboardRoom
    {
        /// <summary>
        /// Unique room UUID.
        /// </summary>
        public string Uuid { get; set; } = "";

        /// <summary>
        /// Channel name associated with the whiteboard.
        /// </summary>
        public string ChannelName { get; set; } = "";

        /// <summary>
        /// Room token for access.
        /// </summary>
        public string RoomToken { get; set; } = "";

        /// <summary>
        /// When the room was created.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Whether the room is currently active.
        /// </summary>
        public bool IsActive { get; set; } = true;
    }

    /// <summary>
    /// Configuration for whiteboard client-side setup.
    /// Contains the info needed by Flutter/Web clients to connect to whiteboard.
    /// </summary>
    public class AgoraWhiteboardConfig
    {
        /// <summary>
        /// Netless App Identifier for client-side SDK.
        /// </summary>
        public string AppIdentifier { get; set; } = "";

        /// <summary>
        /// Netless region (e.g., "us-sv", "cn-hz").
        /// </summary>
        public string Region { get; set; } = "us-sv";
    }

    /// <summary>
    /// Represents a snapshot of a whiteboard page.
    /// </summary>
    public class AgoraWhiteboardSnapshot
    {
        /// <summary>
        /// Unique snapshot ID.
        /// </summary>
        public string SnapshotId { get; set; } = "";

        /// <summary>
        /// Channel name associated with the snapshot.
        /// </summary>
        public string ChannelName { get; set; } = "";

        /// <summary>
        /// Session ID for the snapshot.
        /// </summary>
        public string SessionId { get; set; } = "";

        /// <summary>
        /// Page number of the whiteboard.
        /// </summary>
        public int PageNumber { get; set; } = 1;

        /// <summary>
        /// Reason for the snapshot (e.g., "page_change", "session_end").
        /// </summary>
        public string Reason { get; set; } = "";

        /// <summary>
        /// Path where the snapshot is stored.
        /// </summary>
        public string FilePath { get; set; } = "";

        /// <summary>
        /// Base64 encoded image data.
        /// </summary>
        public string? ImageDataBase64 { get; set; }

        /// <summary>
        /// When the snapshot was taken.
        /// </summary>
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }
}
