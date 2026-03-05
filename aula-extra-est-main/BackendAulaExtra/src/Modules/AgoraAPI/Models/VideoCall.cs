using System;

namespace ConfidantPostgreSQL.Modules.AgoraAPI.Models
{
    public class VideoCall
    {
        public Guid Id { get; set; }
        public string ChannelName { get; set; } = string.Empty;
        public string? CallName { get; set; }
        public string CallType { get; set; } = "video";
        public Guid? GroupRoomId { get; set; }
        public Guid? InitiatedByUserId { get; set; }
        public string Status { get; set; } = "active";
        public DateTimeOffset StartedAt { get; set; }
        public DateTimeOffset? EndedAt { get; set; }
        public int? DurationSeconds { get; set; }
        public int MaxParticipants { get; set; }
        public string? RecordingUrl { get; set; }
        public bool IsRecorded { get; set; }
        public string? Metadata { get; set; }
    }
}
