using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a file attachment in chat (maps to public.chat_files table).
/// </summary>
[Table("chat_files", Schema = "public")]
public class ChatFileEntity
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; }

    /// <summary>
    /// Unique file identifier (GUID).
    /// </summary>
    [Required]
    [Column("file_id")]
    [MaxLength(255)]
    public string FileId { get; set; } = string.Empty;

    /// <summary>
    /// Original file name.
    /// </summary>
    [Required]
    [Column("file_name")]
    [MaxLength(500)]
    public string FileName { get; set; } = string.Empty;

    /// <summary>
    /// Local storage path.
    /// </summary>
    [Required]
    [Column("storage_path")]
    [MaxLength(1000)]
    public string StoragePath { get; set; } = string.Empty;

    /// <summary>
    /// MIME type of the file.
    /// </summary>
    [Required]
    [Column("content_type")]
    [MaxLength(255)]
    public string ContentType { get; set; } = string.Empty;

    /// <summary>
    /// File size in bytes.
    /// </summary>
    [Column("file_size")]
    public long FileSize { get; set; }

    /// <summary>
    /// User who uploaded the file.
    /// </summary>
    [Column("uploaded_by_user_id")]
    public Guid? UploadedByUserId { get; set; }

    /// <summary>
    /// Room/channel where the file was shared (optional).
    /// </summary>
    [Column("room_id")]
    [MaxLength(255)]
    public string? RoomId { get; set; }

    /// <summary>
    /// Associated message ID (if sent in a message).
    /// </summary>
    [Column("message_id")]
    public Guid? MessageId { get; set; }

    /// <summary>
    /// Thumbnail URL for images/videos.
    /// </summary>
    [Column("thumbnail_url")]
    [MaxLength(500)]
    public string? ThumbnailUrl { get; set; }

    /// <summary>
    /// Whether the file is active (not deleted).
    /// </summary>
    [Column("is_active")]
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// When the file was uploaded.
    /// </summary>
    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    [ForeignKey(nameof(UploadedByUserId))]
    public UserEntity? UploadedByUser { get; set; }

    [ForeignKey(nameof(MessageId))]
    public MessageEntity? Message { get; set; }
}
