using System;

namespace ConfidantPostgreSQL.Modules.Education.Models
{
    public class CicloEstudoAno
    {
        public Guid IdCicloEstudoAnoEscolaridade { get; set; }
        public Guid IdCicloEstudo { get; set; }
        public Guid IdAnoEscolaridade { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
