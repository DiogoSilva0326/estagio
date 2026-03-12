using Synget.AgoraIntegrator.Agora;
using Synget.AgoraIntegrator.Models;
using Synget.AgoraIntegrator.Utilities;

namespace Synget.AgoraIntegrator
{
    /// <summary>
    /// Main implementation of the IAgora interface.
    /// Provides full integration with Agora RTC/RTM services.
    /// Similar to ERPMoloni in the ERP integrator pattern.
    /// </summary>
    public class AgoraRTC : IAgora
    {
        /// <inheritdoc/>
        public string Message { get; set; } = "";

        /// <summary>
        /// The Agora client for API operations.
        /// </summary>
        public AgoraClient? Client { get; private set; }

        /// <summary>
        /// Current configuration.
        /// </summary>
        public AgoraConfig? Config { get; private set; }

        /// <inheritdoc/>
        public bool Initialize(AgoraConfig config)
        {
            if (config is null)
            {
                Message = "Configuration cannot be null.";
                return false;
            }

            var (isValid, errorMessage) = config.Validate();
            if (!isValid)
            {
                Message = errorMessage;
                return false;
            }

            Config = config;

            // Create internal client config
            var clientConfig = new AgoraClientConfig
            {
                AppId = config.AppId,
                AppCertificate = config.AppCertificate,
                TokenExpirationSeconds = config.TokenExpirationSeconds,
                WhiteboardSdkToken = config.WhiteboardSdkToken,
                WhiteboardAppIdentifier = config.WhiteboardAppIdentifier,
                WhiteboardRegion = config.WhiteboardRegion
            };

            Client = new AgoraClient(clientConfig);

            Message = "";
            return true;
        }

        #region RTC Token Operations

        /// <inheritdoc/>
        public AgoraToken? RtcTokenGenerate(string channelName, uint uid, AgoraRtcRole role = AgoraRtcRole.Publisher)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            if (channelName.Empty())
            {
                Message = "Channel name is required.";
                return null;
            }

            try
            {
                var token = Client.Rtc.GenerateToken(channelName, uid, role);
                Message = "";
                return token;
            }
            catch (Exception ex)
            {
                Message = $"Failed to generate RTC token: {ex.Message}";
                return null;
            }
        }

        /// <inheritdoc/>
        public bool RtcTokenValidate(string token)
        {
            if (Client is null)
            {
                Message = "Client not initialized.";
                return false;
            }

            return Client.Rtc.ValidateToken(token);
        }

        #endregion

        #region RTM Token Operations

        /// <inheritdoc/>
        public AgoraToken? RtmTokenGenerate(string userId)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            if (userId.Empty())
            {
                Message = "User ID is required.";
                return null;
            }

