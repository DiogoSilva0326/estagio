namespace ConfidantPostgreSQL.Integrations.CloudflareImages;

public sealed class CloudflareImagesOptions
{
    public string? AccountId { get; set; }
    public string? ApiToken { get; set; }
    public string? DeliveryBase { get; set; }

    public bool IsConfigured => !string.IsNullOrWhiteSpace(AccountId)
                             && !string.IsNullOrWhiteSpace(ApiToken);
}
