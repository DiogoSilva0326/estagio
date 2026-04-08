using System.Collections.Generic;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class StudentPaymentSummaryDto
    {
        public decimal AvailableCredits { get; set; }
        public decimal TotalSpent { get; set; }
        public decimal PendingAmount { get; set; }
        public int TransactionsCount { get; set; }
        public string Currency { get; set; } = "EUR";
        public IReadOnlyList<StudentPaymentHistoryItemDto> History { get; set; } = new List<StudentPaymentHistoryItemDto>();
    }
}