using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class WithdrawalPolicy
    {
        public Guid IdWithdrawalPolicy { get; set; }
        public Guid? PaymentProviderId { get; set; }
        public decimal? MinAmount { get; set; }
        public decimal? MinBalanceAfter { get; set; }
        public decimal? FixedFee { get; set; }
        public decimal? PercentFee { get; set; }
        public bool? Active { get; set; }
        public DateTime? EffectiveFrom { get; set; }
        public DateTime? EffectiveTo { get; set; }
        public string? Note { get; set; }
    }
}
