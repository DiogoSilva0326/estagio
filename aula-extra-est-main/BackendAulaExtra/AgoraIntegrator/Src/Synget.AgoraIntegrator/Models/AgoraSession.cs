namespace Synget.AgoraIntegrator.Models
{
    /// <summary>
    /// Represents a session (channel/room) in Agora.
    /// </summary>
    public class AgoraSession
    {
        /// <summary>
        /// Unique session identifier (auto-generated if not provided).
        /// </summary>
        public string SessionId { get; set; } = "";

        /// <summary>
        /// Channel name for the session.
        /// </summary>
        public string ChannelName { get; set; } = "";

        /// <summary>
        /// Current status of the session.
        /// </summary>
        public AgoraSessionStatus Status { get; set; } = AgoraSessionStatus.Idle;

        /// <summary>
        /// When the session was created.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// When the session started (users joined).
        /// </summary>
        public DateTime? StartedAt { get; set; }

        /// <summary>
        /// When the session ended.
        /// </summary>
        public DateTime? EndedAt { get; set; }

        /// <summary>
        /// Participants in the session with per-user state (mute flags, join time).
        /// </summary>
        public List<AgoraSessionUser> Users { get; set; } = new();

        /// <summary>
        /// Maximum number of users that have been in the session simultaneously.
        /// </summary>
        public int PeakUserCount { get; set; }

        /// <summary>
        /// Total number of unique users that have joined the session.
        /// </summary>
        public int TotalUniqueUsers { get; set; }

        /// <summary>
        /// Additional metadata for the session.
        /// </summary>
        public Dictionary<string, string> Metadata { get; set; } = new();

        /// <summary>
        /// Convenience: find a participant by user id.
        /// </summary>
        /// <param name="userId">User id to find.</param>
        /// <returns>Participant or null.</returns>
        public AgoraSessionUser? GetUser(string userId)
        {
            return Users.FirstOrDefault(u => string.Equals(u.UserId, userId, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// Duration of the session in seconds (if ended).
        /// </summary>
        public int DurationSeconds
        {
            get
            {
                if (StartedAt == null)
                    return 0;

                var endTime = EndedAt ?? DateTime.UtcNow;
                return (int)(endTime - StartedAt.Value).TotalSeconds;
            }
        }

        /// <summary>
        /// Check if the session is currently active.
        /// </summary>
        public bool IsActive => Status == AgoraSessionStatus.Connected || Status == AgoraSessionStatus.Connecting || Status == AgoraSessionStatus.Reconnecting;
    }

    /// <summary>
    /// Represents a participant in a session, including mute/video flags.
    /// </summary>
    public class AgoraSessionUser
    {
        /// <summary>
        /// User identifier (string form).
        /// </summary>
        public string UserId { get; set; } = string.Empty;

        /// <summary>
        /// Optional display name for the user.
        /// </summary>
        public string? DisplayName { get; set; }

        /// <summary>
        /// Whether the user's audio is muted.
        /// </summary>
        public bool IsAudioMuted { get; set; } = false;

        /// <summary>
        /// Whether the user's video is muted.
        /// </summary>
        public bool IsVideoMuted { get; set; } = false;

        /// <summary>
        /// When the user joined the session.
        /// </summary>
        public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
    }
}
