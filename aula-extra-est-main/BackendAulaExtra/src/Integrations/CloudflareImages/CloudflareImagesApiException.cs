using System.Net;

namespace ConfidantPostgreSQL.Integrations.CloudflareImages;

public sealed class CloudflareImagesApiException : Exception
{
    public HttpStatusCode StatusCode { get; }
    public string? ResponseBody { get; }

    public CloudflareImagesApiException(HttpStatusCode statusCode, string? responseBody)
        : base(BuildMessage(statusCode, responseBody))
    {
        StatusCode = statusCode;
        ResponseBody = responseBody;
    }

    private static string BuildMessage(HttpStatusCode statusCode, string? responseBody)
    {
        var statusCodeValue = (int)statusCode;
        if (string.IsNullOrWhiteSpace(responseBody))
        {
            return $"cloudflare_images_api_error:{statusCodeValue}";
        }

        return $"cloudflare_images_api_error:{statusCodeValue}:{responseBody}";
    }
}