using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a video call session (maps to public.video_calls table).
/// </summary>
[Table("video_calls", Schema = "public")]
public class VideoCallEntity
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; }

    /// <summary>
    /// Unique call identifier (Agora channel name).
    /// </summary>
    [Required]
    [Column("channel_name")]
    [MaxLength(255)]
    public string ChannelName { get; set; } = string.Empty;

    /// <summary>
    /// Optional friendly name for the call.
    /// </summary>
    [Column("call_name")]
    [MaxLength(255)]
    public string? CallName { get; set; }

    /// <summary>
    /// Call type: 'video', 'audio', 'screen_share'.
    /// </summary>
    [Required]
    [Column("call_type")]
    [MaxLength(50)]
    public string CallType { get; set; } = "video";

    /// <summary>
    /// Associated group room (if any).
    /// </summary>
    [Column("group_room_id")]
    public Guid? GroupRoomId { get; set; }

    /// <summary>
    /// User who initiated the call.
    /// </summary>
    [Column("initiated_by_user_id")]
    public Guid? InitiatedByUserId { get; set; }

    /// <summary>
    /// Call status: 'active', 'ended', 'missed', 'declined'.
    /// </summary>
    [Required]
    [Column("status")]
    [MaxLength(50)]
    public string Status { get; set; } = "active";

    /// <summary>
    /// When the call started.
    /// </summary>
    [Column("started_at")]
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// When the call ended.
    /// </summary>
    [Column("ended_at")]
    public DateTime? EndedAt { get; set; }

    /// <summary>
    /// Calculated duration in seconds.
    /// </summary>
    [Column("duration_seconds")]
    public int? DurationSeconds { get; set; }

    /// <summary>
    /// Max concurrent participants during the call.
    /// </summary>
    [Column("max_participants")]
    public int MaxParticipants { get; set; } = 0;

    /// <summary>
    /// Recording URL (if call was recorded).
    /// </summary>
    [Column("recording_url")]
    [MaxLength(500)]
    public string? RecordingUrl { get; set; }

    /// <summary>
    /// Whether the call was recorded.
    /// </summary>
    [Column("is_recorded")]
    public bool IsRecorded { get; set; } = false;

    /// <summary>
    /// Metadata (Agora app settings, quality info, etc.).
    /// </summary>
    [Column("metadata", TypeName = "jsonb")]
    public string? Metadata { get; set; }

    // Navigation properties
    [ForeignKey(nameof(GroupRoomId))]
    public GroupRoomEntity? GroupRoom { get; set; }

    [ForeignKey(nameof(InitiatedByUserId))]
    public UserEntity? InitiatedByUser { get; set; }

    public ICollection<VideoCallParticipantEntity> Participants { get; set; } = new List<VideoCallParticipantEntity>();
}

/// <summary>
/// Call type values.
/// </summary>
public static class CallType
{
    public const string Video = "video";
    public const string Audio = "audio";
    public const string ScreenShare = "screen_share";
}

/// <summary>
/// Call status values.
/// </summary>
public static class CallStatus
{
    public const string Active = "active";
    public const string Ended = "ended";
    public const string Missed = "missed";
    public const string Declined = "declined";
}
