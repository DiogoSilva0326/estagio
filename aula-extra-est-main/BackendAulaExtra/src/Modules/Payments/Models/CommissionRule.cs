using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class CommissionRule
    {
        public Guid IdCommissionRule { get; set; }
        public Guid? IdProfessor { get; set; }
        public decimal? Percent { get; set; }
        public decimal? FixedFee { get; set; }
        public string? AppliesTo { get; set; }
        public DateTime? EffectiveFrom { get; set; }
        public DateTime? EffectiveTo { get; set; }
    }
}
