namespace AgoraBackend.agoraAPI.Services;

using System.Net.Mime;
using System.Text;
using System.Text.Json;
using AgoraBackend.agoraAPI.Models;
using AgoraBackend.agoraAPI.Repository;

public interface IWhiteboardService
{
    Task<(string uuid, string roomToken)> GenerateTokenAsync(string channelName);
}

public class WhiteboardService : IWhiteboardService
{
    private readonly IWhiteboardRoomRepository _roomRepository;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly string _netlessSdkToken;
    private readonly string _netlessRegion;

    public WhiteboardService(IWhiteboardRoomRepository roomRepository, IHttpClientFactory httpClientFactory, AppConfig config)
    {
        _roomRepository = roomRepository;
        _httpClientFactory = httpClientFactory;
        _netlessSdkToken = config.NetlessSdkToken;
        _netlessRegion = config.NetlessRegion;
    }

    public async Task<(string uuid, string roomToken)> GenerateTokenAsync(string channelName)
    {
        var uuid = await _roomRepository.GetOrCreateRoomUuidAsync(channelName);
        var roomToken = await CreateRoomTokenAsync(uuid);
        return (uuid, roomToken);
    }

    private async Task<string> CreateRoomTokenAsync(string uuid)
    {
        var client = _httpClientFactory.CreateClient("netless");
        var url = $"https://api.netless.link/v5/tokens/rooms/{uuid}";

        using var req = new HttpRequestMessage(HttpMethod.Post, url);
        req.Headers.TryAddWithoutValidation("token", _netlessSdkToken);
        req.Headers.TryAddWithoutValidation("region", _netlessRegion);
        req.Content = new StringContent("{\"lifespan\":3600000,\"role\":\"admin\"}", Encoding.UTF8, MediaTypeNames.Application.Json);

        using var resp = await client.SendAsync(req);
        var respBody = await resp.Content.ReadAsStringAsync();
        resp.EnsureSuccessStatusCode();

        var token = JsonSerializer.Deserialize<string>(respBody);
        if (string.IsNullOrWhiteSpace(token))
            throw new InvalidOperationException("Netless: empty room token");

        return token;
    }
}
