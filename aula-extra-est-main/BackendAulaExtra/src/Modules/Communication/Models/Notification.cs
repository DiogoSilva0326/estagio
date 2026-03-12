using System;

namespace ConfidantPostgreSQL.Modules.Communication.Models
{
    public class Notification
    {
        public Guid IdNotification { get; set; }
        public Guid IdUser { get; set; }
        public string? Type { get; set; }
        public string? Message { get; set; }
        public bool WasRead { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
