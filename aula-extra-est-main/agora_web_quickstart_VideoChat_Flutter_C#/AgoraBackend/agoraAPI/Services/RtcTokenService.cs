namespace AgoraBackend.agoraAPI.Services;

using System.Text;
using System.Text.Json;
using System.Net.Mime;
using AgoraBackend.agoraAPI.Models;
using AgoraIO.Media;

public interface IRtcTokenService
{
    string GenerateToken(string appId, string appCertificate, string channelName, uint uid, RtcRole role);
}

public class RtcTokenService : IRtcTokenService
{
    public string GenerateToken(string appId, string appCertificate, string channelName, uint uid, RtcRole role)
    {
        const int privilegeExpireSeconds = 3600;

        var privilegeExpiredTs = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds() + (uint)Math.Max(0, privilegeExpireSeconds);
        var agoraRole = role == RtcRole.Publisher
            ? RtcTokenBuilder.Role.RolePublisher
            : RtcTokenBuilder.Role.RoleSubscriber;

        return RtcTokenBuilder.buildTokenWithUID(
            appId,
            appCertificate,
            channelName,
            uid,
            agoraRole,
            privilegeExpiredTs);
    }
}

public enum RtcRole
{
    Publisher = 1,
    Subscriber = 2,
}
