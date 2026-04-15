namespace ConfidantPostgreSQL.Modules.Complaints.Models
{
    public class CreateRelatedComplaintRequest
    {
        public string? TargetUserId { get; set; }
        public string? RelationshipType { get; set; }
        public string? ComplaintType { get; set; }
        public string? Subject { get; set; }
        public string? Message { get; set; }
    }
}