namespace ConfidantPostgreSQL.Integrations.Email
{
    public class EmailSenderDto
    {
        public string To { get; set; } = default!;
        public string? From { get; set; }
        public string Subject { get; set; } = default!;
        public string? TextBody { get; set; }
        public string? HtmlBody { get; set; }
        public bool TrackOpens { get; set; } = true;
        public string MessageStream { get; set; } = "outbound";
        public string? Tag { get; set; }
    }
}
