using Synget_R2.Integrator.Models;

namespace Synget_R2.Integrator.Services;

public interface ICloudflareBucketAdminClient
{
    Task<BucketApiTokenResult> CheckBucketAsync(CancellationToken cancellationToken = default);
}
