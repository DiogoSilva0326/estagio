using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class PaymentProvider
    {
        public Guid IdPaymentProvider { get; set; }
        public string? Name { get; set; }
        public string? ConfigInfo { get; set; }
    }
}
