using System.Text.Json;
using System.Text.Json.Serialization;

namespace Synget.AgoraIntegrator.Utilities
{
    /// <summary>
    /// Extension methods for common operations.
    /// </summary>
    public static class Extensions
    {
        /// <summary>
        /// Check if a string is null, empty, or whitespace.
        /// </summary>
        public static bool Empty(this string? value)
        {
            return string.IsNullOrWhiteSpace(value);
        }

        /// <summary>
        /// Check if a string is not null, empty, or whitespace.
        /// </summary>
        public static bool NotEmpty(this string? value)
        {
            return !string.IsNullOrWhiteSpace(value);
        }

        /// <summary>
        /// Serialize an object to JSON.
        /// </summary>
        public static string ToJson<T>(this T obj, bool indented = false)
        {
            var options = new JsonSerializerOptions
            {
                WriteIndented = indented,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            };
            return JsonSerializer.Serialize(obj, options);
        }

        /// <summary>
        /// Deserialize JSON to an object.
        /// </summary>
        public static T? FromJson<T>(this string json)
        {
            if (string.IsNullOrWhiteSpace(json))
                return default;

            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };
            return JsonSerializer.Deserialize<T>(json, options);
        }

        /// <summary>
        /// Try to deserialize JSON to an object.
        /// </summary>
        public static bool TryFromJson<T>(this string json, out T? result)
        {
            result = default;
            try
            {
                result = json.FromJson<T>();
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Get Unix timestamp in seconds.
        /// </summary>
        public static uint ToUnixSeconds(this DateTime dateTime)
        {
            return (uint)new DateTimeOffset(dateTime).ToUnixTimeSeconds();
        }

        /// <summary>
        /// Convert Unix timestamp to DateTime.
        /// </summary>
        public static DateTime FromUnixSeconds(this uint unixSeconds)
        {
            return DateTimeOffset.FromUnixTimeSeconds(unixSeconds).DateTime;
        }
    }
}
