using System;
using System.Threading;
using System.Threading.Tasks;

namespace ConfidantPostgreSQL.Integrations.Email
{
    public class SystemSettingsPostmarkProvider : IPostmarkSettingsProvider
    {
        public async Task<(string? ApiKey, string? EmailFrom)> GetPostmarkSettingsAsync(
            bool forceRefresh = false, 
            CancellationToken cancellationToken = default)
        {
            await Task.CompletedTask;

            // This workspace snapshot doesn't include the SystemSettings module.
            // Fallback to environment variables only.
            var apiKey = Environment.GetEnvironmentVariable("POSTMARK_API_TOKEN");
            var emailFrom = Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL");
            return (apiKey, emailFrom);
        }
    }
}
