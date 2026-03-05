using System;

namespace ConfidantPostgreSQL.Modules.Student.DTOs
{
    public class PendingProfessorEvaluationDto
    {
        public Guid ProfessorId { get; set; }
        public string ProfessorName { get; set; } = string.Empty;
        public DateTime? LastLessonStart { get; set; }
        public DateTime? LastLessonEnd { get; set; }
    }
}
