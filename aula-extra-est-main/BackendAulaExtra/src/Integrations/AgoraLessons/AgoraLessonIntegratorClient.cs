using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace ConfidantPostgreSQL.Integrations.AgoraLessons
{
    public sealed class AgoraLessonIntegratorClient : IAgoraLessonIntegratorClient
    {
        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true,
        };

        private readonly HttpClient _httpClient;
        private readonly AgoraLessonOptions _options;

        public AgoraLessonIntegratorClient(HttpClient httpClient, AgoraLessonOptions options)
        {
            _httpClient = httpClient;
            _options = options;
        }

        public async Task<AgoraLessonClientConfig> GetClientConfigAsync(CancellationToken cancellationToken = default)
        {
            try
            {
                return await SendAsync<AgoraLessonClientConfig>(HttpMethod.Get, "/api/client-config", null, cancellationToken);
            }
            catch (AgoraLessonIntegratorException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                var legacyConfig = await SendAsync<LegacyWhiteboardConfigResponse>(HttpMethod.Get, "/api/whiteboard/config", null, cancellationToken);

                return new AgoraLessonClientConfig
                {
                    AgoraAppId = _options.AgoraAppId,
                    WhiteboardAppIdentifier = !string.IsNullOrWhiteSpace(legacyConfig.AppIdentifier)
                        ? legacyConfig.AppIdentifier
                        : _options.WhiteboardAppIdentifier,
                    WhiteboardRegion = !string.IsNullOrWhiteSpace(legacyConfig.Region)
                        ? legacyConfig.Region
                        : _options.WhiteboardRegion,
                };
            }
        }

        public async Task<AgoraSessionResponse> JoinOrCreateSessionAsync(string channelName, string userId, string displayName, CancellationToken cancellationToken = default)
        {
            try
            {
                return await SendAsync<AgoraSessionResponse>(
                    HttpMethod.Post,
                    "/api/session/join",
                    new
                    {
                        channelName,
                        userId,
                        displayName,
                    },
                    cancellationToken);
            }
            catch (AgoraLessonIntegratorException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
            {
                await SendAsync<AgoraSessionResponse>(
                    HttpMethod.Post,
                    "/api/session/create",
                    new
                    {
                        channelName,
                        hostUserId = userId,
                    },
                    cancellationToken);

                return await SendAsync<AgoraSessionResponse>(
                    HttpMethod.Post,
                    "/api/session/join",
                    new
                    {
                        channelName,
                        userId,
                        displayName,
                    },
                    cancellationToken);
            }
        }

        public async Task<AgoraTokenResponse> GenerateRtcTokenAsync(string channelName, string uid, CancellationToken cancellationToken = default)
        {
            return await SendAsync<AgoraTokenResponse>(
                HttpMethod.Post,
                "/api/token/rtc",
                new
                {
                    channelName,
                    uid,
                },
                cancellationToken);
        }

        public async Task<AgoraScreenShareTokenResponse> GenerateScreenShareTokenAsync(string channelName, uint baseUid, CancellationToken cancellationToken = default)
        {
            return await SendAsync<AgoraScreenShareTokenResponse>(
                HttpMethod.Post,
                "/api/token/screenshare",
                new
                {
                    channelName,
                    baseUid,
                },
                cancellationToken);
        }

        public async Task<AgoraWhiteboardTokenResponse> GetWhiteboardTokenAsync(string channelName, int uid, CancellationToken cancellationToken = default)
        {
            return await SendAsync<AgoraWhiteboardTokenResponse>(
                HttpMethod.Post,
                "/api/whiteboard/token",
                new
                {
                    channelName,
                    uid,
                },
                cancellationToken);
        }

        public async Task StartCallByUsernameAsync(string channelName, string username, string displayName, CancellationToken cancellationToken = default)
        {
            await SendAsync<object>(
                HttpMethod.Post,
                "/api/videocalls/start-by-username",
                new
                {
                    channelName,
                    username,
                    displayName,
                    callType = "video",
                },
                cancellationToken);
        }

        public async Task JoinCallByUsernameAsync(string channelName, string username, string displayName, CancellationToken cancellationToken = default)
        {
            await SendAsync<object>(
                HttpMethod.Post,
                "/api/videocalls/join-by-username",
                new
                {
                    channelName,
                    username,
                    displayName,
                },
                cancellationToken);
        }

        private async Task<T> SendAsync<T>(HttpMethod method, string path, object? body, CancellationToken cancellationToken)
        {
            if (!_options.IsConfigured)
            {
                throw new AgoraLessonIntegratorException("Agora Integrator base URL is not configured.");
            }

            using var request = new HttpRequestMessage(method, BuildUri(path));
            if (body != null)
            {
                request.Content = JsonContent.Create(body);
            }

            HttpResponseMessage response;
            try
            {
                response = await _httpClient.SendAsync(request, cancellationToken);
            }
            catch (HttpRequestException ex)
            {
                throw new AgoraLessonIntegratorException(
                    $"Não foi possível contactar o Agora Integrator em '{_options.BaseUrl}'. {ex.Message}");
            }

            using (response)
            {
                if (response.IsSuccessStatusCode)
                {
                    if (typeof(T) == typeof(object))
                    {
                        return (T)(object)new object();
                    }

                    var result = await response.Content.ReadFromJsonAsync<T>(JsonOptions, cancellationToken);
                    if (result == null)
                    {
                        throw new AgoraLessonIntegratorException($"Invalid response from Agora Integrator for '{path}'.");
                    }

                    return result;
                }

                var message = await ExtractErrorMessageAsync(response, cancellationToken);
                throw new AgoraLessonIntegratorException(message, response.StatusCode);
            }
        }

        private Uri BuildUri(string path)
        {
            var trimmedBaseUrl = _options.BaseUrl.TrimEnd('/');
            var normalizedPath = path.StartsWith("/", StringComparison.Ordinal) ? path : "/" + path;
            return new Uri(trimmedBaseUrl + normalizedPath, UriKind.Absolute);
        }

        private static async Task<string> ExtractErrorMessageAsync(HttpResponseMessage response, CancellationToken cancellationToken)
        {
            var body = await response.Content.ReadAsStringAsync(cancellationToken);
            if (string.IsNullOrWhiteSpace(body))
            {
                return $"Agora Integrator request failed with status {(int)response.StatusCode}.";
            }

            try
            {
                using var document = JsonDocument.Parse(body);
                if (document.RootElement.ValueKind == JsonValueKind.Object)
                {
                    if (document.RootElement.TryGetProperty("message", out var messageElement))
                    {
                        var value = messageElement.GetString();
                        if (!string.IsNullOrWhiteSpace(value))
                        {
                            return value;
                        }
                    }

                    if (document.RootElement.TryGetProperty("error", out var errorElement))
                    {
                        var value = errorElement.GetString();
                        if (!string.IsNullOrWhiteSpace(value))
                        {
                            return value;
                        }
                    }
                }
            }
            catch
            {
            }

            return body;
        }

        private sealed class LegacyWhiteboardConfigResponse
        {
            public string AppIdentifier { get; set; } = string.Empty;
            public string Region { get; set; } = string.Empty;
        }
    }
}