using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class ProfessorPaymentDetailsDto
    {
        public Guid Id { get; set; }
        public Guid ReservationId { get; set; }
        public Guid? TransactionId { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string? StudentEmail { get; set; }
        public string Subject { get; set; } = string.Empty;
        public string LessonTitle { get; set; } = string.Empty;
        public DateTime? LessonStart { get; set; }
        public DateTime? LessonEnd { get; set; }
        public DateTime? PaymentDate { get; set; }
        public decimal GrossAmount { get; set; }
        public decimal PlatformFeeAmount { get; set; }
        public decimal NetAmount { get; set; }
        public decimal? CommissionPercent { get; set; }
        public decimal? FixedFee { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Reference { get; set; }
        public string? ReceiptUrl { get; set; }
        public string Currency { get; set; } = "EUR";
    }
}