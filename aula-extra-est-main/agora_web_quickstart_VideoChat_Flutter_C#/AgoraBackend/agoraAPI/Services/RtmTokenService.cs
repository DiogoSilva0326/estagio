namespace AgoraBackend.agoraAPI.Services;

using AgoraBackend.agoraAPI.Utils;

public interface IRtmTokenService
{
    string GenerateToken(string appId, string appCertificate, string account);
}

public class RtmTokenService : IRtmTokenService
{
    public string GenerateToken(string appId, string appCertificate, string account)
    {
        const int privilegeExpireSeconds = 3600;
        var expireTs = (uint)DateTimeOffset.UtcNow.ToUnixTimeSeconds() + (uint)Math.Max(0, privilegeExpireSeconds);

        var token = new AccessToken2(appId, appCertificate, expireTs);
        var service = new ServiceRtm(account);
        service.AddPrivilege(PrivilegesRtm.Login, expireTs);
        token.AddService(service);
        return token.Build();
    }
}
