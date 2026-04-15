using System;

namespace ConfidantPostgreSQL.Modules.ContactsForm.Models
{
    public class ContactFormSubmission
    {
        public Guid IdContactFormSubmission { get; set; }
        public Guid? IdContactFormCategory { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string Status { get; set; } = "não lida";
        public Guid? UserId { get; set; }
        public Guid? UserIdResponse { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public string? CategoryName { get; set; }
        public string? ResponseUserDisplayName { get; set; }
    }
}
