using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class ProfessorDisciplinaUpsert
    {
        public Guid? IdDisciplina { get; set; }
        public Guid IdArea { get; set; }
        public Guid? IdCicloEstudo { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string? Descricao { get; set; }
        public bool IsActive { get; set; } = true;
    }
}