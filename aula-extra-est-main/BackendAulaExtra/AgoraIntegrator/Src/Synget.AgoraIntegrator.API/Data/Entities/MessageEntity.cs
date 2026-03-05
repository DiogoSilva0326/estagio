using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Synget.AgoraIntegrator.API.Data.Entities;

/// <summary>
/// Represents a chat message (maps to public.messages table).
/// </summary>
[Table("messages", Schema = "public")]
public class MessageEntity
{
    [Key]
    [Column("id")]
    public long Id { get; set; }

    /// <summary>
    /// The room/channel name this message belongs to.
    /// </summary>
    [Column("room_id")]
    [MaxLength(255)]
    public string? RoomId { get; set; }

    /// <summary>
    /// Legacy textual sender identifier (for backward compat).
    /// </summary>
    [Column("sender_id")]
    [MaxLength(255)]
    public string? SenderId { get; set; }

    /// <summary>
    /// Legacy textual receiver identifier (for broadcast messages can be null).
    /// </summary>
    [Column("receiver_id")]
    [MaxLength(255)]
    public string? ReceiverId { get; set; }

    /// <summary>
    /// FK to users table for sender.
    /// </summary>
    [Column("sender_user_id")]
    public long? SenderUserId { get; set; }

    /// <summary>
    /// FK to users table for receiver (null for room/broadcast messages).
    /// </summary>
    [Column("receiver_user_id")]
    public long? ReceiverUserId { get; set; }

    /// <summary>
    /// FK to group room (for group chat messages).
    /// </summary>
    [Column("group_room_id")]
    public long? GroupRoomId { get; set; }

    /// <summary>
    /// The message content.
    /// </summary>
    [Required]
    [Column("content")]
    public string Content { get; set; } = string.Empty;

    /// <summary>
    /// JSON metadata (e.g., message type, file attachment info).
    /// </summary>
    [Column("metadata", TypeName = "jsonb")]
    public string? Metadata { get; set; }

    /// <summary>
    /// When the message was created.
    /// </summary>
    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    [ForeignKey(nameof(SenderUserId))]
    public UserEntity? SenderUser { get; set; }

    [ForeignKey(nameof(ReceiverUserId))]
    public UserEntity? ReceiverUser { get; set; }

    [ForeignKey(nameof(GroupRoomId))]
    public GroupRoomEntity? GroupRoom { get; set; }
}
