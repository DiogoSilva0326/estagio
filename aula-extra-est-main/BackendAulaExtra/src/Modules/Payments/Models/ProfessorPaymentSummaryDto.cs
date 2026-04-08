using System.Collections.Generic;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class ProfessorPaymentSummaryDto
    {
        public decimal TotalReceived { get; set; }
        public decimal PendingAmount { get; set; }
        public decimal TotalThisMonth { get; set; }
        public int TransactionsCount { get; set; }
        public string Currency { get; set; } = "EUR";
        public IReadOnlyList<ProfessorPaymentHistoryItemDto> History { get; set; } = new List<ProfessorPaymentHistoryItemDto>();
    }
}