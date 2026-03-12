using System;

namespace ConfidantPostgreSQL.Modules.Courses.Models
{
    public class TutoringType
    {
        public Guid IdTutoringType { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
