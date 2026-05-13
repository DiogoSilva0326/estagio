using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class AdminPaymentOverviewItemDto
    {
        public Guid Id { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string TutorName { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public DateTime? PaymentDate { get; set; }
        public decimal GrossAmount { get; set; }
        public decimal PlatformFeeAmount { get; set; }
        public decimal NetAmount { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Reference { get; set; }
        public string Currency { get; set; } = "EUR";
    }
}