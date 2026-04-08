using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class StudentPaymentHistoryItemDto
    {
        public Guid Id { get; set; }
        public string TutorName { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public DateTime? Date { get; set; }
        public decimal Amount { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? ReceiptUrl { get; set; }
        public string? Reference { get; set; }
    }
}