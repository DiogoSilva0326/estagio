using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Synget_R2.Integrator.Models;
using Synget_R2.Integrator.Options;
using Synget_R2.Integrator.Services;

namespace Synget_R2.Integrator.API.Controllers;

[ApiController]
[Route("api/storage")]
public sealed class StorageController(
    IR2StorageService storageService,
    ICloudflareBucketAdminClient adminClient,
    IOptions<CloudflareR2Options> options) : ControllerBase
{
    [HttpGet("health")]
    public async Task<ActionResult<StorageHealthResponse>> GetHealth(CancellationToken cancellationToken)
    {
        var storageCheck = await storageService.CanAccessBucketAsync(cancellationToken);
        var bucketCheck = await adminClient.CheckBucketAsync(cancellationToken);

        return Ok(new StorageHealthResponse(
            options.Value.AccountId,
            options.Value.BucketName,
            storageCheck,
            bucketCheck));
    }
}