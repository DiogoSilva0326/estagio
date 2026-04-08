using System;

namespace ConfidantPostgreSQL.Modules.Users.DTOs
{
    public class UserNotificationDto
    {
        public Guid Id { get; set; }
        public string Type { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? LastUpdate { get; set; }
    }
}