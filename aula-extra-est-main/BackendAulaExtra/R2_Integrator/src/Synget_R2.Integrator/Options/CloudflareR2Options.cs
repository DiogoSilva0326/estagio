using System.ComponentModel.DataAnnotations;

namespace Synget_R2.Integrator.Options;

public sealed class CloudflareR2Options
{
    public const string SectionName = "CloudflareR2";

    [Required]
    public string AccountId { get; init; } = string.Empty;

    [Required]
    public string BucketName { get; init; } = string.Empty;

    public string? AccessKeyId { get; init; }

    public string? SecretAccessKey { get; init; }

    public string? ApiToken { get; init; }

    public string? PublicBaseUrl { get; init; }

    public bool HasStaticS3Credentials =>
        !string.IsNullOrWhiteSpace(AccessKeyId) &&
        !string.IsNullOrWhiteSpace(SecretAccessKey);

    public string? GetPublicFileUrl(string key)
    {
        if (string.IsNullOrWhiteSpace(PublicBaseUrl))
        {
            return null;
        }

        var baseUrl = PublicBaseUrl.TrimEnd('/');
        var normalizedKey = key.TrimStart('/');
        return $"{baseUrl}/{normalizedKey}";
    }

    public string ServiceUrl => $"https://{AccountId}.r2.cloudflarestorage.com";
}
