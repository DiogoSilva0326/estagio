using System;

namespace ConfidantPostgreSQL.Modules.Courses.Models
{
    public class LessonPack
    {
        public Guid IdLessonPack { get; set; }
        public Guid IdCourse { get; set; }
        public string? Name { get; set; }
        public int NumberOfLessons { get; set; }
        public int? SessionDurationMinutes { get; set; }
        public decimal? TotalPrice { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
