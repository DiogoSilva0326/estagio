using System;

namespace ConfidantPostgreSQL.Modules.Communication.DTOs
{
    public class ContactUserSummary
    {
        public Guid ContactId { get; set; }
        public Guid ContactUserId { get; set; }
        public string? Username { get; set; }
        public string? DisplayName { get; set; }
        public string Status { get; set; } = "pending";
        public string? LastMessage { get; set; }
        public DateTime? LastMessageAt { get; set; }
    }
}
