using System;

namespace ConfidantPostgreSQL.Modules.Reservations.Models
{
    public class AreaLessonSummary
    {
        public int CompletedLessons { get; set; }
        public DateTime? NextLessonStart { get; set; }
        public DateTime? NextLessonEnd { get; set; }
        public string? NextLessonTitle { get; set; }
        public string? NextLessonProfessorName { get; set; }
        public string? NextLessonDisciplinaName { get; set; }
    }
}