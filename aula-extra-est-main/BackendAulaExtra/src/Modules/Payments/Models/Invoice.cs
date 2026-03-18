using System;

namespace ConfidantPostgreSQL.Modules.Payments.Models
{
    public class Invoice
    {
        public Guid IdInvoice { get; set; }
        public Guid IdTransaction { get; set; }
        public Guid IdUser { get; set; }
        public string? InvoiceType { get; set; }
        public string? DocumentReference { get; set; }
        public string? PdfUrl { get; set; }
        public decimal? TotalAmount { get; set; }
        public decimal? TaxAmount { get; set; }
        public DateTime? IssuedAt { get; set; }
        public Guid? RelatedInvoiceId { get; set; }
        public string? AtStatus { get; set; }
    }
}
