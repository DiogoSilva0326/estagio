using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a user in the chat system (maps to public.users table).
/// </summary>
[Table("users", Schema = "public")]
public class UserEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    /// <summary>
    /// Unique username for the user (login name).
    /// </summary>
    [Required]
    [Column("username")]
    [MaxLength(255)]
    public string Username { get; set; } = string.Empty;

    /// <summary>
    /// Human-friendly display name shown in chat UI.
    /// </summary>
    [Column("display_name")]
    [MaxLength(255)]
    public string? DisplayName { get; set; }

    /// <summary>
    /// Optional email address.
    /// </summary>
    [Column("email")]
    [MaxLength(255)]
    public string? Email { get; set; }

    /// <summary>
    /// External provider ID (Agora user ID, OAuth subject, etc).
    /// </summary>
    [Column("external_id")]
    [MaxLength(255)]
    public string? ExternalId { get; set; }

    /// <summary>
    /// Optional JSON metadata.
    /// </summary>
    [Column("metadata", TypeName = "jsonb")]
    public string? Metadata { get; set; }

    /// <summary>
    /// BCrypt password hash for authentication.
    /// </summary>
    [Column("password_hash")]
    [MaxLength(255)]
    public string? PasswordHash { get; set; }

    /// <summary>
    /// User role: 'admin', 'professor', 'aluno'.
    /// </summary>
    [Required]
    [Column("role")]
    [MaxLength(50)]
    public string Role { get; set; } = "aluno";

    /// <summary>
    /// Whether the user account is active.
    /// </summary>
    [Column("is_active")]
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Last login timestamp.
    /// </summary>
    [Column("last_login_at")]
    public DateTime? LastLoginAt { get; set; }

    /// <summary>
    /// When the user was created.
    /// </summary>
    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public ICollection<MessageEntity> SentMessages { get; set; } = new List<MessageEntity>();
    public ICollection<MessageEntity> ReceivedMessages { get; set; } = new List<MessageEntity>();
    public ICollection<ContactEntity> Contacts { get; set; } = new List<ContactEntity>();
    public ICollection<ContactEntity> ContactOf { get; set; } = new List<ContactEntity>();
    public ICollection<GroupRoomMemberEntity> RoomMemberships { get; set; } = new List<GroupRoomMemberEntity>();
    public ICollection<VideoCallParticipantEntity> CallParticipations { get; set; } = new List<VideoCallParticipantEntity>();
}
