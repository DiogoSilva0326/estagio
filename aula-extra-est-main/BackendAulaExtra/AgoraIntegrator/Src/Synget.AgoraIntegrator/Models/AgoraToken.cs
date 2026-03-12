namespace Synget.AgoraIntegrator.Models
{
    /// <summary>
    /// Represents an Agora token (RTC or RTM).
    /// </summary>
    public class AgoraToken
    {
        /// <summary>
        /// The token string.
        /// </summary>
        public string Token { get; set; } = "";

        /// <summary>
        /// Channel name associated with the token (for RTC tokens).
        /// </summary>
        public string? ChannelName { get; set; }

        /// <summary>
        /// User ID associated with the token.
        /// </summary>
        public uint Uid { get; set; }

        /// <summary>
        /// User account (string) associated with the token (for RTM tokens).
        /// </summary>
        public string? Account { get; set; }

        /// <summary>
        /// Role in the channel (for RTC tokens).
        /// </summary>
        public AgoraRtcRole Role { get; set; } = AgoraRtcRole.Publisher;

        /// <summary>
        /// When the token was created.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// When the token expires.
        /// </summary>
        public DateTime ExpiresAt { get; set; }

        /// <summary>
        /// Check if the token is still valid.
        /// </summary>
        public bool IsValid => DateTime.UtcNow < ExpiresAt && !string.IsNullOrEmpty(Token);

        /// <summary>
        /// Seconds until the token expires.
        /// </summary>
        public int SecondsUntilExpiry => Math.Max(0, (int)(ExpiresAt - DateTime.UtcNow).TotalSeconds);
    }
}
