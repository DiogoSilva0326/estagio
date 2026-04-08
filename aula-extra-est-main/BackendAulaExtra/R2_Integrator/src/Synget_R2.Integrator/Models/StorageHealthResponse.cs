namespace Synget_R2.Integrator.Models;

public sealed record StorageHealthResponse(
    string AccountId,
    string BucketName,
    BucketAccessResult S3Api,
    BucketApiTokenResult ApiToken);
