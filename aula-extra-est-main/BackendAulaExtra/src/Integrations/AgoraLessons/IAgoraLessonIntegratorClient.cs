using System.Threading;
using System.Threading.Tasks;

namespace ConfidantPostgreSQL.Integrations.AgoraLessons
{
    public interface IAgoraLessonIntegratorClient
    {
        Task<AgoraLessonClientConfig> GetClientConfigAsync(CancellationToken cancellationToken = default);
        Task<AgoraSessionResponse> JoinOrCreateSessionAsync(string channelName, string userId, string displayName, CancellationToken cancellationToken = default);
        Task<AgoraTokenResponse> GenerateRtcTokenAsync(string channelName, string uid, CancellationToken cancellationToken = default);
        Task<AgoraScreenShareTokenResponse> GenerateScreenShareTokenAsync(string channelName, uint baseUid, CancellationToken cancellationToken = default);
        Task<AgoraWhiteboardTokenResponse> GetWhiteboardTokenAsync(string channelName, int uid, CancellationToken cancellationToken = default);
        Task StartCallByUsernameAsync(string channelName, string username, string displayName, CancellationToken cancellationToken = default);
        Task JoinCallByUsernameAsync(string channelName, string username, string displayName, CancellationToken cancellationToken = default);
    }

    public sealed class AgoraLessonClientConfig
    {
        public string AgoraAppId { get; set; } = string.Empty;
        public string WhiteboardAppIdentifier { get; set; } = string.Empty;
        public string WhiteboardRegion { get; set; } = "us-sv";
    }

    public sealed class AgoraSessionResponse
    {
        public string ChannelName { get; set; } = string.Empty;
        public string HostUserId { get; set; } = string.Empty;
    }

    public sealed class AgoraTokenResponse
    {
        public string Token { get; set; } = string.Empty;
        public string ChannelName { get; set; } = string.Empty;
        public string Uid { get; set; } = string.Empty;
    }

    public sealed class AgoraScreenShareTokenResponse
    {
        public string Token { get; set; } = string.Empty;
        public string ChannelName { get; set; } = string.Empty;
        public uint ScreenShareUid { get; set; }
        public uint BaseUid { get; set; }
    }

    public sealed class AgoraWhiteboardTokenResponse
    {
        public string Uuid { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string ChannelName { get; set; } = string.Empty;
    }
}