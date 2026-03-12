using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a contact relationship between users (maps to public.contacts table).
/// </summary>
[Table("contacts", Schema = "public")]
public class ContactEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    /// <summary>
    /// The user who owns this contact.
    /// </summary>
    [Column("owner_user_id")]
    public long OwnerUserId { get; set; }

    /// <summary>
    /// The contact user.
    /// </summary>
    [Column("contact_user_id")]
    public long ContactUserId { get; set; }

    /// <summary>
    /// Optional display name override for this contact.
    /// </summary>
    [Column("display_name_override")]
    [MaxLength(255)]
    public string? DisplayNameOverride { get; set; }

    /// <summary>
    /// Contact status: pending, accepted, blocked.
    /// </summary>
    [Required]
    [Column("status")]
    [MaxLength(50)]
    public string Status { get; set; } = "pending";

    /// <summary>
    /// Optional notes about the contact.
    /// </summary>
    [Column("notes")]
    public string? Notes { get; set; }

    /// <summary>
    /// JSON metadata for extensibility.
    /// </summary>
    [Column("metadata", TypeName = "jsonb")]
    public string? Metadata { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    [ForeignKey(nameof(OwnerUserId))]
    public UserEntity? OwnerUser { get; set; }

    [ForeignKey(nameof(ContactUserId))]
    public UserEntity? ContactUser { get; set; }
}

/// <summary>
/// Contact status values.
/// </summary>
public static class ContactStatus
{
    public const string Pending = "pending";
    public const string Accepted = "accepted";
    public const string Blocked = "blocked";
}
