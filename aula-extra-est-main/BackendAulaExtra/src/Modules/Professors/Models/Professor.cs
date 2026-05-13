using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class Professor
    {
        public Guid IdProfessor { get; set; }
        public Guid IdUser { get; set; }
        public string? CurrentSchool { get; set; }
        public int? YearsExperience { get; set; }
        public string? Photo { get; set; }
        public string? Biography { get; set; }
        public string? PresentationVideoUrl { get; set; }
        public string? Vat { get; set; }
        public string? Iban { get; set; }
        public string? IbanDocumentUrl { get; set; }
        public bool? IsVerifiedIban { get; set; }
        public bool? IsActive { get; set; }
        public bool? IsVerified { get; set; }
        public bool? IsRejected { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
