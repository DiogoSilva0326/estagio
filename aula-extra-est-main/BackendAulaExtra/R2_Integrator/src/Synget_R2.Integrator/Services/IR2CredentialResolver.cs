using Synget_R2.Integrator.Models;

namespace Synget_R2.Integrator.Services;

public interface IR2CredentialResolver
{
    Task<ResolvedR2Credentials> GetCredentialsAsync(CancellationToken cancellationToken = default);
}