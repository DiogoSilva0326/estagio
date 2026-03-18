using System;

namespace ConfidantPostgreSQL.Modules.Courses.Models
{
    public class UserLessonPack
    {
        public Guid IdUserLessonPack { get; set; }
        public Guid IdUser { get; set; }
        public Guid IdLessonPack { get; set; }
        public int? RemainingCount { get; set; }
        public string? Status { get; set; }
        public DateTime? PurchasedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }
}
