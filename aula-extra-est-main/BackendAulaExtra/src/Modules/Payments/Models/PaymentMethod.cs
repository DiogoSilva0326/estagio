using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class PaymentMethod
    {
        public Guid IdPaymentMethod { get; set; }
        public string? OwnerType { get; set; }
        public Guid OwnerUserId { get; set; }
        public string? MethodType { get; set; }
        public string? MaskedDetails { get; set; }
        public string? ProviderToken { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
