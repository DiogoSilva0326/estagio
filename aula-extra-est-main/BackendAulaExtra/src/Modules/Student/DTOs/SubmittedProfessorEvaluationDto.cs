using System;

namespace ConfidantPostgreSQL.Modules.Student.DTOs
{
    public class SubmittedProfessorEvaluationDto
    {
        public Guid ProfessorFeedbackId { get; set; }
        public Guid ProfessorId { get; set; }
        public string ProfessorName { get; set; } = string.Empty;
        public int? Rating { get; set; }
        public string? Comments { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
