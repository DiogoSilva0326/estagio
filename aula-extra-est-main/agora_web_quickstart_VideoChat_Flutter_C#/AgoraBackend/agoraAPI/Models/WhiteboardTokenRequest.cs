namespace AgoraBackend.agoraAPI.Models;

using System.Text.Json;

public class WhiteboardTokenRequest
{
    public string ChannelName { get; set; } = "";
    public JsonElement Uid { get; set; }
}
