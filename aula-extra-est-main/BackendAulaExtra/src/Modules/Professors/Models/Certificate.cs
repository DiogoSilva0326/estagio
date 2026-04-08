using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class Certificate
    {
        public Guid IdCertificate { get; set; }
        public Guid IdProfessor { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? FileUrl { get; set; }
        public bool? Verified { get; set; }
        public Guid? VerifiedByUserId { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
