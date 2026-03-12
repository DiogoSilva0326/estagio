using System;

namespace ConfidantPostgreSQL.Modules.Schedule.Models
{
    public class BlockPart
    {
        public Guid IdBlockPart { get; set; }
        public Guid IdScheduleBlock { get; set; }
        public int? StartOffsetMinutes { get; set; }
        public int? EndOffsetMinutes { get; set; }
        public bool? IsAvailable { get; set; }
    }
}
