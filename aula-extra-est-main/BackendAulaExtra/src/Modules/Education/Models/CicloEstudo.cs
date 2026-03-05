using System;

namespace ConfidantPostgreSQL.Modules.Education.Models
{
    public class CicloEstudo
    {
        public Guid IdCicloEstudo { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string? Descricao { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
