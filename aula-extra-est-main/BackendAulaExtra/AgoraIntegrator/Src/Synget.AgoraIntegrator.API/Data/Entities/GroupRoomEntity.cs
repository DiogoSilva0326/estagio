using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a group chat room (maps to public.group_rooms table).
/// </summary>
[Table("group_rooms", Schema = "public")]
public class GroupRoomEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    /// <summary>
    /// Unique room identifier (used in SignalR/channel name).
    /// </summary>
    [Required]
    [Column("room_code")]
    [MaxLength(255)]
    public string RoomCode { get; set; } = string.Empty;

    /// <summary>
    /// Human-friendly group name.
    /// </summary>
    [Required]
    [Column("name")]
    [MaxLength(255)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Optional description.
    /// </summary>
    [Column("description")]
    public string? Description { get; set; }

    /// <summary>
    /// Room type: 'group' (multi-user), 'direct' (1-to-1).
    /// </summary>
    [Required]
    [Column("room_type")]
    [MaxLength(50)]
    public string RoomType { get; set; } = "group";

    /// <summary>
    /// Creator/owner of the room.
    /// </summary>
    [Column("created_by_user_id")]
    public long? CreatedByUserId { get; set; }

    /// <summary>
    /// Whether the room is active.
    /// </summary>
    [Column("is_active")]
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Room avatar/image URL.
    /// </summary>
    [Column("avatar_url")]
    [MaxLength(500)]
    public string? AvatarUrl { get; set; }

    /// <summary>
    /// Settings and metadata.
    /// </summary>
    [Column("metadata", TypeName = "jsonb")]
    public string? Metadata { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    [ForeignKey(nameof(CreatedByUserId))]
    public UserEntity? CreatedByUser { get; set; }

    public ICollection<GroupRoomMemberEntity> Members { get; set; } = new List<GroupRoomMemberEntity>();
    public ICollection<MessageEntity> Messages { get; set; } = new List<MessageEntity>();
    public ICollection<VideoCallEntity> VideoCalls { get; set; } = new List<VideoCallEntity>();
}

/// <summary>
/// Room type values.
/// </summary>
public static class RoomType
{
    public const string Group = "group";
    public const string Direct = "direct";
}
