using System;

namespace ConfidantPostgreSQL.Modules.Lessons.Models
{
    public class LessonFeedback
    {
        public Guid IdLessonFeedback { get; set; }
        public Guid IdLesson { get; set; }
        public Guid IdUser { get; set; }
        public bool IsValid { get; set; }
        public int? Rating { get; set; }
        public string? Comments { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
