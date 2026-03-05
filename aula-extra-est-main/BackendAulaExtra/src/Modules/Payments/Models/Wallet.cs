using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Wallet
    {
        public Guid IdWallet { get; set; }
        public string? OwnerType { get; set; }
        public Guid OwnerUserId { get; set; }
        public decimal? Balance { get; set; }
        public decimal? HoldAmount { get; set; }
        public string? Currency { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
