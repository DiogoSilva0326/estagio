using System;

namespace ConfidantPostgreSQL.Modules.Faq.Models
{
    public class FaqEntry
    {
        public Guid IdFaq { get; set; }
        public Guid IdFaqCategory { get; set; }
        public string Question { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string CategoryName { get; set; } = string.Empty;
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public Guid? UserId { get; set; }
    }
}
