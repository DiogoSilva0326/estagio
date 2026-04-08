using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class ProfessorLanguage
    {
        public Guid IdLanguage { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string? ProficiencyLevel { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}