using System;

namespace ConfidantPostgreSQL.Modules.Courses.Models
{
    public class PackTransaction
    {
        public Guid IdPackTransaction { get; set; }
        public Guid IdUserLessonPack { get; set; }
        public Guid? IdReservation { get; set; }
        public string? TransactionType { get; set; }
        public int? ValueChange { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
