using System;

namespace ConfidantPostgreSQL.Modules.Communication.Models
{
    public class GroupRoom
    {
        public Guid Id { get; set; }
        public string RoomCode { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string RoomType { get; set; } = "group";
        public Guid? CreatedByUserId { get; set; }
        public bool IsActive { get; set; }
        public string? AvatarUrl { get; set; }
        public string? Metadata { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}
