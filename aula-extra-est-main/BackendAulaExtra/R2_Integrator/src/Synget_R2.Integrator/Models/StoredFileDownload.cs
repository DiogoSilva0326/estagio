using Microsoft.Net.Http.Headers;

namespace Synget_R2.Integrator.Models;

public sealed record StoredFileDownload(
    Stream Content,
    string FileName,
    string ContentType,
    DateTimeOffset? LastModified,
    EntityTagHeaderValue? ETag);
