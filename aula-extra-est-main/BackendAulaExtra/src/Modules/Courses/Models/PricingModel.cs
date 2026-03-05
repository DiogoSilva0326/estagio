using System;

namespace ConfidantPostgreSQL.Modules.Courses.Models
{
    public class PricingModel
    {
        public Guid IdPricingModel { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
