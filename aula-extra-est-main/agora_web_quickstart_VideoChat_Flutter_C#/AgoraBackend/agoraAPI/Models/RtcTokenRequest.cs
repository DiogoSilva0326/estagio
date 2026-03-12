namespace AgoraBackend.agoraAPI.Models;

public class RtcTokenRequest
{
    public uint Uid { get; set; }
    public string ChannelName { get; set; } = "";
    public uint Role { get; set; }
}
