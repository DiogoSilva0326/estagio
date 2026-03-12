using System;

namespace ConfidantPostgreSQL.Modules.Communication.Models
{
    public class Message
    {
        public Guid IdMessage { get; set; }
        public Guid SenderUserId { get; set; }
        public Guid ReceiverUserId { get; set; }
        public string? MessageContent { get; set; }
        public bool IsRead { get; set; }
        public DateTime? SentAt { get; set; }
        public DateTime? ReadAt { get; set; }

        public Guid? GroupRoomId { get; set; }
    }
}
