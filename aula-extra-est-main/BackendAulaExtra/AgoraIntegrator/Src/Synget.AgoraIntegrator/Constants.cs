namespace Synget.AgoraIntegrator
{
    /// <summary>
    /// Defines the Agora platform/product type being used.
    /// </summary>
    public enum AgoraPlatform
    {
        None,
        /// <summary>
        /// Real-Time Communication (Video/Audio Calls)
        /// </summary>
        RTC,
        /// <summary>
        /// Real-Time Messaging
        /// </summary>
        RTM
    }

    /// <summary>
    /// Role in an RTC channel.
    /// </summary>
    public enum AgoraRtcRole
    {
        /// <summary>
        /// Publisher can send and receive audio/video.
        /// </summary>
        Publisher = 1,
        /// <summary>
        /// Subscriber can only receive audio/video.
        /// </summary>
        Subscriber = 2
    }

    /// <summary>
    /// Session status for video calls.
    /// </summary>
    public enum AgoraSessionStatus
    {
        /// <summary>
        /// Session not started.
        /// </summary>
        Idle,
        /// <summary>
        /// Session is connecting.
        /// </summary>
        Connecting,
        /// <summary>
        /// Session is active.
        /// </summary>
        Connected,
        /// <summary>
        /// Session is reconnecting.
        /// </summary>
        Reconnecting,
        /// <summary>
        /// Session ended.
        /// </summary>
        Disconnected,
        /// <summary>
        /// Session failed.
        /// </summary>
        Failed
    }
}
