using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Refund
    {
        public Guid IdRefund { get; set; }
        public Guid TransactionId { get; set; }
        public Guid ToWalletId { get; set; }
        public decimal? Amount { get; set; }
        public string? Status { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
