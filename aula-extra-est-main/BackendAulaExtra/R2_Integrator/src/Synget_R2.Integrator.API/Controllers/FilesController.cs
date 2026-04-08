using Microsoft.AspNetCore.Mvc;
using Synget_R2.Integrator.Models;
using Synget_R2.Integrator.Options;
using Synget_R2.Integrator.Services;
using Microsoft.Extensions.Options;

namespace Synget_R2.Integrator.API.Controllers;

[ApiController]
[Route("api/files")]
public sealed class FilesController(
    IR2StorageService storageService,
    IOptions<CloudflareR2Options> options) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyCollection<StoredFileSummary>>> ListFiles(CancellationToken cancellationToken)
    {
        var files = await storageService.ListFilesAsync(cancellationToken);
        return Ok(files);
    }

    [HttpPost("upload")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<UploadFileResponse>> Upload(
        [FromForm] IFormFile file,
        [FromQuery] string? key,
        CancellationToken cancellationToken)
    {
        if (file.Length == 0)
        {
            return BadRequest(new ValidationProblemDetails(new Dictionary<string, string[]>
            {
                ["file"] = ["O ficheiro enviado está vazio."]
            }));
        }

        await using var stream = file.OpenReadStream();

        var storedFile = await storageService.UploadAsync(
            stream,
            key,
            file.FileName,
            file.ContentType,
            cancellationToken);

        var response = BuildUploadResponse(storedFile);
        return Created(response.ApiDownloadUrl, response);
    }

    [HttpPut("{**key}")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<UploadFileResponse>> Replace(
        [FromRoute] string key,
        [FromForm] IFormFile file,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(key))
        {
            return BadRequest(new { message = "A chave do ficheiro é obrigatória." });
        }

        if (file.Length == 0)
        {
            return BadRequest(new ValidationProblemDetails(new Dictionary<string, string[]>
            {
                ["file"] = ["O ficheiro enviado está vazio."]
            }));
        }

        await using var stream = file.OpenReadStream();

        var storedFile = await storageService.UploadAsync(
            stream,
            key,
            file.FileName,
            file.ContentType,
            cancellationToken);

        return Ok(BuildUploadResponse(storedFile));
    }

    [HttpGet("{**key}")]
    public async Task<IActionResult> Download([FromRoute] string key, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(key))
        {
            return BadRequest(new { message = "A chave do ficheiro é obrigatória." });
        }

        var download = await storageService.DownloadAsync(key, cancellationToken);

        if (download is null)
        {
            return NotFound(new { message = $"Ficheiro '{key}' não encontrado." });
        }

        return File(
            download.Content,
            download.ContentType,
            download.FileName,
            lastModified: download.LastModified,
            entityTag: download.ETag!,
            enableRangeProcessing: true);
    }

    [HttpDelete("{**key}")]
    public async Task<ActionResult<DeleteFileResponse>> Delete([FromRoute] string key, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(key))
        {
            return BadRequest(new { message = "A chave do ficheiro é obrigatória." });
        }

        await storageService.DeleteAsync(key, cancellationToken);

        return Ok(new DeleteFileResponse(
            key,
            true,
            "Ficheiro removido do bucket R2."));
    }

    private UploadFileResponse BuildUploadResponse(StoredUploadResult storedFile)
    {
        var apiDownloadUrl = $"{Request.Scheme}://{Request.Host}/api/files/{Uri.EscapeDataString(storedFile.Key)}";

        return new UploadFileResponse(
            storedFile.Key,
            storedFile.BucketName,
            storedFile.ContentType,
            storedFile.Size,
            storedFile.ETag,
            apiDownloadUrl,
            options.Value.GetPublicFileUrl(storedFile.Key));
    }
}