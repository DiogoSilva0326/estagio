using System.Collections.Generic;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class TutorBrowseResponse
    {
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int Total { get; set; }
        public List<TutorBrowseItem> Items { get; set; } = new List<TutorBrowseItem>();
    }
}
