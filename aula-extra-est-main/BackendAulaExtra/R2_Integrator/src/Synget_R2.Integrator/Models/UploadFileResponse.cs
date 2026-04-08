namespace Synget_R2.Integrator.Models;

public sealed record UploadFileResponse(
    string Key,
    string BucketName,
    string ContentType,
    long Size,
    string? ETag,
    string ApiDownloadUrl,
    string? PublicDownloadUrl);
