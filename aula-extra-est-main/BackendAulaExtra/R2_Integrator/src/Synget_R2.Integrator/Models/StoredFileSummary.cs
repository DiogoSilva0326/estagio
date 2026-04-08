namespace Synget_R2.Integrator.Models;

public sealed record StoredFileSummary(
    string Key,
    long Size,
    string? ETag,
    DateTimeOffset? LastModified);