            try
            {
                var token = Client.Rtm.GenerateToken(userId);
                Message = "";
                return token;
            }
            catch (Exception ex)
            {
                Message = $"Failed to generate RTM token: {ex.Message}";
                return null;
            }
        }

        /// <inheritdoc/>
        public bool RtmTokenValidate(string token)
        {
            if (Client is null)
            {
                Message = "Client not initialized.";
                return false;
            }

            return Client.Rtm.ValidateToken(token);
        }

        #endregion

        #region Session Operations

        /// <inheritdoc/>
        public AgoraSession? SessionCreate(string channelName)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            if (channelName.Empty())
            {
                Message = "Channel name is required.";
                return null;
            }

            try
            {
                var session = Client.Sessions.Create(channelName);
                Message = "";
                return session;
            }
            catch (Exception ex)
            {
                Message = $"Failed to create session: {ex.Message}";
                return null;
            }
        }

        /// <inheritdoc/>
        public AgoraSession? SessionGet(string channelName)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            if (channelName.Empty())
            {
                Message = "Channel name is required.";
                return null;
            }

            return Client.Sessions.Get(channelName);
        }

        /// <inheritdoc/>
        public bool SessionEnd(string channelName)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return false;
            }

            if (channelName.Empty())
            {
                Message = "Channel name is required.";
                return false;
            }

            var result = Client.Sessions.End(channelName);
            Message = result ? "" : "Session not found.";
            return result;
        }

        /// <inheritdoc/>
        public bool SessionUserJoin(string channelName, string userId, string? displayName = null)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return false;
            }

            if (channelName.Empty() || userId.Empty())
            {
                Message = "Channel name and user ID are required.";
                return false;
            }

            var result = Client.Sessions.UserJoin(channelName, userId, displayName);
            Message = result ? "" : "Failed to add user to session.";
            return result;
        }

        /// <inheritdoc/>
        public bool SessionUserLeave(string channelName, string userId)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return false;
            }

            if (channelName.Empty() || userId.Empty())
            {
                Message = "Channel name and user ID are required.";
                return false;
            }

            var result = Client.Sessions.UserLeave(channelName, userId);
            Message = result ? "" : "Failed to remove user from session.";
            return result;
        }

        /// <inheritdoc/>
        public List<AgoraSession> SessionGetList()
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return new List<AgoraSession>();
            }

            return Client.Sessions.GetAll();
        }

        /// <inheritdoc/>
        public bool SessionSetUserAudioMuted(string channelName, string userId, bool muted)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return false;
            }

            if (channelName.Empty() || userId.Empty())
            {
                Message = "Channel name and user ID are required.";
                return false;
            }

            var result = Client.Sessions.SetUserAudioMuted(channelName, userId, muted);
            Message = result ? "" : "Failed to set audio mute state.";
            return result;
        }

        /// <inheritdoc/>
        public bool SessionSetUserVideoMuted(string channelName, string userId, bool muted)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return false;
            }

            if (channelName.Empty() || userId.Empty())
            {
                Message = "Channel name and user ID are required.";
                return false;
            }

            var result = Client.Sessions.SetUserVideoMuted(channelName, userId, muted);
            Message = result ? "" : "Failed to set video mute state.";
            return result;
        }

        /// <inheritdoc/>
        public AgoraSessionUser? SessionGetUser(string channelName, string userId)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            if (channelName.Empty() || userId.Empty())
            {
                Message = "Channel name and user ID are required.";
                return null;
            }

            return Client.Sessions.GetUser(channelName, userId);
        }

        #endregion

        #region Whiteboard Operations

        /// <inheritdoc/>
        public async Task<AgoraWhiteboardRoom?> WhiteboardGetOrCreateRoomAsync(string channelName)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            if (channelName.Empty())
            {
                Message = "Channel name is required.";
                return null;
            }

            try
            {
                var room = await Client.Whiteboard.GetOrCreateRoomAsync(channelName);
                if (room == null)
                {
                    Message = "Failed to create whiteboard room. Check whiteboard SDK token.";
                    return null;
                }
                Message = "";
                return room;
            }
            catch (Exception ex)
            {
                Message = $"Failed to create whiteboard room: {ex.Message}";
                return null;
            }
        }

        /// <inheritdoc/>
        public AgoraWhiteboardConfig? WhiteboardGetConfig()
        {
            if (Config is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            return new AgoraWhiteboardConfig
            {
                AppIdentifier = Config.WhiteboardAppIdentifier,
                Region = Config.WhiteboardRegion
            };
        }

        #endregion

        #region Screen Share Operations

        /// <summary>
        /// Screen share UID suffix convention.
        /// </summary>
        private const int ScreenShareUidMultiplier = 100;
        private const int ScreenShareUidOffset = 99;

        /// <inheritdoc/>
        public AgoraToken? ScreenShareTokenGenerate(string channelName, uint baseUid)
        {
            if (Client is null)
            {
                Message = "Client not initialized. Call Initialize() first.";
                return null;
            }

            if (channelName.Empty())
            {
                Message = "Channel name is required.";
                return null;
            }

            try
            {
                var screenShareUid = ScreenShareUidCalculate(baseUid);
                var token = Client.Rtc.GenerateToken(channelName, screenShareUid, AgoraRtcRole.Publisher);
                Message = "";
                return token;
            }
            catch (Exception ex)
            {
                Message = $"Failed to generate screen share token: {ex.Message}";
                return null;
            }
        }

        /// <inheritdoc/>
        public uint ScreenShareUidCalculate(uint baseUid)
        {
            return baseUid * ScreenShareUidMultiplier + ScreenShareUidOffset;
        }

        /// <inheritdoc/>
        public bool ScreenShareUidCheck(uint uid)
        {
            return uid % ScreenShareUidMultiplier == ScreenShareUidOffset;
        }

        #endregion
    }
}
