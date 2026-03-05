using System;

namespace ConfidantPostgreSQL.Modules.Lessons.Models
{
    public class Lesson
    {
        public Guid IdLesson { get; set; }
        public Guid? IdCourse { get; set; }
        public Guid? IdProfessor { get; set; }
        public string? Title { get; set; }
        public int? Students { get; set; }
        public int? DurationMinutes { get; set; }
        public DateTime? ScheduledStart { get; set; }
        public DateTime? ScheduledEnd { get; set; }
        public bool? UsesCustomBlocks { get; set; }
        public int? MaxStudents { get; set; }
        public decimal? BasePrice { get; set; }
    }
}
