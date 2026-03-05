using System;

namespace ConfidantPostgreSQL.Modules.Schedule.Models
{
    public class ScheduleBlock
    {
        public Guid IdScheduleBlock { get; set; }
        public Guid IdProfessor { get; set; }
        public Guid? IdDay { get; set; }

        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public int? DefaultDurationMinutes { get; set; }
        public bool? IsAvailable { get; set; }
        public string? RecurrenceRule { get; set; }

        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
