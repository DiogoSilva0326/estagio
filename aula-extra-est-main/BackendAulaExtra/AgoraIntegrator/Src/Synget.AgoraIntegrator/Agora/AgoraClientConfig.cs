namespace Synget.AgoraIntegrator.Agora
{
    /// <summary>
    /// Configuration specific to Agora RTC/RTM client.
    /// Internal configuration derived from AgoraConfig.
    /// </summary>
    public class AgoraClientConfig
    {
        /// <summary>
        /// Agora App ID.
        /// </summary>
        public string AppId { get; set; } = "";

        /// <summary>
        /// Agora App Certificate.
        /// </summary>
        public string AppCertificate { get; set; } = "";

        /// <summary>
        /// Token expiration time in seconds.
        /// </summary>
        public int TokenExpirationSeconds { get; set; } = 3600;

        #region Whiteboard Settings

        /// <summary>
        /// Netless SDK Token.
        /// </summary>
        public string WhiteboardSdkToken { get; set; } = "";

        /// <summary>
        /// Netless App Identifier for client-side SDK.
        /// </summary>
        public string WhiteboardAppIdentifier { get; set; } = "";

        /// <summary>
        /// Netless Region.
        /// </summary>
        public string WhiteboardRegion { get; set; } = "us-sv";

        #endregion
    }
}
