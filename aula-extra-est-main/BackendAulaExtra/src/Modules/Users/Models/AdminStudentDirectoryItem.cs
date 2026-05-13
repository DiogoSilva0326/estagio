using System;

namespace ConfidantPostgreSQL.Modules.Users.Models
{
    public class AdminStudentDirectoryItem
    {
        public Guid UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string SchoolYear { get; set; } = string.Empty;
        public string PlanLabel { get; set; } = string.Empty;
        public string SessionsLabel { get; set; } = string.Empty;
        public string StatusLabel { get; set; } = string.Empty;
        public string AccountStateLabel { get; set; } = string.Empty;
        public decimal TotalSpent { get; set; }
        public int ActiveLessonPacks { get; set; }
        public int SessionsCount { get; set; }
    }
}