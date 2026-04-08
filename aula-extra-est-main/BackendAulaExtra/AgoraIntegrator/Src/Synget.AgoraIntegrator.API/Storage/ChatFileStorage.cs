using System.Net.Http.Headers;
using System.Text.Json;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Storage;

public class ChatFileStorage : IChatFileStorage
{
    private const string UploadFolder = "uploads";

    private readonly ILogger<ChatFileStorage> _logger;
    private readonly IWebHostEnvironment _environment;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly R2IntegratorStorageOptions _options;

    private static readonly HashSet<string> ThumbnailExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".pdf"
    };

    public ChatFileStorage(
        ILogger<ChatFileStorage> logger,
        IWebHostEnvironment environment,
        IHttpClientFactory httpClientFactory,
        R2IntegratorStorageOptions options)
    {
        _logger = logger;
        _environment = environment;
        _httpClientFactory = httpClientFactory;
        _options = options;
    }

    public bool IsCloudStorageEnabled => _options.IsConfigured;

    public async Task<ChatStoredFile> SaveAsync(IFormFile file, string fileId, CancellationToken cancellationToken = default)
    {
        if (IsCloudStorageEnabled)
        {
            return await SaveToR2IntegratorAsync(file, fileId, cancellationToken);
        }

        return await SaveToLocalAsync(file, fileId, Path.GetExtension(file.FileName), cancellationToken);
    }

    public string ResolveFileUrl(ChatFileEntity file)
    {
        if (IsStoredInCloud(file))
        {
            return file.StoragePath;
        }

        return $"/api/files/{file.FileId}";
    }

    public string? ResolveThumbnailUrl(ChatFileEntity file)
    {
        if (!string.IsNullOrWhiteSpace(file.ThumbnailUrl))
        {
            return file.ThumbnailUrl;
        }

        var extension = Path.GetExtension(file.FileName);
        if (!ThumbnailExtensions.Contains(extension))
        {
            return null;
        }

        return ResolveFileUrl(file);
    }

    public bool IsStoredInCloud(ChatFileEntity file)
    {
        return Uri.TryCreate(file.StoragePath, UriKind.Absolute, out _);
    }

    public async Task DeleteAsync(ChatFileEntity file, CancellationToken cancellationToken = default)
    {
        if (IsStoredInCloud(file))
        {
            var objectKey = _options.TryExtractObjectKey(file.StoragePath);
            if (string.IsNullOrWhiteSpace(objectKey))
            {
                _logger.LogWarning("Could not determine R2 object key for file {FileId} from {StoragePath}", file.FileId, file.StoragePath);
                return;
            }

            var client = _httpClientFactory.CreateClient(nameof(ChatFileStorage));
            var encodedObjectKey = string.Join(
                '/',
                objectKey
                    .Split('/', StringSplitOptions.RemoveEmptyEntries)
                    .Select(Uri.EscapeDataString));
            using var response = await client.DeleteAsync($"{_options.NormalizeBaseUrl()}/api/files/{encodedObjectKey}", cancellationToken);

            if (!response.IsSuccessStatusCode && response.StatusCode != System.Net.HttpStatusCode.NotFound)
            {
                var payload = await response.Content.ReadAsStringAsync(cancellationToken);
                throw new InvalidOperationException($"Falha ao remover ficheiro do R2 Integrator: {(int)response.StatusCode} {payload}");
            }

            return;
        }

        if (System.IO.File.Exists(file.StoragePath))
        {
            System.IO.File.Delete(file.StoragePath);
        }
    }

    private async Task<ChatStoredFile> SaveToR2IntegratorAsync(
        IFormFile file,
        string fileId,
        CancellationToken cancellationToken)
    {
        var extension = Path.GetExtension(file.FileName);
        var objectKey = BuildObjectKey(fileId, file.FileName, DateTime.UtcNow);
        var client = _httpClientFactory.CreateClient(nameof(ChatFileStorage));
        await using var stream = file.OpenReadStream();
        using var form = new MultipartFormDataContent();
        using var fileContent = new StreamContent(stream);

        fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse(
            string.IsNullOrWhiteSpace(file.ContentType) ? "application/octet-stream" : file.ContentType);
        form.Add(fileContent, "file", file.FileName);

        using var response = await client.PostAsync(
            $"{_options.NormalizeBaseUrl()}/api/files/upload?key={Uri.EscapeDataString(objectKey)}",
            form,
            cancellationToken);

        var payload = await response.Content.ReadAsStringAsync(cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException($"Falha ao guardar ficheiro no R2 Integrator: {(int)response.StatusCode} {payload}");
        }

        var uploadResponse = JsonSerializer.Deserialize<R2IntegratorUploadResponse>(
            payload,
            new JsonSerializerOptions(JsonSerializerDefaults.Web))
            ?? throw new InvalidOperationException("Resposta inválida do R2 Integrator.");

        var publicUrl = string.IsNullOrWhiteSpace(uploadResponse.PublicDownloadUrl)
            ? uploadResponse.ApiDownloadUrl
            : uploadResponse.PublicDownloadUrl;

        if (string.IsNullOrWhiteSpace(publicUrl))
        {
            throw new InvalidOperationException("O R2 Integrator não devolveu um URL de download utilizável.");
        }

        _logger.LogInformation("File {FileName} uploaded through R2 Integrator with key {ObjectKey}", file.FileName, objectKey);

        return new ChatStoredFile(
            StoragePath: publicUrl,
            PublicUrl: publicUrl,
            ThumbnailUrl: ThumbnailExtensions.Contains(extension) ? publicUrl : null);
    }

    private async Task<ChatStoredFile> SaveToLocalAsync(
        IFormFile file,
        string fileId,
        string extension,
        CancellationToken cancellationToken)
    {
        var uploadPath = Path.Combine(_environment.WebRootPath ?? _environment.ContentRootPath, UploadFolder);
        Directory.CreateDirectory(uploadPath);

        var safeFileName = $"{fileId}{extension}";
        var filePath = Path.Combine(uploadPath, safeFileName);

        await using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream, cancellationToken);
        }

        var publicUrl = $"/api/files/{fileId}";
        return new ChatStoredFile(
            StoragePath: filePath,
            PublicUrl: publicUrl,
            ThumbnailUrl: ThumbnailExtensions.Contains(extension) ? publicUrl : null);
    }

    private static string BuildObjectKey(string fileId, string fileName, DateTime createdAtUtc)
    {
        var friendlyFileName = R2IntegratorStorageOptions.SlugifyFileName(fileName);
        return $"chat-files/{createdAtUtc:yyyy/MM}/{fileId}-{friendlyFileName}";
    }

    private sealed record R2IntegratorUploadResponse(
        string Key,
        string BucketName,
        string ContentType,
        long Size,
        string? ETag,
        string? ApiDownloadUrl,
        string? PublicDownloadUrl);
}
