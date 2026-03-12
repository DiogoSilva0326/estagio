using AgoraIO.Media;
using Synget.AgoraIntegrator.Models;

namespace Synget.AgoraIntegrator.Agora
{
    /// <summary>
    /// Endpoints for RTC token generation.
    /// Handles video/audio call token creation.
    /// </summary>
    public class RtcEndpoints
    {
        private readonly AgoraClient _client;

        public RtcEndpoints(AgoraClient client)
        {
            _client = client ?? throw new ArgumentNullException(nameof(client));
        }

        /// <summary>
        /// Generate an RTC token for joining a channel.
        /// </summary>
        /// <param name="channelName">Name of the channel.</param>
        /// <param name="uid">User ID (0 for dynamic assignment).</param>
        /// <param name="role">Role in the channel.</param>
        /// <returns>Generated token.</returns>
        public AgoraToken GenerateToken(string channelName, uint uid, AgoraRtcRole role = AgoraRtcRole.Publisher)
        {
            if (string.IsNullOrWhiteSpace(channelName))
                throw new ArgumentException("Channel name is required.", nameof(channelName));

            var config = _client.Config;
            var expirationSeconds = config.TokenExpirationSeconds;
            var privilegeExpiredTs = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds() + (uint)Math.Max(0, expirationSeconds);

            var agoraRole = role == AgoraRtcRole.Publisher
                ? RtcTokenBuilder.Role.RolePublisher
                : RtcTokenBuilder.Role.RoleSubscriber;

            var tokenString = RtcTokenBuilder.buildTokenWithUID(
                config.AppId,
                config.AppCertificate,
                channelName,
                uid,
                agoraRole,
                privilegeExpiredTs);

            return new AgoraToken
            {
                Token = tokenString,
                ChannelName = channelName,
                Uid = uid,
                Role = role,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddSeconds(expirationSeconds)
            };
        }

        /// <summary>
        /// Validate if a token is still valid (based on expiration time).
        /// Note: This is a local check only. Full validation would require API call.
        /// </summary>
        /// <param name="token">Token to validate.</param>
        /// <returns>True if the token appears valid.</returns>
        public bool ValidateToken(AgoraToken token)
        {
            return token != null && token.IsValid;
        }

        /// <summary>
        /// Validate if a token string is still valid.
        /// Note: This is a basic check. Full validation would require parsing the token.
        /// </summary>
        /// <param name="tokenString">Token string to validate.</param>
        /// <returns>True if the token appears valid.</returns>
        public bool ValidateToken(string tokenString)
        {
            // Basic validation - token should not be empty and should have correct format
            return !string.IsNullOrWhiteSpace(tokenString) && tokenString.Length > 50;
        }
    }
}
