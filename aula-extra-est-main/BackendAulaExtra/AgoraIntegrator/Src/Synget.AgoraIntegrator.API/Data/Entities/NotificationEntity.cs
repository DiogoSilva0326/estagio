using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a user notification (maps to public.notifications table).
/// </summary>
[Table("notifications", Schema = "public")]
public class NotificationEntity
{
    [Key]
    [Column("id_notification")]
    public Guid Id { get; set; }

    [Column("id_user")]
    public Guid UserId { get; set; }

    [Column("type")]
    [MaxLength(100)]
    public string? Type { get; set; }

    [Column("message")]
    public string? Message { get; set; }

    [Column("was_read")]
    public bool WasRead { get; set; }

    [Column("created_at")]
    public DateTime? CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime? UpdatedAt { get; set; }
}