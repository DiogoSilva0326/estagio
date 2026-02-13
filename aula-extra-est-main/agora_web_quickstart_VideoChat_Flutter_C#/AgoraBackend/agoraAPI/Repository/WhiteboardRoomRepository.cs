using System.Collections.Concurrent;
using System.Text;
using System.Text.Json;
using AgoraBackend.agoraAPI.Models;

namespace AgoraBackend.agoraAPI.Repository;

public interface IWhiteboardRoomRepository
{
    Task<string> GetOrCreateRoomUuidAsync(string channelName);
}

public class WhiteboardRoomRepository : IWhiteboardRoomRepository
{
    private readonly ConcurrentDictionary<string, string> _channelRooms = new(StringComparer.Ordinal);
    private readonly string _netlessSdkToken;
    private readonly string _netlessRegion;
    private readonly IHttpClientFactory _httpClientFactory;

    public WhiteboardRoomRepository(AppConfig config, IHttpClientFactory httpClientFactory)
    {
        _netlessSdkToken = config.NetlessSdkToken;
        _netlessRegion = config.NetlessRegion;
        _httpClientFactory = httpClientFactory;
    }

    public async Task<string> GetOrCreateRoomUuidAsync(string channelName)
    {
        if (_channelRooms.TryGetValue(channelName, out var existing))
            return existing;

        var client = _httpClientFactory.CreateClient("netless");
        using var req = new HttpRequestMessage(HttpMethod.Post, "https://api.netless.link/v5/rooms");
        req.Headers.TryAddWithoutValidation("token", _netlessSdkToken);
        req.Headers.TryAddWithoutValidation("region", _netlessRegion);
        req.Content = new StringContent("{\"isRecord\":false}", Encoding.UTF8, "application/json");

        using var resp = await client.SendAsync(req);
        var respBody = await resp.Content.ReadAsStringAsync();
        resp.EnsureSuccessStatusCode();

        var parsed = JsonSerializer.Deserialize<RoomResponse>(respBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        if (parsed?.Uuid is null || string.IsNullOrWhiteSpace(parsed.Uuid))
            throw new InvalidOperationException("Netless: missing uuid in /v5/rooms response");

        var uuid = parsed.Uuid;
        _channelRooms.TryAdd(channelName, uuid);
        return uuid;
    }
}

public class RoomResponse
{
    public string Uuid { get; set; } = "";
}
