using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Dispute
    {
        public Guid IdDispute { get; set; }
        public Guid? TransactionId { get; set; }
        public Guid? IdReservation { get; set; }
        public Guid? ReservationPaymentId { get; set; }
        public Guid? TopupId { get; set; }
        public Guid? RaisedByUserId { get; set; }
        public string? ReporterName { get; set; }
        public string? ReporterEmail { get; set; }
        public string? ReporterRole { get; set; }
        public string? Subject { get; set; }
        public string? Reason { get; set; }
        public string? PaymentReference { get; set; }
        public string? PaymentSource { get; set; }
        public string? Status { get; set; }
        public string? ResolutionNote { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
