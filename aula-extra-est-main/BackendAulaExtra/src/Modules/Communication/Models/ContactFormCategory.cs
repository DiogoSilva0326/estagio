using System;

namespace ConfidantPostgreSQL.Modules.Communication.Models
{
    public class ContactFormCategory
    {
        public Guid IdContactFormCategory { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}
