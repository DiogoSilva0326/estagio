using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a participant in a video call (maps to public.video_call_participants table).
/// </summary>
[Table("video_call_participants", Schema = "public")]
public class VideoCallParticipantEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    /// <summary>
    /// The call.
    /// </summary>
    [Column("call_id")]
    public long CallId { get; set; }

    /// <summary>
    /// The participant user.
    /// </summary>
    [Column("user_id")]
    public long UserId { get; set; }

    /// <summary>
    /// Participant role: 'host', 'co-host', 'participant'.
    /// </summary>
    [Required]
    [Column("role")]
    [MaxLength(50)]
    public string Role { get; set; } = "participant";

    /// <summary>
    /// When the participant joined.
    /// </summary>
    [Column("joined_at")]
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// When the participant left.
    /// </summary>
    [Column("left_at")]
    public DateTime? LeftAt { get; set; }

    /// <summary>
    /// Duration this participant was in the call (seconds).
    /// </summary>
    [Column("duration_seconds")]
    public int? DurationSeconds { get; set; }

    /// <summary>
    /// Average video quality: 'high', 'medium', 'low'.
    /// </summary>
    [Column("avg_video_quality")]
    [MaxLength(50)]
    public string? AvgVideoQuality { get; set; }

    /// <summary>
    /// Average audio quality.
    /// </summary>
    [Column("avg_audio_quality")]
    [MaxLength(50)]
    public string? AvgAudioQuality { get; set; }

    /// <summary>
    /// Whether user had video enabled.
    /// </summary>
    [Column("had_video")]
    public bool HadVideo { get; set; } = true;

    /// <summary>
    /// Whether user had audio enabled.
    /// </summary>
    [Column("had_audio")]
    public bool HadAudio { get; set; } = true;

    /// <summary>
    /// Whether user shared screen.
    /// </summary>
    [Column("had_screen_share")]
    public bool HadScreenShare { get; set; } = false;

    /// <summary>
    /// Device/platform info: 'web', 'ios', 'android', 'desktop'.
    /// </summary>
    [Column("device_type")]
    [MaxLength(50)]
    public string? DeviceType { get; set; }

    /// <summary>
    /// Metadata (connection stats, etc.).
    /// </summary>
    [Column("metadata", TypeName = "jsonb")]
    public string? Metadata { get; set; }

    // Navigation properties
    [ForeignKey(nameof(CallId))]
    public VideoCallEntity? Call { get; set; }

    [ForeignKey(nameof(UserId))]
    public UserEntity? User { get; set; }
}

/// <summary>
/// Participant role values.
/// </summary>
public static class ParticipantRole
{
    public const string Host = "host";
    public const string CoHost = "co-host";
    public const string Participant = "participant";
}
