namespace ConfidantPostgreSQL.Integrations.AgoraLessons
{
    public sealed class AgoraLessonOptions
    {
        public string BaseUrl { get; set; } = string.Empty;
        public string AgoraAppId { get; set; } = string.Empty;
        public string WhiteboardAppIdentifier { get; set; } = string.Empty;
        public string WhiteboardRegion { get; set; } = "us-sv";

        public bool IsConfigured => !string.IsNullOrWhiteSpace(BaseUrl);
    }
}