namespace ConfidantPostgreSQL.Modules.Complaints.Models;

public class ComplaintResolution2{
    public Guid IdComplaintResolution {get; set;}
    public Guid ComplaintId {get; set;}
    public Guid AdminUserId {get; set;}
    public string? ResolutionStatus { get; set; }
    public string? ResolutionNotes { get; set; }
    public DateTime? CreatedAt {get; set;}
    public DateTime? ResolvedAt {get; set;}
    public DateTime? UpdatedAt { get; set; }
}