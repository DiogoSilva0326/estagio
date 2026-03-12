using System;

namespace ConfidantPostgreSQL.Integrations.CloudflareImages;

public sealed class CloudflareImagesNotConfiguredException : Exception
{
    public CloudflareImagesNotConfiguredException()
        : base("cloudflare_images_not_configured")
    {
    }
}
