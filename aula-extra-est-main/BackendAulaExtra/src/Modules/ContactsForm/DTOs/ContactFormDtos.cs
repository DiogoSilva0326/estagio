using System;

namespace ConfidantPostgreSQL.Modules.ContactsForm.DTOs
{
    public class PublicCreateContactFormSubmissionRequest
    {
        public Guid? IdContactFormCategory { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
    }

    public class UpsertContactFormSubmissionRequest
    {
        public Guid? IdContactFormCategory { get; set; }
        public string? Subject { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? Status { get; set; }
        public Guid? UserId { get; set; }
        public Guid? UserIdResponse { get; set; }
    }

    public class UpsertContactFormCategoryRequest
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
    }
}
