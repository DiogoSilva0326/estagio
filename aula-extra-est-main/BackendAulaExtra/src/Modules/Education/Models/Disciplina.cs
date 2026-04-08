using System;

namespace ConfidantPostgreSQL.Modules.Education.Models
{
    public class Disciplina
    {
        public Guid IdDisciplina { get; set; }
        public Guid? IdArea { get; set; }
        public string? AreaNome { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string? Descricao { get; set; }
        public Guid? IdCicloEstudo { get; set; }
        public string? CicloEstudos { get; set; }
        public int ActiveStudentsCount { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
