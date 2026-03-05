using System;

namespace ConfidantPostgreSQL.Modules.Communication.Models
{
    public class GroupRoomMember
    {
        public Guid Id { get; set; }
        public Guid RoomId { get; set; }
        public Guid UserId { get; set; }
        public string Role { get; set; } = "member";
        public string? Nickname { get; set; }
        public string Status { get; set; } = "active";
        public bool NotificationsEnabled { get; set; }
        public DateTimeOffset JoinedAt { get; set; }
        public DateTimeOffset? LeftAt { get; set; }
        public DateTimeOffset? LastReadAt { get; set; }
    }
}
