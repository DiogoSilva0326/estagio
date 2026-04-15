using System;

namespace ConfidantPostgreSQL.Modules.Faq.Models
{
    public class FaqCategory
    {
        public Guid IdFaqCategory { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public Guid? UserId { get; set; }
    }
}
