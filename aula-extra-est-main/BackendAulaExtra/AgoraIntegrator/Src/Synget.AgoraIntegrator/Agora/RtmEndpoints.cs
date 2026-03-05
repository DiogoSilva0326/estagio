using Synget.AgoraIntegrator.Models;
using Synget.AgoraIntegrator.Utilities;

namespace Synget.AgoraIntegrator.Agora
{
    /// <summary>
    /// Endpoints for RTM (Real-Time Messaging) token generation.
    /// </summary>
    public class RtmEndpoints
    {
        private readonly AgoraClient _client;

        public RtmEndpoints(AgoraClient client)
        {
            _client = client ?? throw new ArgumentNullException(nameof(client));
        }

        /// <summary>
        /// Generate an RTM token for a user.
        /// </summary>
        /// <param name="account">User account/ID.</param>
        /// <returns>Generated token.</returns>
        public AgoraToken GenerateToken(string account)
        {
            if (string.IsNullOrWhiteSpace(account))
                throw new ArgumentException("Account is required.", nameof(account));

            var config = _client.Config;
            var expirationSeconds = config.TokenExpirationSeconds;
            var expireTs = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds() + (uint)Math.Max(0, expirationSeconds);

            var accessToken = new AccessToken2(config.AppId, config.AppCertificate, expireTs);
            var service = new ServiceRtm(account);
            service.AddPrivilege(PrivilegesRtm.Login, expireTs);
            accessToken.AddService(service);

            var tokenString = accessToken.Build();

            return new AgoraToken
            {
                Token = tokenString,
                Account = account,
                CreatedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddSeconds(expirationSeconds)
            };
        }

        /// <summary>
        /// Validate if a token is still valid (based on expiration time).
        /// </summary>
        /// <param name="token">Token to validate.</param>
        /// <returns>True if the token appears valid.</returns>
        public bool ValidateToken(AgoraToken token)
        {
            return token != null && token.IsValid;
        }

        /// <summary>
        /// Validate if a token string is still valid.
        /// </summary>
        /// <param name="tokenString">Token string to validate.</param>
        /// <returns>True if the token appears valid.</returns>
        public bool ValidateToken(string tokenString)
        {
            // Basic validation - RTM tokens start with "agora_"
            return !string.IsNullOrWhiteSpace(tokenString) && tokenString.StartsWith("agora_");
        }
    }
}
