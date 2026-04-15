using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class CreatePaymentDisputeRequest
    {
        public Guid PaymentRecordId { get; set; }
        public string PaymentSource { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
    }

    public class PaymentDisputeContextDto
    {
        public Guid? TransactionId { get; set; }
        public Guid? ReservationId { get; set; }
        public Guid? ReservationPaymentId { get; set; }
        public Guid? TopupId { get; set; }
        public string PaymentReference { get; set; } = string.Empty;
        public string PaymentSource { get; set; } = string.Empty;
        public string ReporterRole { get; set; } = string.Empty;
    }
}