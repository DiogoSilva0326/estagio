using System;

namespace ConfidantPostgreSQL.Modules.Communication.Models
{
    public class Contact
    {
        public Guid Id { get; set; }
        public Guid OwnerUserId { get; set; }
        public Guid ContactUserId { get; set; }
        public string? DisplayNameOverride { get; set; }
        public string Status { get; set; } = "pending";
        public string? Notes { get; set; }
        public string? Metadata { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}
