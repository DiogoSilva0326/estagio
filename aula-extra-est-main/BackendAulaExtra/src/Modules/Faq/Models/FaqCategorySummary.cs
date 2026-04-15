namespace ConfidantPostgreSQL.Modules.Faq.Models
{
    public class FaqCategorySummary
    {
        public Guid IdFaqCategory { get; set; }
        public string Category { get; set; } = string.Empty;
        public string? Description { get; set; }
        public int FaqCount { get; set; }
    }
}
