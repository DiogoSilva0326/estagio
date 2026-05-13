using System;

namespace ConfidantPostgreSQL.Modules.Complaints.Models
{
    public class Complaint
    {
        public Guid IdComplaint { get; set; }
        public Guid SenderUserId { get; set; }
        public Guid? ReceiverUserId { get; set; }
        public string? ComplaintType { get; set; }
        public string? ComplaintSubject { get; set; }
        public string? ComplaintMessage { get; set; }
        public string? Status { get; set; }
        public bool IsRead { get; set; }
        public string? SenderDisplayName { get; set; }
        public string? SenderEmail { get; set; }
        public string? ReceiverDisplayName { get; set; }
        public string? SenderRole { get; set; }
        public string? ReceiverRole { get; set; }
        public string? RelationshipContext { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class ReplyToComplaintRequest
    {
        public string? ResponseMessage { get; set; }
        public string? Status { get; set; }
    }
}
