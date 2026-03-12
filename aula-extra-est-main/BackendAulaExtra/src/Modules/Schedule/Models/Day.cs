using System;

namespace ConfidantPostgreSQL.Modules.Schedule.Models
{
    public class Day
    {
        public Guid IdDay { get; set; }
        public string Name { get; set; } = string.Empty;
        public int? DayIndex { get; set; }
    }
}
