using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class StudentTopupSimulationRequest
    {
        public decimal CreditsAmount { get; set; }
        public decimal PaymentAmount { get; set; }
        public string? PackageName { get; set; }
        public string? TopupType { get; set; }

        public string GetNormalizedTopupType()
        {
            if (!string.IsNullOrWhiteSpace(TopupType)) return TopupType!.Trim();
            if (!string.IsNullOrWhiteSpace(PackageName)) return PackageName!.Trim();
            return "Top-up de créditos";
        }

        public decimal GetNormalizedPaymentAmount()
        {
            if (PaymentAmount > 0) return PaymentAmount;
            return CreditsAmount;
        }
    }
}