namespace AgoraBackend.agoraAPI.Services;

using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using AgoraBackend.agoraAPI.Models;

/// <summary>
/// HTTP client for Agora Chat REST API
/// Makes real calls to Agora's cloud service
/// </summary>
public interface IAgoraChatRestClient
{
    Task<AgoraChatTokenResponse?> GetAppTokenAsync();
    Task<AgoraChatUserResponse?> CreateUserAsync(string userId, string password, string nickname = "");
    Task<AgoraChatUserResponse?> GetUserAsync(string userId);
    Task<AgoraChatUserResponse?> AuthenticateUserAsync(string userId, string password);
    Task<AgoraChatMessageResponse?> SendMessageAsync(string fromUserId, string toUserId, string messageText);
}

public class AgoraChatRestClient : IAgoraChatRestClient
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly string _appKey;
    private readonly string _clientId;
    private readonly string _clientSecret;
    private readonly ILogger<AgoraChatRestClient> _logger;
    
    private string? _cachedAppToken;
    private DateTime _tokenExpiry = DateTime.MinValue;

    public AgoraChatRestClient(
        IHttpClientFactory httpClientFactory,
        AppConfig config,
        ILogger<AgoraChatRestClient> logger)
    {
        _httpClientFactory = httpClientFactory;
        _appKey = config.AgoraChatAppKey;
        _clientId = config.AgoraChatClientId;
        _clientSecret = config.AgoraChatClientSecret;
        _logger = logger;
        
        if (string.IsNullOrWhiteSpace(_appKey))
        {
            _logger.LogWarning("Agora Chat AppKey not configured - chat will use in-memory storage");
        }
    }

    private (string orgName, string appName) ParseAppKey(string appKey)
    {
        var parts = appKey.Split('#');
        if (parts.Length != 2)
            throw new ArgumentException($"Invalid AppKey format: {appKey}. Expected: orgName#appName");
        return (parts[0], parts[1]);
    }

    private string GetBaseUrl()
    {
        var (orgName, appName) = ParseAppKey(_appKey);
        return $"https://a1.easemob.com/{orgName}/{appName}";
    }

    /// <summary>
    /// Get app-level token for API authentication
    /// </summary>
    public async Task<AgoraChatTokenResponse?> GetAppTokenAsync()
    {
        if (string.IsNullOrWhiteSpace(_appKey))
        {
            _logger.LogWarning("Cannot get app token - Agora Chat credentials not configured");
            return null;
        }

        // Return cached token if still valid
        if (!string.IsNullOrEmpty(_cachedAppToken) && DateTime.UtcNow < _tokenExpiry)
        {
            return new AgoraChatTokenResponse { AccessToken = _cachedAppToken };
        }

        try
        {
            var client = _httpClientFactory.CreateClient();
            var baseUrl = GetBaseUrl();
            
            var requestBody = new
            {
                grant_type = "client_credentials",
                client_id = _clientId,
                client_secret = _clientSecret
            };

            var content = new StringContent(
                JsonSerializer.Serialize(requestBody),
                Encoding.UTF8,
                "application/json");

            var response = await client.PostAsync($"{baseUrl}/token", content);
            var responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError($"Failed to get app token: {response.StatusCode} - {responseBody}");
                return null;
            }

            var tokenResponse = JsonSerializer.Deserialize<AgoraChatTokenResponse>(
                responseBody,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (tokenResponse?.AccessToken != null)
            {
                _cachedAppToken = tokenResponse.AccessToken;
                _tokenExpiry = DateTime.UtcNow.AddSeconds(tokenResponse.ExpiresIn * 0.9);
                _logger.LogInformation($"App token obtained, expires in {tokenResponse.ExpiresIn}s");
            }

            return tokenResponse;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Exception getting app token");
            return null;
        }
    }

    /// <summary>
    /// Create a user in Agora Chat
    /// </summary>
    public async Task<AgoraChatUserResponse?> CreateUserAsync(string userId, string password, string nickname = "")
    {
        if (string.IsNullOrWhiteSpace(_appKey))
        {
            _logger.LogWarning($"Cannot create user {userId} - Agora Chat not configured");
            return null;
        }

        try
        {
            var appToken = await GetAppTokenAsync();
            if (appToken?.AccessToken == null)
            {
                _logger.LogError($"Cannot create user {userId} - failed to get app token");
                return null;
            }

            var client = _httpClientFactory.CreateClient();
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {appToken.AccessToken}");
            
            var baseUrl = GetBaseUrl();
            var requestBody = new
            {
                username = userId,
                password = password,
                nickname = string.IsNullOrWhiteSpace(nickname) ? userId : nickname
            };

            var content = new StringContent(
                JsonSerializer.Serialize(requestBody),
                Encoding.UTF8,
                "application/json");

            var response = await client.PostAsync($"{baseUrl}/users", content);
            var responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning($"Create user {userId} returned {response.StatusCode}");
                
                // If user already exists, try to get their info
                if (response.StatusCode == System.Net.HttpStatusCode.BadRequest)
                {
                    _logger.LogInformation($"User {userId} likely already exists, attempting to fetch");
                    return await GetUserAsync(userId);
                }
                
                return null;
            }

            var userResponse = JsonSerializer.Deserialize<AgoraChatCreateUserResponse>(
                responseBody,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (userResponse?.Entities != null && userResponse.Entities.Count > 0)
            {
                var user = userResponse.Entities[0];
                _logger.LogInformation($"User created: {user.Username}");
                return new AgoraChatUserResponse { Username = user.Username, Uuid = user.Uuid };
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Exception creating user {userId}");
            return null;
        }
    }

    /// <summary>
    /// Get user information
    /// </summary>
    public async Task<AgoraChatUserResponse?> GetUserAsync(string userId)
    {
        if (string.IsNullOrWhiteSpace(_appKey))
        {
            _logger.LogWarning($"Cannot get user {userId} - Agora Chat not configured");
            return null;
        }

        try
        {
            var appToken = await GetAppTokenAsync();
            if (appToken?.AccessToken == null)
            {
                _logger.LogError($"Cannot get user {userId} - failed to get app token");
                return null;
            }

            var client = _httpClientFactory.CreateClient();
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {appToken.AccessToken}");
            
            var baseUrl = GetBaseUrl();
            var response = await client.GetAsync($"{baseUrl}/users/{userId}");
            var responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning($"Get user {userId} returned {response.StatusCode}");
                return null;
            }

            var userResponse = JsonSerializer.Deserialize<AgoraChatGetUserResponse>(
                responseBody,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (userResponse?.Entities != null && userResponse.Entities.Count > 0)
            {
                var user = userResponse.Entities[0];
                return new AgoraChatUserResponse { Username = user.Username, Uuid = user.Uuid };
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Exception getting user {userId}");
            return null;
        }
    }

    /// <summary>
    /// Authenticate a user by verifying their credentials with Agora Chat
    /// This validates that the user exists and password is correct
    /// </summary>
    public async Task<AgoraChatUserResponse?> AuthenticateUserAsync(string userId, string password)
    {
        if (string.IsNullOrWhiteSpace(_appKey))
        {
            _logger.LogWarning($"Cannot authenticate user {userId} - Agora Chat not configured");
            return null;
        }

        try
        {
            // Try to authenticate using Agora Chat's token endpoint with user credentials
            var client = _httpClientFactory.CreateClient();
            var baseUrl = GetBaseUrl();
            
            var requestBody = new
            {
                grant_type = "password",
                username = userId,
                password = password,
                client_id = _clientId,
                client_secret = _clientSecret
            };

            var content = new StringContent(
                JsonSerializer.Serialize(requestBody),
                Encoding.UTF8,
                "application/json");

            var response = await client.PostAsync($"{baseUrl}/token", content);
            var responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning($"User authentication failed for {userId}: {response.StatusCode}");
                return null;
            }

            // If we got here, user credentials are valid
            _logger.LogInformation($"User {userId} authenticated successfully");
            return new AgoraChatUserResponse { Username = userId };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Exception authenticating user {userId}");
            return null;
        }
    }

    /// <summary>
    /// Send a message from one user to another
    /// </summary>
    public async Task<AgoraChatMessageResponse?> SendMessageAsync(string fromUserId, string toUserId, string messageText)
    {
        if (string.IsNullOrWhiteSpace(_appKey))
        {
            _logger.LogWarning($"Cannot send message from {fromUserId} to {toUserId} - Agora Chat not configured");
            return null;
        }

        try
        {
            var appToken = await GetAppTokenAsync();
            if (appToken?.AccessToken == null)
            {
                _logger.LogError("Cannot send message - failed to get app token");
                return null;
            }

            var client = _httpClientFactory.CreateClient();
            client.DefaultRequestHeaders.Add("Authorization", $"Bearer {appToken.AccessToken}");
            
            var baseUrl = GetBaseUrl();
            var requestBody = new
            {
                from = fromUserId,
                target_type = "users",
                target = new[] { toUserId },
                msg = new
                {
                    type = "txt",
                    msg = messageText
                }
            };

            var content = new StringContent(
                JsonSerializer.Serialize(requestBody),
                Encoding.UTF8,
                "application/json");

            var response = await client.PostAsync($"{baseUrl}/messages", content);
            var responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError($"Send message failed: {response.StatusCode} - {responseBody}");
                return null;
            }

            var messageResponse = JsonSerializer.Deserialize<AgoraChatSendMessageResponse>(
                responseBody,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (messageResponse?.Data != null)
            {
                _logger.LogInformation($"Message sent from {fromUserId} to {toUserId}");
                return new AgoraChatMessageResponse 
                { 
                    Success = true, 
                    MessageId = messageResponse.Data.Id 
                };
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Exception sending message from {fromUserId} to {toUserId}");
            return null;
        }
    }
}

// ===== DTOs =====

public class AgoraChatTokenResponse
{
    [JsonPropertyName("access_token")]
    public string AccessToken { get; set; } = "";
    
    [JsonPropertyName("expires_in")]
    public int ExpiresIn { get; set; }
}

public class AgoraChatUserEntity
{
    [JsonPropertyName("uuid")]
    public string Uuid { get; set; } = "";
    
    [JsonPropertyName("username")]
    public string Username { get; set; } = "";
    
    [JsonPropertyName("nickname")]
    public string? Nickname { get; set; }
    
    [JsonPropertyName("created")]
    public long Created { get; set; }
}

public class AgoraChatCreateUserResponse
{
    [JsonPropertyName("entities")]
    public List<AgoraChatUserEntity> Entities { get; set; } = new();
}

public class AgoraChatGetUserResponse
{
    [JsonPropertyName("entities")]
    public List<AgoraChatUserEntity> Entities { get; set; } = new();
}

public class AgoraChatUserResponse
{
    public string Username { get; set; } = "";
    public string Uuid { get; set; } = "";
}

public class AgoraChatMessageData
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = "";
    
    [JsonPropertyName("timestamp")]
    public long Timestamp { get; set; }
}

public class AgoraChatSendMessageResponse
{
    [JsonPropertyName("data")]
    public AgoraChatMessageData? Data { get; set; }
}

public class AgoraChatMessageResponse
{
    public bool Success { get; set; }
    public string MessageId { get; set; } = "";
}
