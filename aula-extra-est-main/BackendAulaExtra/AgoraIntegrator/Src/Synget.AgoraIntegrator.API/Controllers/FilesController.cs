using Microsoft.AspNetCore.Mvc;
using Synget.ChatIntegrator;
using Synget.AgoraIntegrator.API.DTOs;
using Synget.AgoraIntegrator.API.Data.Repositories;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for managing file uploads and downloads for chat
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class FilesController : ControllerBase
{
    private readonly ILogger<FilesController> _logger;
    private readonly IWebHostEnvironment _environment;
    private readonly IChatFileRepository _fileRepository;
    private readonly IUserRepository _userRepository;
    private const string UploadFolder = "uploads";
    private const long MaxFileSize = 50 * 1024 * 1024; // 50MB

    private static readonly HashSet<string> AllowedImageExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp"
    };

    private static readonly HashSet<string> AllowedDocumentExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".txt", ".rtf", ".csv"
    };

    private static readonly HashSet<string> AllowedVideoExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".mp4", ".webm", ".mov", ".avi"
    };

    private static readonly HashSet<string> AllowedAudioExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".mp3", ".wav", ".ogg", ".m4a"
    };

    public FilesController(
        ILogger<FilesController> logger, 
        IWebHostEnvironment environment,
        IChatFileRepository fileRepository,
        IUserRepository userRepository)
    {
        _logger = logger;
        _environment = environment;
        _fileRepository = fileRepository;
        _userRepository = userRepository;
    }

    /// <summary>
    /// Upload a file for chat attachment
    /// </summary>
    [HttpPost("upload")]
    [ProducesResponseType(typeof(FileUploadResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [RequestSizeLimit(MaxFileSize)]
    public async Task<ActionResult<FileUploadResponse>> UploadFile(
        IFormFile file, 
        [FromQuery] string? userId = null,
        [FromQuery] string? roomId = null)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(new ErrorResponse { Message = "No file provided" });
        }

        if (file.Length > MaxFileSize)
        {
            return BadRequest(new ErrorResponse { Message = $"File size exceeds the maximum allowed size of {MaxFileSize / 1024 / 1024}MB" });
        }

        var extension = Path.GetExtension(file.FileName);
        if (!IsAllowedExtension(extension))
        {
            return BadRequest(new ErrorResponse { Message = $"File type {extension} is not allowed" });
        }

        try
        {
            // Create upload directory if it doesn't exist
            var uploadPath = Path.Combine(_environment.WebRootPath ?? _environment.ContentRootPath, UploadFolder);
            if (!Directory.Exists(uploadPath))
            {
                Directory.CreateDirectory(uploadPath);
            }

            // Generate unique file ID and name
            var fileId = Guid.NewGuid().ToString();
            var safeFileName = $"{fileId}{extension}";
            var filePath = Path.Combine(uploadPath, safeFileName);

            // Save file to disk
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Generate thumbnail URL for images
            string? thumbnailUrl = null;
            if (AllowedImageExtensions.Contains(extension))
            {
                thumbnailUrl = $"/api/files/{fileId}";
            }

            // Get user ID if provided - always lookup by username first
            long? uploadedByUserId = null;
            if (!string.IsNullOrEmpty(userId))
            {
                // Try to find user by username first
                var user = await _userRepository.GetByUsernameAsync(userId);
                if (user != null)
                {
                    uploadedByUserId = user.Id;
                }
                // If userId is a pure numeric string that doesn't match a username, 
                // it might be an Agora UID - in this case, we leave uploadedByUserId as null
                // since we can't map it to a real user
                else
                {
                    _logger.LogWarning("User not found for userId: {UserId} - file will be uploaded without user association", userId);
                }
            }

            // Save to database
            var fileEntity = new ChatFileEntity
            {
                FileId = fileId,
                FileName = file.FileName,
                StoragePath = filePath,
                ContentType = file.ContentType,
                FileSize = file.Length,
                UploadedByUserId = uploadedByUserId,
                RoomId = roomId,
                ThumbnailUrl = thumbnailUrl
            };

            await _fileRepository.CreateAsync(fileEntity);

            var response = new FileUploadResponse
            {
                FileId = fileId,
                FileName = file.FileName,
                FileUrl = $"/api/files/{fileId}",
                ContentType = file.ContentType,
                FileSizeBytes = file.Length,
                ThumbnailUrl = thumbnailUrl
            };

            _logger.LogInformation("File uploaded: {FileName} ({FileSize} bytes) by user {UserId}", 
                file.FileName, file.Length, userId);

            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading file: {FileName}", file.FileName);
            return StatusCode(500, new ErrorResponse { Message = "Error uploading file" });
        }
    }

    /// <summary>
    /// Download a file by ID
    /// </summary>
    [HttpGet("{fileId}")]
    [ProducesResponseType(typeof(FileContentResult), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> DownloadFile(string fileId)
    {
        try
        {
            // First try to get from database
            var fileEntity = await _fileRepository.GetByFileIdAsync(fileId);
            
            if (fileEntity != null && System.IO.File.Exists(fileEntity.StoragePath))
            {
                var stream = new FileStream(fileEntity.StoragePath, FileMode.Open, FileAccess.Read);
                return File(stream, fileEntity.ContentType, fileEntity.FileName);
            }

            // Fallback to disk search for legacy files
            var uploadPath = Path.Combine(_environment.WebRootPath ?? _environment.ContentRootPath, UploadFolder);
            
            var files = Directory.GetFiles(uploadPath, $"{fileId}.*");
            if (files.Length == 0)
            {
                return NotFound(new ErrorResponse { Message = "File not found" });
            }

            var filePath = files[0];
            var fileName = Path.GetFileName(filePath);
            var contentType = GetContentType(Path.GetExtension(filePath));

            var fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            return File(fileStream, contentType, fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error downloading file: {FileId}", fileId);
            return NotFound(new ErrorResponse { Message = "File not found" });
        }
    }

    /// <summary>
    /// Get file info by ID
    /// </summary>
    [HttpGet("{fileId}/info")]
    [ProducesResponseType(typeof(FileUploadResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<FileUploadResponse>> GetFileInfo(string fileId)
    {
        var fileEntity = await _fileRepository.GetByFileIdAsync(fileId);
        
        if (fileEntity == null)
        {
            return NotFound(new ErrorResponse { Message = "File not found" });
        }

        return Ok(new FileUploadResponse
        {
            FileId = fileEntity.FileId,
            FileName = fileEntity.FileName,
            FileUrl = $"/api/files/{fileEntity.FileId}",
            ContentType = fileEntity.ContentType,
            FileSizeBytes = fileEntity.FileSize,
            ThumbnailUrl = fileEntity.ThumbnailUrl
        });
    }

    /// <summary>
    /// Delete a file by ID
    /// </summary>
    [HttpDelete("{fileId}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public ActionResult DeleteFile(string fileId)
    {
        try
        {
            var uploadPath = Path.Combine(_environment.WebRootPath ?? _environment.ContentRootPath, UploadFolder);
            
            var files = Directory.GetFiles(uploadPath, $"{fileId}.*");
            if (files.Length == 0)
            {
                return NotFound(new ErrorResponse { Message = "File not found" });
            }

            System.IO.File.Delete(files[0]);
            _logger.LogInformation("File deleted: {FileId}", fileId);

            return Ok(new { message = "File deleted successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting file: {FileId}", fileId);
            return StatusCode(500, new ErrorResponse { Message = "Error deleting file" });
        }
    }

    /// <summary>
    /// Get all files accessible to a user (sent or received)
    /// </summary>
    [HttpGet("user/{username}")]
    [ProducesResponseType(typeof(UserFilesResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<UserFilesResponse>> GetUserFiles(string username, [FromQuery] int limit = 100)
    {
        try
        {
            var files = await _fileRepository.GetAccessibleFilesAsync(username, limit);
            
            var response = new UserFilesResponse
            {
                Username = username,
                TotalFiles = files.Count,
                Files = files.Select(f => new UserFileInfo
                {
                    FileId = f.FileId,
                    FileName = f.FileName,
                    ContentType = f.ContentType,
                    FileSizeBytes = f.FileSize,
                    RoomId = f.RoomId,
                    UploadedBy = f.UploadedByUser?.Username ?? "Unknown",
                    UploadedByDisplayName = f.UploadedByUser?.DisplayName ?? "Unknown",
                    DownloadUrl = $"/api/files/{f.FileId}",
                    ThumbnailUrl = f.ThumbnailUrl,
                    CreatedAt = f.CreatedAt,
                    IsOwnFile = f.UploadedByUser?.Username == username
                }).ToList()
            };

            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting files for user: {Username}", username);
            return StatusCode(500, new ErrorResponse { Message = "Error getting user files" });
        }
    }

    /// <summary>
    /// Get files in a specific conversation (room)
    /// </summary>
    [HttpGet("room/{roomId}")]
    [ProducesResponseType(typeof(RoomFilesResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<RoomFilesResponse>> GetRoomFiles(string roomId, [FromQuery] string? username = null, [FromQuery] int limit = 100)
    {
        try
        {
            // Optionally check access
            if (!string.IsNullOrEmpty(username))
            {
                // For DM rooms, check if user is participant
                if (roomId.StartsWith("dm_") && !roomId.Contains(username))
                {
                    return Forbid();
                }
                // For group rooms, would need to check membership (simplified here)
            }

            var files = await _fileRepository.GetFilesInConversationAsync(roomId, limit);
            
            var response = new RoomFilesResponse
            {
                RoomId = roomId,
                TotalFiles = files.Count,
                Files = files.Select(f => new UserFileInfo
                {
                    FileId = f.FileId,
                    FileName = f.FileName,
                    ContentType = f.ContentType,
                    FileSizeBytes = f.FileSize,
                    RoomId = f.RoomId,
                    UploadedBy = f.UploadedByUser?.Username ?? "Unknown",
                    UploadedByDisplayName = f.UploadedByUser?.DisplayName ?? "Unknown",
                    DownloadUrl = $"/api/files/{f.FileId}",
                    ThumbnailUrl = f.ThumbnailUrl,
                    CreatedAt = f.CreatedAt,
                    IsOwnFile = !string.IsNullOrEmpty(username) && f.UploadedByUser?.Username == username
                }).ToList()
            };

            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting files for room: {RoomId}", roomId);
            return StatusCode(500, new ErrorResponse { Message = "Error getting room files" });
        }
    }

    /// <summary>
    /// Check if user has access to download a file
    /// </summary>
    [HttpGet("{fileId}/access/{username}")]
    [ProducesResponseType(typeof(FileAccessResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<FileAccessResponse>> CheckFileAccess(string fileId, string username)
    {
        var hasAccess = await _fileRepository.UserHasAccessAsync(username, fileId);
        return Ok(new FileAccessResponse { HasAccess = hasAccess });
    }

    private bool IsAllowedExtension(string extension)
    {
        return AllowedImageExtensions.Contains(extension) ||
               AllowedDocumentExtensions.Contains(extension) ||
               AllowedVideoExtensions.Contains(extension) ||
               AllowedAudioExtensions.Contains(extension);
    }

    private string GetContentType(string extension)
    {
        return extension.ToLowerInvariant() switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".webp" => "image/webp",
            ".bmp" => "image/bmp",
            ".pdf" => "application/pdf",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ".xls" => "application/vnd.ms-excel",
            ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            ".ppt" => "application/vnd.ms-powerpoint",
            ".pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            ".txt" => "text/plain",
            ".rtf" => "application/rtf",
            ".csv" => "text/csv",
            ".mp4" => "video/mp4",
            ".webm" => "video/webm",
            ".mov" => "video/quicktime",
            ".avi" => "video/x-msvideo",
            ".mp3" => "audio/mpeg",
            ".wav" => "audio/wav",
            ".ogg" => "audio/ogg",
            ".m4a" => "audio/mp4",
            _ => "application/octet-stream"
        };
    }
}

// DTOs
public class FileUploadResponse
{
    public string FileId { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public long FileSizeBytes { get; set; }
    public string? ThumbnailUrl { get; set; }
}

public class UserFilesResponse
{
    public string Username { get; set; } = string.Empty;
    public int TotalFiles { get; set; }
    public List<UserFileInfo> Files { get; set; } = new();
}

public class RoomFilesResponse
{
    public string RoomId { get; set; } = string.Empty;
    public int TotalFiles { get; set; }
    public List<UserFileInfo> Files { get; set; } = new();
}

public class UserFileInfo
{
    public string FileId { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public long FileSizeBytes { get; set; }
    public string? RoomId { get; set; }
    public string UploadedBy { get; set; } = string.Empty;
    public string UploadedByDisplayName { get; set; } = string.Empty;
    public string DownloadUrl { get; set; } = string.Empty;
    public string? ThumbnailUrl { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsOwnFile { get; set; }
}

public class FileAccessResponse
{
    public bool HasAccess { get; set; }
}
