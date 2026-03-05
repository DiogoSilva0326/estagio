using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class ProfessorFeedback
    {
        public Guid IdProfessorFeedback { get; set; }
        public Guid IdProfessor { get; set; }
        public Guid IdUser { get; set; }
        public bool? IsValid { get; set; }
        public int? Rating { get; set; }
        public string? Comments { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
