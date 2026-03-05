using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Entity representing a professor's video call room.
/// Each professor has exactly one room with a unique name.
/// </summary>
[Table("professor_rooms")]
public class ProfessorRoomEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    /// <summary>
    /// The professor user who owns this room.
    /// </summary>
    [Column("professor_id")]
    public long ProfessorId { get; set; }

    /// <summary>
    /// The professor's display name (denormalized for quick access).
    /// </summary>
    [Column("professor_name")]
    [Required]
    [MaxLength(255)]
    public string ProfessorName { get; set; } = string.Empty;

    /// <summary>
    /// Unique room name for video calls. Default: Professor_Username.
    /// Can be customized by the professor but must remain unique.
    /// </summary>
    [Column("room_name")]
    [Required]
    [MaxLength(255)]
    public string RoomName { get; set; } = string.Empty;

    /// <summary>
    /// Optional description of the room.
    /// </summary>
    [Column("description")]
    public string? Description { get; set; }

    /// <summary>
    /// Whether the room is active.
    /// </summary>
    [Column("is_active")]
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// When the room was created.
    /// </summary>
    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// When the room was last updated.
    /// </summary>
    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation property
    public UserEntity? Professor { get; set; }
}
