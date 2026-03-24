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
    [Column("id_user")]
    public Guid Id { get; set; }

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
    [Required]
    [Column("email")]
    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// External provider ID (Agora user ID, OAuth subject, etc).
    /// </summary>
    [NotMapped]
    public string? ExternalId { get; set; }

    /// <summary>
    /// Optional JSON metadata.
    /// </summary>
    [NotMapped]
    public string? Metadata { get; set; }

    /// <summary>
    /// BCrypt password hash for authentication.
    /// </summary>
    [Column("password")]
    [MaxLength(255)]
    public string? PasswordHash { get; set; }

    /// <summary>
    /// User role: 'admin', 'professor', 'aluno'.
    /// </summary>
    [NotMapped]
    public string Role { get; set; } = "aluno";

    /// <summary>
    /// Whether the user account is active.
    /// </summary>
    [Column("inactive")]
    public bool Inactive { get; set; } = false;

    [NotMapped]
    public bool IsActive
    {
        get => !Inactive;
        set => Inactive = !value;
    }

    /// <summary>
    /// Last login timestamp.
    /// </summary>
    [NotMapped]
    public DateTime? LastLoginAt { get; set; }

    /// <summary>
    /// When the user was created.
    /// </summary>
    [Column("creation_date")]
    public DateTime CreatedAt { get; set; }

    [Column("last_update")]
    public DateTime UpdatedAt { get; set; }

    [Column("first_name")]
    [MaxLength(200)]
    public string? FirstName { get; set; }

    [Column("last_name")]
    [MaxLength(200)]
    public string? LastName { get; set; }

    // Navigation properties
    public ICollection<MessageEntity> SentMessages { get; set; } = new List<MessageEntity>();
    public ICollection<MessageEntity> ReceivedMessages { get; set; } = new List<MessageEntity>();
    public ICollection<ContactEntity> Contacts { get; set; } = new List<ContactEntity>();
    public ICollection<ContactEntity> ContactOf { get; set; } = new List<ContactEntity>();
    public ICollection<GroupRoomMemberEntity> RoomMemberships { get; set; } = new List<GroupRoomMemberEntity>();
    public ICollection<VideoCallParticipantEntity> CallParticipations { get; set; } = new List<VideoCallParticipantEntity>();
}
