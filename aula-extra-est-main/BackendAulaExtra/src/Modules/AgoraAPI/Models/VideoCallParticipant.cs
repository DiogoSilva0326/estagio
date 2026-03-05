using System;

namespace ConfidantPostgreSQL.Modules.AgoraAPI.Models
{
    public class VideoCallParticipant
    {
        public Guid Id { get; set; }
        public Guid CallId { get; set; }
        public Guid UserId { get; set; }
        public string Role { get; set; } = "participant";
        public DateTimeOffset JoinedAt { get; set; }
        public DateTimeOffset? LeftAt { get; set; }
        public int? DurationSeconds { get; set; }
        public string? AvgVideoQuality { get; set; }
        public string? AvgAudioQuality { get; set; }
        public bool HadVideo { get; set; }
        public bool HadAudio { get; set; }
        public bool HadScreenShare { get; set; }
        public string? DeviceType { get; set; }
        public string? Metadata { get; set; }
    }
}
