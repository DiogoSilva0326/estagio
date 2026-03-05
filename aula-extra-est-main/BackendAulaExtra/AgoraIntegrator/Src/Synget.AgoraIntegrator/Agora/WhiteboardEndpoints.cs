using Synget.AgoraIntegrator.Models;
using System.Text;
using System.Text.Json;

namespace Synget.AgoraIntegrator.Agora
{
    /// <summary>
    /// Endpoints for Whiteboard (Netless) operations.
    /// Handles room creation and token generation.
    /// </summary>
    public class WhiteboardEndpoints
    {
        private readonly AgoraClient _client;
        private readonly Dictionary<string, string> _roomCache = new();

        public WhiteboardEndpoints(AgoraClient client)
        {
            _client = client ?? throw new ArgumentNullException(nameof(client));
        }

        /// <summary>
        /// Create or get an existing whiteboard room.
        /// </summary>
        /// <param name="channelName">Channel name to associate with the room.</param>
        /// <returns>Whiteboard room info.</returns>
        public async Task<AgoraWhiteboardRoom?> GetOrCreateRoomAsync(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
                throw new ArgumentException("Channel name is required.", nameof(channelName));

            var config = _client.Config;

            if (string.IsNullOrWhiteSpace(config.WhiteboardSdkToken))
            {
                return null;
            }

            // Check cache
            if (_roomCache.TryGetValue(channelName, out var cachedUuid))
            {
                var token = await CreateRoomTokenAsync(cachedUuid);
                return new AgoraWhiteboardRoom
                {
                    Uuid = cachedUuid,
                    ChannelName = channelName,
                    RoomToken = token ?? ""
                };
            }

            // Create new room
            var uuid = await CreateRoomAsync();
            if (uuid == null)
                return null;

            _roomCache[channelName] = uuid;

            var roomToken = await CreateRoomTokenAsync(uuid);
            return new AgoraWhiteboardRoom
            {
                Uuid = uuid,
                ChannelName = channelName,
                RoomToken = roomToken ?? "",
                CreatedAt = DateTime.UtcNow
            };
        }

        /// <summary>
        /// Create a new whiteboard room.
        /// </summary>
        /// <returns>Room UUID.</returns>
        private async Task<string?> CreateRoomAsync()
        {
            var config = _client.Config;

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, "https://api.netless.link/v5/rooms");
                request.Headers.TryAddWithoutValidation("token", config.WhiteboardSdkToken);
                request.Headers.TryAddWithoutValidation("region", config.WhiteboardRegion);
                request.Content = new StringContent("{}", Encoding.UTF8, "application/json");

                var response = await _client.HttpClient.SendAsync(request);
                var responseBody = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                    return null;

                var roomResponse = JsonSerializer.Deserialize<WhiteboardRoomResponse>(
                    responseBody,
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                return roomResponse?.Uuid;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Create a token for accessing a whiteboard room.
        /// </summary>
        /// <param name="uuid">Room UUID.</param>
        /// <returns>Room token.</returns>
        private async Task<string?> CreateRoomTokenAsync(string uuid)
        {
            var config = _client.Config;

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, $"https://api.netless.link/v5/tokens/rooms/{uuid}");
                request.Headers.TryAddWithoutValidation("token", config.WhiteboardSdkToken);
                request.Headers.TryAddWithoutValidation("region", config.WhiteboardRegion);
                request.Content = new StringContent(
                    "{\"lifespan\":3600000,\"role\":\"admin\"}",
                    Encoding.UTF8,
                    "application/json");

                var response = await _client.HttpClient.SendAsync(request);
                var responseBody = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                    return null;

                return JsonSerializer.Deserialize<string>(responseBody);
            }
            catch
            {
                return null;
            }
        }
    }

    internal class WhiteboardRoomResponse
    {
        public string? Uuid { get; set; }
    }
}
