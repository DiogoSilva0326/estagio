using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class ProfessorRoom
    {
        public Guid Id { get; set; }
        public Guid ProfessorId { get; set; }
        public string ProfessorName { get; set; } = string.Empty;
        public string RoomName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}
