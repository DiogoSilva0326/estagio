namespace ConfidantPostgreSQL.Integrations.CloudflareImages;

public interface ICloudflareImagesClient
{
    Task<CloudflareImagesClient.V2ListResponse> ListAsync(string? continuationToken, int perPage, CancellationToken ct);
    Task<CloudflareImagesClient.ImageDetails> GetAsync(string imageId, CancellationToken ct);
    Task DeleteAsync(string imageId, CancellationToken ct);

    Task<CloudflareImagesClient.DirectUploadResponse> CreateDirectUploadAsync(TimeSpan? expiresIn, IDictionary<string, string>? metadata, CancellationToken ct);
    Task<CloudflareImagesClient.UploadResponse> UploadFileAsync(Stream fileStream, string fileName, string? id, IDictionary<string, string>? metadata, CancellationToken ct);
    Task<CloudflareImagesClient.UploadResponse> UploadViaUrlAsync(string url, string? id, IDictionary<string, string>? metadata, CancellationToken ct);
}
