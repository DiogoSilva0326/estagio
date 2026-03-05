using System;

namespace ConfidantPostgreSQL.Modules.Student.DTOs
{
    public class SubmittedEvaluationDto
    {
        public Guid LessonFeedbackId { get; set; }
        public Guid LessonId { get; set; }
        public Guid? ProfessorId { get; set; }
        public string? ProfessorName { get; set; }
        public string? Subject { get; set; }
        public DateTime? LessonStart { get; set; }
        public DateTime? LessonEnd { get; set; }
        public int? Rating { get; set; }
        public string? Comments { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
