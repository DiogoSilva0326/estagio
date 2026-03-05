using System;

namespace ConfidantPostgreSQL.Modules.Complaints.Models
{
    public class Complaint
    {
        public Guid IdComplaint { get; set; }
        public Guid SenderUserId { get; set; }
        public Guid? ReceiverUserId { get; set; }
        public string? ComplaintType { get; set; }
        public string? ComplaintMessage { get; set; }
        public string? Status { get; set; }
        public bool IsRead { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
