using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class TutorBrowseQuery
    {
        public string? Q { get; set; }
        public Guid? AreaId { get; set; }
        public Guid? DisciplinaId { get; set; }
        public Guid? CicloEstudoId { get; set; }
        public Guid? AnoEscolaridadeId { get; set; }
        public decimal? MaxPrice { get; set; }
        public decimal? MinRating { get; set; }

        public bool Morning { get; set; }
        public bool Afternoon { get; set; }
        public bool Evening { get; set; }
        public bool Weekend { get; set; }

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 4;
    }
}
