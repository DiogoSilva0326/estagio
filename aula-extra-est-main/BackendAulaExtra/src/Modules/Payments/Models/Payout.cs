using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Payout
    {
        public Guid IdPayout { get; set; }
        public Guid? WithdrawalRequestId { get; set; }
        public Guid? TransactionId { get; set; }
        public decimal? GrossAmount { get; set; }
        public decimal? ProviderFeeAmount { get; set; }
        public decimal? PlatformFeeAmount { get; set; }
        public decimal? NetAmount { get; set; }
        public string? Status { get; set; }
        public DateTime? ProcessedAt { get; set; }
    }
}
