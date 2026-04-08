namespace ConfidantPostgreSQL.Modules.UserProfile.Models;

public class UserProfile
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public decimal TotalSpent { get; set; }
    public string? ResetPasswordToken { get; set; }
    public DateTime? ResetPasswordTokenExpiry { get; set; }
    public string? EmailVerificationToken { get; set; }
    public DateTime? EmailVerifiedAt { get; set; }
    public string? PreferedLanguage { get; set; }
    public string? Status { get; set; }
    public string? Phone { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string? ProfileImageThumbnailUrl { get; set; }
    public string? ProfileImageCloudflareId { get; set; }
    public string? ProfileImageProvider { get; set; }
    public string? ProfileImageSource { get; set; }
    public DateTime CreationDate { get; set; }
    public DateTime LastUpdate { get; set; }
    public bool Inactive { get; set; }
}

public class InsertUserProfileRequest
{
    public Guid UserId { get; set; }
    public decimal? TotalSpent { get; set; }
    public string? PreferedLanguage { get; set; }
    public string? Status { get; set; }
    public string? Phone { get; set; }
}

public class UpdateUserProfileRequest
{
    public Guid UserId { get; set; }
    public decimal? TotalSpent { get; set; }
    public string? ResetPasswordToken { get; set; }
    public DateTime? ResetPasswordTokenExpiry { get; set; }
    public string? EmailVerificationToken { get; set; }
    public DateTime? EmailVerifiedAt { get; set; }
    public string? PreferedLanguage { get; set; }
    public string? Status { get; set; }
    public string? Phone { get; set; }
    public string? ProfileImageUrl { get; set; }
    public string? ProfileImageThumbnailUrl { get; set; }
    public string? ProfileImageCloudflareId { get; set; }
    public string? ProfileImageProvider { get; set; }
    public string? ProfileImageSource { get; set; }
    public bool ClearProfileImage { get; set; }
}
