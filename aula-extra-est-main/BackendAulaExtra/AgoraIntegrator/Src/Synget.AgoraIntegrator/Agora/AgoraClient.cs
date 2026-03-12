namespace Synget.AgoraIntegrator.Agora
{
    /// <summary>
    /// Client for Agora RTC/RTM APIs.
    /// Handles token generation and session management.
    /// Similar to MoloniClient in the ERP integrator pattern.
    /// </summary>
    public class AgoraClient
    {
        /// <summary>
        /// Configuration for the client.
        /// </summary>
        public AgoraClientConfig Config { get; set; }

        /// <summary>
        /// HTTP client for making API requests.
        /// </summary>
        public HttpClient HttpClient { get; set; }

        /// <summary>
        /// RTC endpoints for token generation.
        /// </summary>
        public RtcEndpoints Rtc { get; set; }

        /// <summary>
        /// RTM endpoints for token generation.
        /// </summary>
        public RtmEndpoints Rtm { get; set; }

        /// <summary>
        /// Whiteboard endpoints for collaborative drawing.
        /// </summary>
        public WhiteboardEndpoints Whiteboard { get; set; }

        /// <summary>
        /// Session endpoints for managing call sessions.
        /// </summary>
        public SessionEndpoints Sessions { get; set; }

        /// <summary>
        /// Create a new Agora client with the specified configuration.
        /// </summary>
        public AgoraClient(AgoraClientConfig config)
        {
            Config = config ?? throw new ArgumentNullException(nameof(config));
            HttpClient = new HttpClient();

            // Initialize endpoints
            Rtc = new RtcEndpoints(this);
            Rtm = new RtmEndpoints(this);
            Whiteboard = new WhiteboardEndpoints(this);
            Sessions = new SessionEndpoints(this);
        }
    }
}
