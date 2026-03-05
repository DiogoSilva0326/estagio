using Synget.AgoraIntegrator.Models;

namespace Synget.AgoraIntegrator
{
    /// <summary>
    /// Defines the public contract for an Agora integration provider.
    /// Implementations must implement these methods so UIs and services can
    /// perform common operations in a vendor-agnostic way.
    /// </summary>
    public interface IAgora
    {
        /// <summary>
        /// When an operation fails, implementations should set <see cref="Message"/>
        /// with a human-readable description of the error.
        /// </summary>
        string Message { get; set; }

        /// <summary>
        /// Initialize the provider using the supplied configuration. This should
        /// perform any validation and setup required for subsequent operations.
        /// Return <c>true</c> on success.
        /// </summary>
        /// <param name="config">Configuration values specific to the provider.</param>
        /// <returns><c>true</c> when initialization succeeded, otherwise <c>false</c>.</returns>
        bool Initialize(AgoraConfig config);

        #region RTC Token Operations

        /// <summary>
        /// Generate an RTC token for video/audio calls.
        /// </summary>
        /// <param name="channelName">Name of the channel to join.</param>
        /// <param name="uid">User ID (0 for dynamic assignment).</param>
        /// <param name="role">Role in the channel (Publisher/Subscriber).</param>
        /// <returns>Generated token or null on error.</returns>
        AgoraToken? RtcTokenGenerate(string channelName, uint uid, AgoraRtcRole role = AgoraRtcRole.Publisher);

        /// <summary>
        /// Validate if an RTC token is still valid.
        /// </summary>
        /// <param name="token">Token to validate.</param>
        /// <returns>True if valid, false otherwise.</returns>
        bool RtcTokenValidate(string token);

        #endregion

        #region RTM Token Operations

        /// <summary>
        /// Generate an RTM token for real-time messaging.
        /// </summary>
        /// <param name="userId">User ID for the token.</param>
        /// <returns>Generated token or null on error.</returns>
        AgoraToken? RtmTokenGenerate(string userId);

        /// <summary>
        /// Validate if an RTM token is still valid.
        /// </summary>
        /// <param name="token">Token to validate.</param>
        /// <returns>True if valid, false otherwise.</returns>
        bool RtmTokenValidate(string token);

        #endregion

        #region Session Operations

        /// <summary>
        /// Create a new session (channel/room) for video calls.
        /// </summary>
        /// <param name="channelName">Name of the channel.</param>
        /// <returns>Session info or null on error.</returns>
        AgoraSession? SessionCreate(string channelName);

        /// <summary>
        /// Get information about an existing session.
        /// </summary>
        /// <param name="channelName">Name of the channel.</param>
        /// <returns>Session info or null if not found.</returns>
        AgoraSession? SessionGet(string channelName);

        /// <summary>
        /// End an active session.
        /// </summary>
        /// <param name="channelName">Name of the channel.</param>
        /// <returns>True on success.</returns>
        bool SessionEnd(string channelName);

        /// <summary>
        /// Add a user to a session.
        /// </summary>
        /// <param name="channelName">Name of the channel.</param>
        /// <param name="userId">User to add.</param>
        /// <returns>True on success.</returns>
        bool SessionUserJoin(string channelName, string userId, string? displayName = null);

        /// <summary>
        /// Remove a user from a session.
        /// </summary>
        /// <param name="channelName">Name of the channel.</param>
        /// <param name="userId">User to remove.</param>
        /// <returns>True on success.</returns>
        bool SessionUserLeave(string channelName, string userId);

        /// <summary>
        /// Get list of all active sessions.
        /// </summary>
        /// <returns>List of active sessions.</returns>
        List<AgoraSession> SessionGetList();

        #endregion

        /// <summary>
        /// Set a participant's audio mute state in a session.
        /// </summary>
        bool SessionSetUserAudioMuted(string channelName, string userId, bool muted);

        /// <summary>
        /// Set a participant's video mute state in a session.
        /// </summary>
        bool SessionSetUserVideoMuted(string channelName, string userId, bool muted);

        /// <summary>
        /// Get participant info for a session.
        /// </summary>
        AgoraSessionUser? SessionGetUser(string channelName, string userId);

        #region Whiteboard Operations

        /// <summary>
        /// Get or create a whiteboard room for a channel.
        /// This is an async operation that creates a room in Netless if it doesn't exist.
        /// </summary>
        /// <param name="channelName">Channel name to associate with the whiteboard.</param>
        /// <returns>Whiteboard room info with UUID and token.</returns>
        Task<AgoraWhiteboardRoom?> WhiteboardGetOrCreateRoomAsync(string channelName);

        /// <summary>
        /// Get the whiteboard configuration (appIdentifier, region) for client-side setup.
        /// </summary>
        /// <returns>Whiteboard configuration.</returns>
        AgoraWhiteboardConfig? WhiteboardGetConfig();

        #endregion

        #region Screen Share Operations

        /// <summary>
        /// Generate a token for screen sharing.
        /// Screen share uses a separate UID convention (baseUid * 100 + 99).
        /// </summary>
        /// <param name="channelName">Channel name.</param>
        /// <param name="baseUid">Base UID of the user sharing screen.</param>
        /// <returns>Token for screen share connection.</returns>
        AgoraToken? ScreenShareTokenGenerate(string channelName, uint baseUid);

        /// <summary>
        /// Calculate the screen share UID from a base UID.
        /// Convention: screenShareUid = baseUid * 100 + 99
        /// </summary>
        /// <param name="baseUid">Base UID of the user.</param>
        /// <returns>Screen share UID.</returns>
        uint ScreenShareUidCalculate(uint baseUid);

        /// <summary>
        /// Check if a UID is a screen share UID.
        /// </summary>
        /// <param name="uid">UID to check.</param>
        /// <returns>True if it's a screen share UID.</returns>
        bool ScreenShareUidCheck(uint uid);

        #endregion
    }
}
