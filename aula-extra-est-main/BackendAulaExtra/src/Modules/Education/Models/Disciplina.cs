using System;

namespace ConfidantPostgreSQL.Modules.Education.Models
{
    public class Disciplina
    {
        public Guid IdDisciplina { get; set; }
        public Guid? IdArea { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string? Descricao { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
