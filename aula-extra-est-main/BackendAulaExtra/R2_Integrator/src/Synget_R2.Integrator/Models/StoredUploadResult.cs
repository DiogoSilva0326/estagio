namespace Synget_R2.Integrator.Models;

public sealed record StoredUploadResult(
    string Key,
    string BucketName,
    string ContentType,
    long Size,
    string? ETag);
