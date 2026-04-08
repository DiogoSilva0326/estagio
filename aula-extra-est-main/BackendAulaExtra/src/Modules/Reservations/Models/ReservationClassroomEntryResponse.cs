using System;

namespace ConfidantPostgreSQL.Modules.Reservations.Models
{
    public sealed class ReservationClassroomEntryResponse
    {
        public Guid ReservationId { get; set; }
        public Guid LessonId { get; set; }
        public string ChannelName { get; set; } = string.Empty;
        public string LessonTitle { get; set; } = string.Empty;
        public string ProfessorUsername { get; set; } = string.Empty;
        public string ProfessorDisplayName { get; set; } = string.Empty;
        public string StudentUsername { get; set; } = string.Empty;
        public string StudentDisplayName { get; set; } = string.Empty;
        public bool IsHost { get; set; }
        public int AgoraUid { get; set; }
        public string AgoraAppId { get; set; } = string.Empty;
        public string RtcToken { get; set; } = string.Empty;
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public ReservationClassroomScreenShareResponse? ScreenShare { get; set; }
        public ReservationClassroomWhiteboardResponse Whiteboard { get; set; } = new();
    }

    public sealed class ReservationClassroomScreenShareResponse
    {
        public int Uid { get; set; }
        public string Token { get; set; } = string.Empty;
    }

    public sealed class ReservationClassroomWhiteboardResponse
    {
        public string AppIdentifier { get; set; } = string.Empty;
        public string Region { get; set; } = "us-sv";
        public string Uuid { get; set; } = string.Empty;
        public string RoomToken { get; set; } = string.Empty;
    }
}