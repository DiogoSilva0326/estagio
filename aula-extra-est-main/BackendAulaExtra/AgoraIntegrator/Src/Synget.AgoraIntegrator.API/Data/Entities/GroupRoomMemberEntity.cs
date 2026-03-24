using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a member of a group room (maps to public.group_room_members table).
/// </summary>
[Table("group_room_members", Schema = "public")]
public class GroupRoomMemberEntity
{
    [Key]
    [Column("id")]
    public Guid Id { get; set; }

    /// <summary>
    /// The room.
    /// </summary>
    [Column("room_id")]
    public Guid RoomId { get; set; }

    /// <summary>
    /// The member user.
    /// </summary>
    [Column("user_id")]
    public Guid UserId { get; set; }

    /// <summary>
    /// Role in the room: 'owner', 'admin', 'member'.
    /// </summary>
    [Required]
    [Column("role")]
    [MaxLength(50)]
    public string Role { get; set; } = "member";

    /// <summary>
    /// Nickname in this room (optional).
    /// </summary>
    [Column("nickname")]
    [MaxLength(255)]
    public string? Nickname { get; set; }

    /// <summary>
    /// Member status: 'active', 'left', 'kicked', 'banned'.
    /// </summary>
    [Required]
    [Column("status")]
    [MaxLength(50)]
    public string Status { get; set; } = "active";

    /// <summary>
    /// Notification settings.
    /// </summary>
    [Column("notifications_enabled")]
    public bool NotificationsEnabled { get; set; } = true;

    /// <summary>
    /// When the user joined.
    /// </summary>
    [Column("joined_at")]
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// When the user left (if applicable).
    /// </summary>
    [Column("left_at")]
    public DateTime? LeftAt { get; set; }

    /// <summary>
    /// Last read message timestamp (for unread count).
    /// </summary>
    [Column("last_read_at")]
    public DateTime? LastReadAt { get; set; }

    // Navigation properties
    [ForeignKey(nameof(RoomId))]
    public GroupRoomEntity? Room { get; set; }

    [ForeignKey(nameof(UserId))]
    public UserEntity? User { get; set; }
}

/// <summary>
/// Member role values.
/// </summary>
public static class MemberRole
{
    public const string Owner = "owner";
    public const string Admin = "admin";
    public const string Member = "member";
}

/// <summary>
/// Member status values.
/// </summary>
public static class MemberStatus
{
    public const string Active = "active";
    public const string Left = "left";
    public const string Kicked = "kicked";
    public const string Banned = "banned";
}
