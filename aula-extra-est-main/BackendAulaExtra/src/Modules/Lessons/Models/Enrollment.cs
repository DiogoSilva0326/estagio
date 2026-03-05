using System;

namespace ConfidantPostgreSQL.Modules.Lessons.Models
{
    public class Enrollment
    {
        public Guid IdEnrollment { get; set; }
        public Guid IdLesson { get; set; }
        public Guid IdUser { get; set; }
        public string? Status { get; set; }
        public decimal? PricePaid { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
