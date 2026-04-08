using Synget_R2.Integrator.Models;

namespace Synget_R2.Integrator.Services;

public interface IR2StorageService
{
    Task<StoredUploadResult> UploadAsync(
        Stream content,
        string? key,
        string originalFileName,
        string? contentType,
        CancellationToken cancellationToken = default);

    Task<StoredFileDownload?> DownloadAsync(string key, CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<StoredFileSummary>> ListFilesAsync(CancellationToken cancellationToken = default);

    Task DeleteAsync(string key, CancellationToken cancellationToken = default);

    Task<BucketAccessResult> CanAccessBucketAsync(CancellationToken cancellationToken = default);
}
