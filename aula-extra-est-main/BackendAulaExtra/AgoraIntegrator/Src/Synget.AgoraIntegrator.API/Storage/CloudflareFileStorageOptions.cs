using System.Security.Cryptography;

namespace Synget.AgoraIntegrator.API.Storage;

public class CloudflareFileStorageOptions
{
    public string AccountId { get; set; } = string.Empty;
    public string AccessKeyId { get; set; } = string.Empty;
    public string ApiToken { get; set; } = string.Empty;
    public string DeliveryBase { get; set; } = string.Empty;
    public string BucketName { get; set; } = string.Empty;

    public bool IsConfigured =>
        !string.IsNullOrWhiteSpace(ResolveAccountId()) &&
        !string.IsNullOrWhiteSpace(AccessKeyId) &&
        !string.IsNullOrWhiteSpace(ApiToken) &&
        !string.IsNullOrWhiteSpace(ResolveBucketName());

    public string ServiceUrl => $"https://{ResolveAccountId()}.r2.cloudflarestorage.com";

    public string ResolveAccountId()
    {
        if (!string.IsNullOrWhiteSpace(AccountId))
        {
            return AccountId.Trim();
        }

        if (string.IsNullOrWhiteSpace(DeliveryBase) ||
            !Uri.TryCreate(DeliveryBase, UriKind.Absolute, out var uri))
        {
            return string.Empty;
        }

        const string suffix = ".r2.cloudflarestorage.com";
        var host = uri.Host.Trim();
        if (host.EndsWith(suffix, StringComparison.OrdinalIgnoreCase))
        {
            return host[..^suffix.Length];
        }

        return string.Empty;
    }

    public string ResolveBucketName()
    {
        if (!string.IsNullOrWhiteSpace(BucketName))
        {
            return BucketName.Trim();
        }

        if (string.IsNullOrWhiteSpace(DeliveryBase))
        {
            return string.Empty;
        }

        if (!Uri.TryCreate(DeliveryBase, UriKind.Absolute, out var uri))
        {
            return string.Empty;
        }

        var firstSegment = uri.AbsolutePath
            .Split('/', StringSplitOptions.RemoveEmptyEntries)
            .FirstOrDefault();

        return firstSegment?.Trim() ?? string.Empty;
    }

    public string ResolveSecretAccessKey()
    {
        var token = ApiToken.Trim();
        if (string.IsNullOrEmpty(token))
        {
            return string.Empty;
        }

        var hash = SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(token));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }

    public string NormalizeDeliveryBase()
    {
        var value = DeliveryBase.Trim();
        if (string.IsNullOrEmpty(value))
        {
            return string.Empty;
        }

        return value.EndsWith('/') ? value[..^1] : value;
    }

    public string BuildPublicUrl(string objectKey)
    {
        var baseUrl = NormalizeDeliveryBase();
        if (string.IsNullOrEmpty(baseUrl))
        {
            return objectKey;
        }

        var encodedKey = string.Join('/', objectKey
            .Split('/', StringSplitOptions.RemoveEmptyEntries)
            .Select(Uri.EscapeDataString));

        return $"{baseUrl}/{encodedKey}";
    }

    public string? TryExtractObjectKey(string storagePath)
    {
        if (string.IsNullOrWhiteSpace(storagePath))
        {
            return null;
        }

        var normalizedBase = NormalizeDeliveryBase();
        if (!string.IsNullOrEmpty(normalizedBase) &&
            storagePath.StartsWith(normalizedBase, StringComparison.OrdinalIgnoreCase))
        {
            var relative = storagePath[normalizedBase.Length..].TrimStart('/');
            return Uri.UnescapeDataString(relative);
        }

        return null;
    }
}
