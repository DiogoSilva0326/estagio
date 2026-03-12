namespace AgoraBackend.agoraAPI.Controllers;

using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("")]
public class UploadController : ControllerBase
{
    private readonly ILogger<UploadController> _logger;

    public UploadController(ILogger<UploadController> logger)
    {
        _logger = logger;
    }

    // POST /upload  (multipart/form-data)
    [HttpPost("/upload")]
    [RequestSizeLimit(10 * 1024 * 1024)] // 10MB max
    public async Task<IActionResult> Upload([FromForm] IFormFile? file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(new { error = "file is required" });
        }

        try
        {
            var wwwroot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploads = Path.Combine(wwwroot, "uploads");
            if (!Directory.Exists(uploads)) Directory.CreateDirectory(uploads);

            var safeFileName = Path.GetFileName(file.FileName);
            var unique = $"{Guid.NewGuid():N}_{safeFileName}";
            var path = Path.Combine(uploads, unique);

            await using (var stream = new FileStream(path, FileMode.Create, FileAccess.Write, FileShare.None))
            {
                await file.CopyToAsync(stream);
            }

            var scheme = Request.Scheme;
            var host = Request.Host.HasValue ? Request.Host.Value : "localhost:8082";
            var url = $"{scheme}://{host}/uploads/{Uri.EscapeDataString(unique)}";

            return Ok(new { url, fileName = safeFileName, size = file.Length });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Upload failed");
            return StatusCode(500, new { error = ex.Message });
        }
    }
}
