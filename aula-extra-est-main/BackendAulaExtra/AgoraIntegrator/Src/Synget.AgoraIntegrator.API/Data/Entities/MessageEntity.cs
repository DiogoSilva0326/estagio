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
    [Column("id_message")]
    public Guid Id { get; set; }

    /// <summary>
    /// FK to users table for sender.
    /// </summary>
    [Column("sender_user_id")]
    public Guid SenderUserId { get; set; }

    /// <summary>
    /// FK to users table for receiver (null for room/broadcast messages).
    /// </summary>
    [Column("receiver_user_id")]
    public Guid ReceiverUserId { get; set; }

    /// <summary>
    /// FK to group room (for group chat messages).
    /// </summary>
    [Column("group_room_id")]
    public Guid? GroupRoomId { get; set; }

    /// <summary>
    /// The message content.
    /// </summary>
    [Column("message_content")]
    public string? Content { get; set; }

    [Column("is_read")]
    public bool IsRead { get; set; } = false;

    /// <summary>
    /// JSON metadata (e.g., message type, file attachment info).
    /// </summary>
    [Column("metadata")]
    public string? Metadata { get; set; }

    /// <summary>
    /// When the message was created.
    /// </summary>
    [Column("sent_at")]
    public DateTime CreatedAt { get; set; }

    [Column("read_at")]
    public DateTime? ReadAt { get; set; }

    // Navigation properties
    [ForeignKey(nameof(SenderUserId))]
    public UserEntity? SenderUser { get; set; }

    [ForeignKey(nameof(ReceiverUserId))]
    public UserEntity? ReceiverUser { get; set; }

    [ForeignKey(nameof(GroupRoomId))]
    public GroupRoomEntity? GroupRoom { get; set; }
}
