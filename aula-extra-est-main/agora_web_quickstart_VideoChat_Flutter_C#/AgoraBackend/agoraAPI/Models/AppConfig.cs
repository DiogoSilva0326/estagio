namespace AgoraBackend.agoraAPI.Models;

public record AppConfig(
    string AgoraAppId,
    string AgoraAppCertificate,
    string NetlessSdkToken,
    string NetlessRegion,
    string AgoraChatAppKey = "",
    string AgoraChatClientId = "",
    string AgoraChatClientSecret = "");
