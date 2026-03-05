using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class ReservationPayment
    {
        public Guid IdReservationPayment { get; set; }
        public Guid ReservationId { get; set; }
        public Guid PayerWalletId { get; set; }
        public Guid? TransactionId { get; set; }
        public Guid? CommissionRuleId { get; set; }
        public decimal? Amount { get; set; }
        public string? Status { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
