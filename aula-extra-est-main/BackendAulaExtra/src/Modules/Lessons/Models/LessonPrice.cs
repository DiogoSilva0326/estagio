using System;

namespace ConfidantPostgreSQL.Modules.Lessons.Models
{
    public class LessonPrice
    {
        public Guid IdLessonPrice { get; set; }
        public Guid IdLesson { get; set; }
        public decimal? SessionPrice { get; set; }
        public decimal? PricePerStudent { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
