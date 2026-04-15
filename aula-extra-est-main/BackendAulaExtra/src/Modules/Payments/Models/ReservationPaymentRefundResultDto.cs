using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class ReservationPaymentRefundResultDto
    {
        public Guid ReservationId { get; set; }
        public Guid? ReservationPaymentId { get; set; }
        public Guid StudentUserId { get; set; }
        public decimal RefundedAmount { get; set; }
        public decimal StudentBalanceAfter { get; set; }
        public decimal ProfessorBalanceAfter { get; set; }
        public decimal TeacherDebitAmount { get; set; }
        public string Currency { get; set; } = "EUR";
        public bool Refunded { get; set; }
    }
}
