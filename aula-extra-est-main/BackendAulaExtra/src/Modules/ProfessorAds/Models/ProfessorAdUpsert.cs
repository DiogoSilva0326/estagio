using System;

namespace ConfidantPostgreSQL.Modules.ProfessorAds.Models
{
    public class ProfessorAdUpsert
    {
        public Guid IdDisciplina { get; set; }
        public Guid IdTutoringType { get; set; }
        public string? Description { get; set; }
        public decimal SessionPrice { get; set; }
        public string? PhotoUrl { get; set; }
        public string Status { get; set; } = "published";
    }
}
