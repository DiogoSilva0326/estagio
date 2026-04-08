namespace Synget_R2.Integrator.Models;

public sealed record BucketApiTokenResult(
    bool Configured,
    bool Success,
    bool BucketFound,
    string Message);
