using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace ConfidantPostgreSQL.Integrations.Email
{
    public interface IPostmarkSettingsProvider
    {
        Task<(string? ApiKey, string? EmailFrom)> GetPostmarkSettingsAsync(bool forceRefresh = false, CancellationToken cancellationToken = default);
    }

    public interface IPostmarkService
    {
        Task<bool> SendEmailAsync(EmailSenderDto dto, CancellationToken cancellationToken = default);
    }

    public class PostmarkService : IPostmarkService
    {
        private readonly IPostmarkSettingsProvider? _settingsProvider;
        private readonly object _sync = new();
        private string? _apiKey;
        private string? _defaultFrom;
        private DateTime _lastRefreshUtc = DateTime.MinValue;
        private static readonly TimeSpan SettingsCacheDuration = TimeSpan.FromMinutes(1);
        private readonly HttpClient _httpClient;

        public PostmarkService(string? apiKey, string? defaultFrom, IPostmarkSettingsProvider? settingsProvider = null)
        {
            _settingsProvider = settingsProvider;
            
            // Default to environment variables so development environments work without DB values
            _apiKey = apiKey ?? Environment.GetEnvironmentVariable("POSTMARK_API_TOKEN");
            _defaultFrom = defaultFrom ?? Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL");
            
            _httpClient = new HttpClient
            {
                BaseAddress = new Uri("https://api.postmarkapp.com"),
                Timeout = TimeSpan.FromSeconds(30)
            };
        }

        public static PostmarkService FromEnvironment(IPostmarkSettingsProvider? settingsProvider = null)
        {
            var apiKey = Environment.GetEnvironmentVariable("POSTMARK_API_TOKEN");
            var defaultFrom = Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL");
            return new PostmarkService(apiKey, defaultFrom, settingsProvider);
        }

        public async Task<bool> SendEmailAsync(EmailSenderDto dto, CancellationToken cancellationToken = default)
        {
            // Refresh settings from DB if available
            await EnsureSettingsAsync(forceRefresh: false, cancellationToken: cancellationToken);

            if (string.IsNullOrWhiteSpace(_apiKey))
            {
                // Try force refresh if API key is missing
                await EnsureSettingsAsync(forceRefresh: true, cancellationToken: cancellationToken);
            }

            var effectiveFrom = string.IsNullOrWhiteSpace(dto.From) ? _defaultFrom : dto.From;
            
            if (string.IsNullOrWhiteSpace(_apiKey))
            {
                Console.WriteLine($"[Postmark] WARN: API key not configured, email not sent. To={dto.To}, From={effectiveFrom}");
                return false;
            }

            if (string.IsNullOrWhiteSpace(effectiveFrom))
            {
                Console.WriteLine($"[Postmark] WARN: From address not configured, email not sent. To={dto.To}, DefaultFrom={_defaultFrom}");
                return false;
            }

            try
            {
                var payload = new
                {
                    From = effectiveFrom,
                    To = dto.To,
                    Subject = dto.Subject,
                    TextBody = dto.TextBody,
                    HtmlBody = dto.HtmlBody,
                    TrackOpens = dto.TrackOpens,
                    MessageStream = dto.MessageStream,
                    Tag = dto.Tag
                };

                var json = JsonSerializer.Serialize(payload);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var request = new HttpRequestMessage(HttpMethod.Post, "/email")
                {
                    Content = content
                };
                request.Headers.Add("X-Postmark-Server-Token", _apiKey);
                request.Headers.Add("Accept", "application/json");

                var response = await _httpClient.SendAsync(request, cancellationToken);
                var responseBody = await response.Content.ReadAsStringAsync(cancellationToken);

                if (response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[Postmark] Email sent to {dto.To}");
                    return true;
                }
                else
                {
                    Console.WriteLine($"[Postmark] ERROR: {response.StatusCode} - {responseBody}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Postmark] EXCEPTION: {ex.Message}");
                return false;
            }
        }

        private async Task EnsureSettingsAsync(bool forceRefresh, CancellationToken cancellationToken)
        {
            if (_settingsProvider == null)
            {
                return; // No provider, use environment variables only
            }

            var now = DateTime.UtcNow;
            
            // Check if cache is still valid
            if (!forceRefresh &&
                _lastRefreshUtc != DateTime.MinValue &&
                now - _lastRefreshUtc < SettingsCacheDuration &&
                !string.IsNullOrWhiteSpace(_apiKey) &&
                !string.IsNullOrWhiteSpace(_defaultFrom))
            {
                return; // Cache is valid, no need to refresh
            }

            // Double-check locking pattern
            lock (_sync)
            {
                now = DateTime.UtcNow;
                if (!forceRefresh &&
                    _lastRefreshUtc != DateTime.MinValue &&
                    now - _lastRefreshUtc < SettingsCacheDuration &&
                    !string.IsNullOrWhiteSpace(_apiKey) &&
                    !string.IsNullOrWhiteSpace(_defaultFrom))
                {
                    return;
                }
            }

            try
            {
                var (apiKey, emailFrom) = await _settingsProvider
                    .GetPostmarkSettingsAsync(forceRefresh, cancellationToken)
                    .ConfigureAwait(false);

                lock (_sync)
                {
                    if (!string.IsNullOrWhiteSpace(apiKey))
                    {
                        _apiKey = apiKey;
                    }

                    if (!string.IsNullOrWhiteSpace(emailFrom))
                    {
                        _defaultFrom = emailFrom;
                    }

                    _lastRefreshUtc = DateTime.UtcNow;
                }

                Console.WriteLine($"[Postmark] Settings refreshed from database. ApiKey={(string.IsNullOrWhiteSpace(_apiKey) ? "missing" : "configured")}, EmailFrom={_defaultFrom ?? "missing"}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Postmark] Failed to refresh settings from database: {ex.Message}");

                // Fallback to environment variables
                lock (_sync)
                {
                    if (string.IsNullOrWhiteSpace(_apiKey))
                    {
                        _apiKey = Environment.GetEnvironmentVariable("POSTMARK_API_TOKEN");
                    }

                    if (string.IsNullOrWhiteSpace(_defaultFrom))
                    {
                        _defaultFrom = Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL");
                    }
                    
                    _lastRefreshUtc = DateTime.UtcNow;
                }
            }
        }
    }

    /// <summary>
    /// Disabled implementation that does nothing.
    /// </summary>
    public class PostmarkDisabledService : IPostmarkService
    {
        public static readonly PostmarkDisabledService Instance = new();
        private PostmarkDisabledService() { }

        public Task<bool> SendEmailAsync(EmailSenderDto dto, CancellationToken cancellationToken = default)
        {
            Console.WriteLine("[Postmark] DISABLED: Email would be sent to " + dto.To);
            return Task.FromResult(false);
        }
    }
}
