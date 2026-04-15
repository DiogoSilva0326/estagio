using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class ReservationPaymentProcessResultDto
    {
        public Guid ReservationId { get; set; }
        public Guid LessonId { get; set; }
        public Guid? ReservationPaymentId { get; set; }
        public decimal Amount { get; set; }
        public decimal PlatformFeeAmount { get; set; }
        public decimal TeacherNetAmount { get; set; }
        public string Currency { get; set; } = "EUR";
        public decimal StudentBalanceAfter { get; set; }
        public decimal ProfessorBalanceAfter { get; set; }
        public bool AlreadyPaid { get; set; }
    }
}
