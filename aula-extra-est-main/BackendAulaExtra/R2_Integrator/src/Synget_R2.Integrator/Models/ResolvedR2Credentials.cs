namespace Synget_R2.Integrator.Models;

public sealed record ResolvedR2Credentials(
    string AccessKeyId,
    string SecretAccessKey,
    string Source);