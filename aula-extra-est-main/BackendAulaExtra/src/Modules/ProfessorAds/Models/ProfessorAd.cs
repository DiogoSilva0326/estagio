using System;

namespace ConfidantPostgreSQL.Modules.ProfessorAds.Models
{
    public class ProfessorAd
    {
        public Guid IdProfessorAd { get; set; }
        public Guid IdProfessor { get; set; }
        public Guid IdCourse { get; set; }
        public Guid? IdDisciplina { get; set; }
        public string? DisciplinaNome { get; set; }
        public Guid? IdCicloEstudo { get; set; }
        public string? CicloEstudos { get; set; }
        public Guid? IdTutoringType { get; set; }
        public string? TutoringTypeName { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? LevelOfEducation { get; set; }
        public decimal? SessionPrice { get; set; }
        public string? PhotoUrl { get; set; }
        public string Status { get; set; } = "published";
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
