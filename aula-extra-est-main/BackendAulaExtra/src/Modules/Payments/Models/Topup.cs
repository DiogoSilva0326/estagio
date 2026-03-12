using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Topup
    {
        public Guid IdTopup { get; set; }
        public Guid WalletId { get; set; }
        public Guid? PaymentMethodId { get; set; }
        public decimal Amount { get; set; }
        public string? ProviderReference { get; set; }
        public string? TopupType { get; set; }
        public string? Status { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
