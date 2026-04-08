using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Storage;

public interface IChatFileStorage
{
    bool IsCloudStorageEnabled { get; }

    Task<ChatStoredFile> SaveAsync(IFormFile file, string fileId, CancellationToken cancellationToken = default);

    string ResolveFileUrl(ChatFileEntity file);

    string? ResolveThumbnailUrl(ChatFileEntity file);

    bool IsStoredInCloud(ChatFileEntity file);

    Task DeleteAsync(ChatFileEntity file, CancellationToken cancellationToken = default);
}

public sealed record ChatStoredFile(
    string StoragePath,
    string PublicUrl,
    string? ThumbnailUrl);
