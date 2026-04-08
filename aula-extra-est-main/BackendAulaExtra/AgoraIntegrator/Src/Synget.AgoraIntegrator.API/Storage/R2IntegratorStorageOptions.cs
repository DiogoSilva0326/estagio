using System.Text.RegularExpressions;

namespace Synget.AgoraIntegrator.API.Storage;

public sealed class R2IntegratorStorageOptions
{
    public string BaseUrl { get; set; } = string.Empty;

    public bool IsConfigured => !string.IsNullOrWhiteSpace(BaseUrl);

    public string NormalizeBaseUrl()
    {
        var value = BaseUrl.Trim();
        if (string.IsNullOrWhiteSpace(value))
        {
            return string.Empty;
        }

        return value.EndsWith('/') ? value[..^1] : value;
    }

    public string? TryExtractObjectKey(string storagePath)
    {
        if (string.IsNullOrWhiteSpace(storagePath) ||
            !Uri.TryCreate(storagePath, UriKind.Absolute, out var storageUri))
        {
            return null;
        }

        var baseUrl = NormalizeBaseUrl();
        if (!string.IsNullOrWhiteSpace(baseUrl) &&
            Uri.TryCreate(baseUrl, UriKind.Absolute, out var baseUri) &&
            string.Equals(baseUri.Host, storageUri.Host, StringComparison.OrdinalIgnoreCase))
        {
            var basePath = baseUri.AbsolutePath.TrimEnd('/');
            var absolutePath = storageUri.AbsolutePath;

            if (!string.IsNullOrWhiteSpace(basePath) && absolutePath.StartsWith(basePath, StringComparison.OrdinalIgnoreCase))
            {
                var relative = absolutePath[basePath.Length..].TrimStart('/');
                return Uri.UnescapeDataString(relative);
            }
        }

        return Uri.UnescapeDataString(storageUri.AbsolutePath.TrimStart('/'));
    }

    public static string SlugifyFileName(string fileName)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        var nameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);
        var normalized = nameWithoutExtension.Normalize(System.Text.NormalizationForm.FormD);

        var builder = new System.Text.StringBuilder(normalized.Length);
        foreach (var character in normalized)
        {
            var category = System.Globalization.CharUnicodeInfo.GetUnicodeCategory(character);
            if (category == System.Globalization.UnicodeCategory.NonSpacingMark)
            {
                continue;
            }

            if (char.IsLetterOrDigit(character))
            {
                builder.Append(char.ToLowerInvariant(character));
                continue;
            }

            builder.Append('-');
        }

        var slug = Regex.Replace(builder.ToString(), "-+", "-").Trim('-');
        if (string.IsNullOrWhiteSpace(slug))
        {
            slug = "ficheiro";
        }

        return string.IsNullOrWhiteSpace(extension) ? slug : $"{slug}{extension}";
    }
}