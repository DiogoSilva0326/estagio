using System;

namespace ConfidantPostgreSQL.Modules.Complaints.Models
{
    public class Complaint2{
        public Guid ComplaintId { get; set; }
        public Guid SenderUserId {get; set;}
        public Guid? ReceiverUserId {get; set;}
        public string? ComplaintType {get; set;}
        public string? ComplaintMessage {get; set;}
        public Boolean IsRead {get; set;}
        public string? Status{get; set;}
        public DateTime? CreatedAt {get; set;}
        public DateTime? UpdatedAt {get; set;}
    }    
} 