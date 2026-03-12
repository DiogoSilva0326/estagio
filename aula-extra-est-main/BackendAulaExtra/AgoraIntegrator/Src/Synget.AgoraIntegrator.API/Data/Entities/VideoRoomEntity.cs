using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a video call room (maps to public.video_rooms table).
/// Only professors and admins can create these.
/// </summary>
[Table("video_rooms", Schema = "public")]
public class VideoRoomEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    /// <summary>
    /// Unique channel name for the video room (Agora channel).
    /// </summary>
    [Required]
    [Column("channel_name")]
    [MaxLength(255)]
    public string ChannelName { get; set; } = string.Empty;

    /// <summary>
    /// The user who created/hosts this room.
    /// </summary>
    [Column("host_user_id")]
    public long HostUserId { get; set; }

    /// <summary>
    /// Username of the host (for quick reference).
    /// </summary>
    [Column("host_username")]
    [MaxLength(100)]
    public string? HostUsername { get; set; }

    /// <summary>
    /// Display title for the room.
    /// </summary>
    [Column("title")]
    [MaxLength(255)]
    public string? Title { get; set; }

    /// <summary>
    /// Whether the room is currently active.
    /// </summary>
    [Column("is_active")]
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Whether the host (professor) has joined the room.
    /// Students can only join after this is true.
    /// </summary>
    [Column("host_joined")]
    public bool HostJoined { get; set; } = false;

    /// <summary>
    /// When the call started.
    /// </summary>
    [Column("started_at")]
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// When the call ended (null if still active).
    /// </summary>
    [Column("ended_at")]
    public DateTime? EndedAt { get; set; }

    /// <summary>
    /// Total duration in seconds (calculated when room ends).
    /// </summary>
    [Column("total_duration_seconds")]
    public int TotalDurationSeconds { get; set; } = 0;

    /// <summary>
    /// Maximum number of participants allowed.
    /// </summary>
    [Column("max_participants")]
    public int MaxParticipants { get; set; } = 50;

    /// <summary>
    /// When the room was created.
    /// </summary>
    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    [ForeignKey("HostUserId")]
    public UserEntity? Host { get; set; }

    public ICollection<VideoRoomParticipantEntity> Participants { get; set; } = new List<VideoRoomParticipantEntity>();
}

/// <summary>
/// Represents a participant in a video room.
/// </summary>
[Table("video_room_participants", Schema = "public")]
public class VideoRoomParticipantEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    [Column("video_room_id")]
    public long VideoRoomId { get; set; }

    [Column("user_id")]
    public long UserId { get; set; }

    [Column("joined_at")]
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    [Column("left_at")]
    public DateTime? LeftAt { get; set; }

    [Column("role")]
    [MaxLength(50)]
    public string Role { get; set; } = "participant";

    // Navigation properties
    [ForeignKey("VideoRoomId")]
    public VideoRoomEntity? VideoRoom { get; set; }

    [ForeignKey("UserId")]
    public UserEntity? User { get; set; }
}
