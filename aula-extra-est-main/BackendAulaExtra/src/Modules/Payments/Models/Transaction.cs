using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Transaction
    {
        public Guid IdTransaction { get; set; }
        public Guid WalletId { get; set; }
        public string? TransactionType { get; set; }
        public decimal Amount { get; set; }
        public decimal? BalanceBefore { get; set; }
        public decimal? BalanceAfter { get; set; }
        public int? RelatedId { get; set; }
        public Guid? RelatedEntityId { get; set; }
        public string? Status { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
