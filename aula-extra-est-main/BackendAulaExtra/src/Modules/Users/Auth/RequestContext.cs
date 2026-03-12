using System;
using System.Globalization;
using System.Linq;
using System.Threading;
using Microsoft.AspNetCore.Http;

namespace ConfidantPostgreSQL.Auth
{
    public static class RequestContext
    {
        public static void ApplyCulture(string? culture, string defaultCulture = "pt-PT")
        {
            var effective = string.IsNullOrWhiteSpace(culture) ? defaultCulture : culture;
            if (string.IsNullOrWhiteSpace(effective)) return;

            try
            {
                Thread.CurrentThread.CurrentUICulture = CultureInfo.GetCultureInfo(effective);
            }
            catch (CultureNotFoundException)
            {
                // ignore invalid culture
            }
        }

        public static void ApplyCultureFromHeader(HttpRequest request, string headerName = "culture")
        {
            if (request == null) return;
            if (!request.Headers.TryGetValue(headerName, out var cultureValues)) return;
            var culture = cultureValues.FirstOrDefault();
            if (string.IsNullOrWhiteSpace(culture)) return;

            try
            {
                Thread.CurrentThread.CurrentUICulture = CultureInfo.GetCultureInfo(culture);
            }
            catch (CultureNotFoundException)
            {
                // ignore invalid culture header
            }
        }
    }
}
