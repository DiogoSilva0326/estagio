using System;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.IdentityModel.Tokens;

namespace ConfidantPostgreSQL.Auth
{
    public static class JwtActor
    {
        public static bool TryGetActorUserId(HttpRequest request, out Guid userId)
        {
            userId = Guid.Empty;
            if (request == null) return false;

            request.Headers.TryGetValue("token", out var tokenValues);
            request.Headers.TryGetValue("Authorization", out var authValues);
            var raw = NormalizeJwtToken(tokenValues.FirstOrDefault() ?? authValues.FirstOrDefault());
            if (string.IsNullOrWhiteSpace(raw)) return false;

            return TryGetActorUserIdFromJwtRaw(raw, out userId);
        }

        public static bool TryGetActorUserIdFromJwt(string? token, out Guid userId)
        {
            userId = Guid.Empty;
            var raw = NormalizeJwtToken(token);
            if (string.IsNullOrWhiteSpace(raw)) return false;
            return TryGetActorUserIdFromJwtRaw(raw, out userId);
        }

        private static bool TryGetActorUserIdFromJwtRaw(string raw, out Guid userId)
        {
            userId = Guid.Empty;
            var secret = Environment.GetEnvironmentVariable("JWT_SECRET") ?? "replace_this_dev_secret";
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret));
            var validation = new TokenValidationParameters
            {
                ValidateIssuer = false,
                ValidateAudience = false,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = key,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(1),
            };

            try
            {
                var handler = new JwtSecurityTokenHandler();
                var principal = handler.ValidateToken(raw, validation, out _);
                var sub = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value
                          ?? principal.FindFirst("sub")?.Value
                          ?? principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                return Guid.TryParse(sub, out userId) && userId != Guid.Empty;
            }
            catch
            {
                userId = Guid.Empty;
                return false;
            }
        }

        private static string? NormalizeJwtToken(string? token)
        {
            if (string.IsNullOrWhiteSpace(token)) return null;

            var trimmed = token.Trim().Trim('"');
            if (trimmed.StartsWith("Bearer", StringComparison.OrdinalIgnoreCase))
                trimmed = trimmed.Substring("Bearer".Length).Trim();

            var parts = trimmed.Split(new[] { ' ', '\t', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var p in parts)
            {
                var idx = p.IndexOf("eyJ", StringComparison.Ordinal);
                var candidate = idx >= 0 ? p.Substring(idx) : p;
                if (candidate.Count(c => c == '.') >= 2) return candidate.Trim();
            }
            var legacyIdx = trimmed.IndexOf("eyJ", StringComparison.Ordinal);
            if (legacyIdx >= 0) return trimmed.Substring(legacyIdx).Trim();
            return trimmed;
        }
    }
}
