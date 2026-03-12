using System;

namespace ConfidantPostgreSQL.Modules.Courses.Models
{
    public class CoursePrice
    {
        public Guid IdCoursePrice { get; set; }
        public Guid IdCourse { get; set; }
        public decimal? SessionPrice { get; set; }
        public decimal? PricePerStudent { get; set; }
        public int? NumberStudents { get; set; }
        public bool Active { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
