using System;

namespace ConfidantPostgreSQL.Modules.Student.DTOs
{
    public class PendingEvaluationDto
    {
        public Guid LessonId { get; set; }
        public Guid ProfessorId { get; set; }
        public string ProfessorName { get; set; } = string.Empty;
        public string? Subject { get; set; }
        public DateTime? LessonStart { get; set; }
        public DateTime? LessonEnd { get; set; }
    }
}
