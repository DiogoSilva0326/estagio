using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class ReservationPaymentReviewDto
    {
        public Guid ReservationId { get; set; }
        public Guid LessonId { get; set; }
        public string? ReservationStatus { get; set; }
        public string? LessonTitle { get; set; }
        public string? Subject { get; set; }
        public string? TutoringTypeName { get; set; }
        public string? TeacherName { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public decimal Amount { get; set; }
        public decimal AvailableCredits { get; set; }
        public string Currency { get; set; } = "EUR";
        public bool CanAfford { get; set; }
        public bool AlreadyPaid { get; set; }
        public Guid? ReservationPaymentId { get; set; }
        public string? PaymentStatus { get; set; }
        public decimal PlatformFeeAmount { get; set; }
        public decimal TeacherNetAmount { get; set; }
    }
}
