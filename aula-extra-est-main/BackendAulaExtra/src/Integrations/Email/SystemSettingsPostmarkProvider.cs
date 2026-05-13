using System;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.SystemSettings.Service;

namespace ConfidantPostgreSQL.Integrations.Email
{
    public class SystemSettingsPostmarkProvider : IPostmarkSettingsProvider
    {
        private readonly ISystemSettingsService? _systemSettings;

        public SystemSettingsPostmarkProvider(ISystemSettingsService? systemSettings = null)
        {
            _systemSettings = systemSettings;
        }

        public async Task<(string? ApiKey, string? EmailFrom)> GetPostmarkSettingsAsync(
            bool forceRefresh = false, 
            CancellationToken cancellationToken = default)
        {
            string? apiKey = null;
            string? emailFrom = null;

            if (_systemSettings != null)
            {
                apiKey = (await _systemSettings.GetByKeyAsync("PostMarkClient.ApiKey", cancellationToken))?.SettingsValue?.Trim();
                emailFrom = (await _systemSettings.GetByKeyAsync("PostMarkClient.EmailFrom", cancellationToken))?.SettingsValue?.Trim();
            }

            apiKey ??= Environment.GetEnvironmentVariable("POSTMARK_API_TOKEN");
            emailFrom ??= Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL");
            return (apiKey, emailFrom);
        }
    }
}
