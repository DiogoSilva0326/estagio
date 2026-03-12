namespace Synget.AgoraIntegrator.Models
{
    /// <summary>
    /// Configuration class for Agora integration.
    /// Contains all credentials and settings needed to connect to Agora services.
    /// </summary>
    public class AgoraConfig
    {
        /// <summary>
        /// Which Agora platform to use. Typically <see cref="AgoraPlatform.RTC"/>.
        /// </summary>
        public AgoraPlatform Platform { get; set; } = AgoraPlatform.None;

        #region Core Agora Credentials

        /// <summary>
        /// Agora App ID from the Agora Console.
        /// Required for all Agora services.
        /// </summary>
        public string AppId { get; set; } = "";

        /// <summary>
        /// Agora App Certificate from the Agora Console.
        /// Required for token-based authentication.
        /// </summary>
        public string AppCertificate { get; set; } = "";

        #endregion

        #region Token Settings

        /// <summary>
        /// Token expiration time in seconds. Default is 3600 (1 hour).
        /// </summary>
        public int TokenExpirationSeconds { get; set; } = 3600;

        #endregion

        #region Whiteboard/Netless Settings

        /// <summary>
        /// Netless SDK Token for whiteboard functionality.
        /// </summary>
        public string WhiteboardSdkToken { get; set; } = "";

        /// <summary>
        /// Netless App Identifier for client-side SDK.
        /// </summary>
        public string WhiteboardAppIdentifier { get; set; } = "";

        /// <summary>
        /// Netless region (e.g., "cn-hz", "us-sv").
        /// </summary>
        public string WhiteboardRegion { get; set; } = "us-sv";

        #endregion

        #region Session Storage Settings

        /// <summary>
        /// Base path for session storage (recordings, snapshots, etc.).
        /// </summary>
        public string SessionStoragePath { get; set; } = "";

        #endregion

        /// <summary>
        /// Validate the configuration.
        /// </summary>
        /// <returns>Tuple with (isValid, errorMessage).</returns>
        public (bool IsValid, string ErrorMessage) Validate()
        {
            if (Platform == AgoraPlatform.None)
                return (false, "Platform must be specified.");

            if (string.IsNullOrWhiteSpace(AppId))
                return (false, "AppId is required.");

            if (string.IsNullOrWhiteSpace(AppCertificate))
                return (false, "AppCertificate is required for token generation.");

            return (true, "");
        }
    }
}
