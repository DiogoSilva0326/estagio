using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Npgsql;
using ConfidantPostgreSQL.Modules.UserProfile.Models;

namespace ConfidantPostgreSQL.Modules.UserProfile.Repository;

public interface IUserProfileRepository
{
    Task<Models.UserProfile?> GetByUserIdAsync(Guid userId);
    Task<Models.UserProfile?> GetByVerificationTokenAsync(string token);
    Task<Models.UserProfile?> GetByResetTokenAsync(string token);
    Task<List<Models.UserProfile>> GetAllAsync();
    Task<Guid> InsertAsync(InsertUserProfileRequest request);
    Task<int> UpdateAsync(UpdateUserProfileRequest request);
}

public class UserProfileRepository : IUserProfileRepository
{
    private readonly string _connectionString;
    private readonly ILogger<UserProfileRepository>? _logger;

    public UserProfileRepository(string connectionString, ILogger<UserProfileRepository>? logger = null)
    {
        _connectionString = connectionString;
        _logger = logger;
    }

    public async Task<Models.UserProfile?> GetByUserIdAsync(Guid userId)
    {
        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_userprofiles_get_by_id(@p_id);";
            cmd.Parameters.AddWithValue("p_id", userId);

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new Models.UserProfile
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                    TotalSpent = reader.IsDBNull(reader.GetOrdinal("total_spent")) 
                        ? 0 
                        : reader.GetDecimal(reader.GetOrdinal("total_spent")),
                    ResetPasswordToken = reader.IsDBNull(reader.GetOrdinal("reset_password_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("reset_password_token")),
                    ResetPasswordTokenExpiry = reader.IsDBNull(reader.GetOrdinal("reset_password_token_expiry")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("reset_password_token_expiry")),
                    EmailVerificationToken = reader.IsDBNull(reader.GetOrdinal("email_verification_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("email_verification_token")),
                    EmailVerifiedAt = reader.IsDBNull(reader.GetOrdinal("email_verified_at")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("email_verified_at")),
                    PreferedLanguage = reader.IsDBNull(reader.GetOrdinal("prefered_language")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("prefered_language")),
                    Status = reader.IsDBNull(reader.GetOrdinal("status")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("status")),
                    Phone = reader.IsDBNull(reader.GetOrdinal("phone")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("phone")),
                    ProfileImageUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_url")),
                    ProfileImageThumbnailUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_thumbnail_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_thumbnail_url")),
                    ProfileImageCloudflareId = reader.IsDBNull(reader.GetOrdinal("profile_image_cloudflare_id"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_cloudflare_id")),
                    ProfileImageProvider = reader.IsDBNull(reader.GetOrdinal("profile_image_provider"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_provider")),
                    ProfileImageSource = reader.IsDBNull(reader.GetOrdinal("profile_image_source"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_source")),
                    CreationDate = reader.GetDateTime(reader.GetOrdinal("creation_date")),
                    LastUpdate = reader.GetDateTime(reader.GetOrdinal("last_update")),
                    Inactive = reader.GetBoolean(reader.GetOrdinal("inactive"))
                };
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "GetByUserIdAsync failed for userId={UserId}", userId);
            throw;
        }
    }

    public async Task<Models.UserProfile?> GetByVerificationTokenAsync(string token)
    {
        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_userprofiles_get_by_verification_token(@p_token);";
            cmd.Parameters.AddWithValue("p_token", token);

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new Models.UserProfile
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                    TotalSpent = reader.IsDBNull(reader.GetOrdinal("total_spent")) 
                        ? 0 
                        : reader.GetDecimal(reader.GetOrdinal("total_spent")),
                    ResetPasswordToken = reader.IsDBNull(reader.GetOrdinal("reset_password_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("reset_password_token")),
                    ResetPasswordTokenExpiry = reader.IsDBNull(reader.GetOrdinal("reset_password_token_expiry")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("reset_password_token_expiry")),
                    EmailVerificationToken = reader.IsDBNull(reader.GetOrdinal("email_verification_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("email_verification_token")),
                    EmailVerifiedAt = reader.IsDBNull(reader.GetOrdinal("email_verified_at")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("email_verified_at")),
                    PreferedLanguage = reader.IsDBNull(reader.GetOrdinal("prefered_language")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("prefered_language")),
                    Status = reader.IsDBNull(reader.GetOrdinal("status")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("status")),
                    Phone = reader.IsDBNull(reader.GetOrdinal("phone")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("phone")),
                    ProfileImageUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_url")),
                    ProfileImageThumbnailUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_thumbnail_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_thumbnail_url")),
                    ProfileImageCloudflareId = reader.IsDBNull(reader.GetOrdinal("profile_image_cloudflare_id"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_cloudflare_id")),
                    ProfileImageProvider = reader.IsDBNull(reader.GetOrdinal("profile_image_provider"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_provider")),
                    ProfileImageSource = reader.IsDBNull(reader.GetOrdinal("profile_image_source"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_source")),
                    CreationDate = reader.GetDateTime(reader.GetOrdinal("creation_date")),
                    LastUpdate = reader.GetDateTime(reader.GetOrdinal("last_update")),
                    Inactive = reader.GetBoolean(reader.GetOrdinal("inactive"))
                };
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "GetByVerificationTokenAsync failed for token: {Token}", token);
            throw;
        }
    }

    public async Task<Models.UserProfile?> GetByResetTokenAsync(string token)
    {
        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_userprofiles_get_by_reset_token(@p_token);";
            cmd.Parameters.AddWithValue("p_token", token);

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new Models.UserProfile
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                    TotalSpent = reader.IsDBNull(reader.GetOrdinal("total_spent")) 
                        ? 0 
                        : reader.GetDecimal(reader.GetOrdinal("total_spent")),
                    ResetPasswordToken = reader.IsDBNull(reader.GetOrdinal("reset_password_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("reset_password_token")),
                    ResetPasswordTokenExpiry = reader.IsDBNull(reader.GetOrdinal("reset_password_token_expiry")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("reset_password_token_expiry")),
                    EmailVerificationToken = reader.IsDBNull(reader.GetOrdinal("email_verification_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("email_verification_token")),
                    EmailVerifiedAt = reader.IsDBNull(reader.GetOrdinal("email_verified_at")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("email_verified_at")),
                    PreferedLanguage = reader.IsDBNull(reader.GetOrdinal("prefered_language")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("prefered_language")),
                    Status = reader.IsDBNull(reader.GetOrdinal("status")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("status")),
                    Phone = reader.IsDBNull(reader.GetOrdinal("phone")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("phone")),
                    ProfileImageUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_url")),
                    ProfileImageThumbnailUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_thumbnail_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_thumbnail_url")),
                    ProfileImageCloudflareId = reader.IsDBNull(reader.GetOrdinal("profile_image_cloudflare_id"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_cloudflare_id")),
                    ProfileImageProvider = reader.IsDBNull(reader.GetOrdinal("profile_image_provider"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_provider")),
                    ProfileImageSource = reader.IsDBNull(reader.GetOrdinal("profile_image_source"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_source")),
                    CreationDate = reader.GetDateTime(reader.GetOrdinal("creation_date")),
                    LastUpdate = reader.GetDateTime(reader.GetOrdinal("last_update")),
                    Inactive = reader.GetBoolean(reader.GetOrdinal("inactive"))
                };
            }

            return null;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "GetByResetTokenAsync failed for token: {Token}", token);
            throw;
        }
    }

    public async Task<List<Models.UserProfile>> GetAllAsync()
    {
        var profiles = new List<Models.UserProfile>();
        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_userprofiles_select_all01();";

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                profiles.Add(new Models.UserProfile
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                    TotalSpent = reader.IsDBNull(reader.GetOrdinal("total_spent")) 
                        ? 0 
                        : reader.GetDecimal(reader.GetOrdinal("total_spent")),
                    ResetPasswordToken = reader.IsDBNull(reader.GetOrdinal("reset_password_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("reset_password_token")),
                    ResetPasswordTokenExpiry = reader.IsDBNull(reader.GetOrdinal("reset_password_token_expiry")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("reset_password_token_expiry")),
                    EmailVerificationToken = reader.IsDBNull(reader.GetOrdinal("email_verification_token")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("email_verification_token")),
                    EmailVerifiedAt = reader.IsDBNull(reader.GetOrdinal("email_verified_at")) 
                        ? null 
                        : reader.GetDateTime(reader.GetOrdinal("email_verified_at")),
                    PreferedLanguage = reader.IsDBNull(reader.GetOrdinal("prefered_language")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("prefered_language")),
                    Status = reader.IsDBNull(reader.GetOrdinal("status")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("status")),
                    Phone = reader.IsDBNull(reader.GetOrdinal("phone")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("phone")),
                    ProfileImageUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_url")),
                    ProfileImageThumbnailUrl = reader.IsDBNull(reader.GetOrdinal("profile_image_thumbnail_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_thumbnail_url")),
                    ProfileImageCloudflareId = reader.IsDBNull(reader.GetOrdinal("profile_image_cloudflare_id"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_cloudflare_id")),
                    ProfileImageProvider = reader.IsDBNull(reader.GetOrdinal("profile_image_provider"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_provider")),
                    ProfileImageSource = reader.IsDBNull(reader.GetOrdinal("profile_image_source"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("profile_image_source")),
                    CreationDate = reader.GetDateTime(reader.GetOrdinal("creation_date")),
                    LastUpdate = reader.GetDateTime(reader.GetOrdinal("last_update")),
                    Inactive = reader.GetBoolean(reader.GetOrdinal("inactive"))
                });
            }

            return profiles;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "GetAllAsync failed");
            throw;
        }
    }

    public async Task<Guid> InsertAsync(InsertUserProfileRequest request)
    {
        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_userprofiles_insert(@p_user_id, @p_total_spent, @p_prefered_language, @p_status, @p_phone);";
            cmd.Parameters.AddWithValue("p_user_id", request.UserId);
            cmd.Parameters.AddWithValue("p_total_spent", (object?)request.TotalSpent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_prefered_language", (object?)request.PreferedLanguage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_status", (object?)request.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_phone", (object?)request.Phone ?? DBNull.Value);

            var result = await cmd.ExecuteScalarAsync();
            if (result == null || result == DBNull.Value) return Guid.Empty;
            return result is Guid guid ? guid : Guid.Parse(result.ToString()!);
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "InsertAsync failed for userId={UserId}", request.UserId);
            throw;
        }
    }

    public async Task<int> UpdateAsync(UpdateUserProfileRequest request)
    {
        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_userprofiles_update(
                @p_user_id, @p_total_spent, @p_reset_password_token, @p_reset_password_token_expiry,
                @p_email_verification_token, @p_email_verified_at, @p_prefered_language, @p_status, @p_phone,
                @p_profile_image_url, @p_profile_image_thumbnail_url, @p_profile_image_cloudflare_id,
                @p_profile_image_provider, @p_profile_image_source, @p_clear_profile_image
            );";
            cmd.Parameters.AddWithValue("p_user_id", request.UserId);
            cmd.Parameters.AddWithValue("p_total_spent", (object?)request.TotalSpent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_reset_password_token", (object?)request.ResetPasswordToken ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_reset_password_token_expiry", (object?)request.ResetPasswordTokenExpiry ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_email_verification_token", (object?)request.EmailVerificationToken ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_email_verified_at", (object?)request.EmailVerifiedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_prefered_language", (object?)request.PreferedLanguage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_status", (object?)request.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_phone", (object?)request.Phone ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_profile_image_url", (object?)request.ProfileImageUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_profile_image_thumbnail_url", (object?)request.ProfileImageThumbnailUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_profile_image_cloudflare_id", (object?)request.ProfileImageCloudflareId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_profile_image_provider", (object?)request.ProfileImageProvider ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_profile_image_source", (object?)request.ProfileImageSource ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_clear_profile_image", request.ClearProfileImage);

            var result = await cmd.ExecuteScalarAsync();
            return result is int rows ? rows : Convert.ToInt32(result);
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "UpdateAsync failed for userId={UserId}", request.UserId);
            throw;
        }
    }
}
