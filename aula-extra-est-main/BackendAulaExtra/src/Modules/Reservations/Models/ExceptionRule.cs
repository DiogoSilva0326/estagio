using System;

namespace ConfidantPostgreSQL.Modules.Reservations.Models
{
    public class ExceptionRule
    {
        public Guid IdExceptionRule { get; set; }
        public Guid IdProfessor { get; set; }
        public Guid? IdScheduleBlock { get; set; }
        public string? RuleType { get; set; }
        public int? CustomDurationMinutes { get; set; }
        public int? PartStartOffsetMinutes { get; set; }
        public int? PartEndOffsetMinutes { get; set; }
        public int? OriginatingRequestId { get; set; }
        public DateTime? EffectiveFrom { get; set; }
        public DateTime? EffectiveTo { get; set; }
        public string? Note { get; set; }
    }
}
