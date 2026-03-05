using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Dispute
    {
        public Guid IdDispute { get; set; }
        public Guid TransactionId { get; set; }
        public Guid? RaisedByUserId { get; set; }
        public string? Reason { get; set; }
        public string? Status { get; set; }
        public string? ResolutionNote { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
