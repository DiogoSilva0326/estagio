using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents an authentication session (maps to public.sessions table).
/// </summary>
[Table("sessions", Schema = "public")]
public class SessionEntity
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; }

    /// <summary>
    /// The user this session belongs to.
    /// </summary>
    [Column("user_id")]
    public Guid UserId { get; set; }

    /// <summary>
    /// Unique session token.
    /// </summary>
    [Required]
    [Column("token")]
    [MaxLength(255)]
    public string Token { get; set; } = string.Empty;

    /// <summary>
    /// When this session expires.
    /// </summary>
    [Column("expires_at")]
    public DateTime ExpiresAt { get; set; }

    /// <summary>
    /// When the session was created.
    /// </summary>
    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// IP address of the client.
    /// </summary>
    [Column("ip_address")]
    [MaxLength(50)]
    public string? IpAddress { get; set; }

    /// <summary>
    /// User agent string of the client.
    /// </summary>
    [Column("user_agent")]
    public string? UserAgent { get; set; }

    // Navigation property
    [ForeignKey("UserId")]
    public UserEntity? User { get; set; }
}
