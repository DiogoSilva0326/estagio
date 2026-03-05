using System;

namespace ConfidantPostgreSQL.Modules.Education.Models
{
    public class AnoEscolaridade
    {
        public Guid IdAnoEscolaridade { get; set; }
        public string? Nome { get; set; }
        public int? AnoIndex { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
