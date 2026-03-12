using System;

namespace ConfidantPostgreSQL.Modules.Lessons.Models
{
    public class LessonScheduleBlock
    {
        public Guid IdLessonScheduleBlock { get; set; }
        public Guid IdLesson { get; set; }
        public Guid IdScheduleBlock { get; set; }
        public Guid? IdBlockPart { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
    }
}
