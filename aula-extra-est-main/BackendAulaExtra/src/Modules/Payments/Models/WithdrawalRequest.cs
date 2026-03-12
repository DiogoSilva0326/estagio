using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class WithdrawalRequest
    {
        public Guid IdWithdrawalRequest { get; set; }
        public Guid WalletId { get; set; }
        public decimal? RequestedAmount { get; set; }
        public decimal? FeeAmount { get; set; }
        public decimal? NetAmount { get; set; }
        public Guid? PaymentMethodId { get; set; }
        public Guid? PaymentProviderId { get; set; }
        public Guid? WithdrawalPolicyId { get; set; }
        public string? Status { get; set; }
        public DateTime? RequestedAt { get; set; }
        public DateTime? ProcessedAt { get; set; }
        public Guid? ProcessedByUserId { get; set; }
    }
}
