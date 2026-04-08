using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using System.Linq;
using System.Security.Cryptography;
using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Integrations.CloudflareImages;
using ConfidantPostgreSQL.Modules.Users.Models;
using ConfidantPostgreSQL.Modules.Users.DTOs;
using ConfidantPostgreSQL.Modules.Student.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using ConfidantPostgreSQL.Modules.Users.Repository;
using ConfidantPostgreSQL.Modules.UserProfile.Service;
using ConfidantPostgreSQL.Modules.UserProfile.Models;
using ConfidantPostgreSQL.Integrations.Email;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Users.Controller
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _service;
        private readonly IMyTutorsService _myTutors;
        private readonly IUserProfileService _userProfileService;
        private readonly IEmailTemplateService _emailService;
        private readonly IServiceProvider _services;
        private readonly IOptions<CloudflareImagesOptions> _cloudflareOptions;
        private readonly string _connStr;

        public UsersController(
            IUserService service, 
            IMyTutorsService myTutors,
            IUserProfileService userProfileService,
            IEmailTemplateService emailService,
            IServiceProvider services,
            IOptions<CloudflareImagesOptions> cloudflareOptions)
        {
            _service = service;
            _myTutors = myTutors;
            _userProfileService = userProfileService;
            _emailService = emailService;
            _services = services;
            _cloudflareOptions = cloudflareOptions;
            var host = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
            var port = Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
            var user = Environment.GetEnvironmentVariable("DB_USER") ?? "sa";
            var pass = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "";
            var db = Environment.GetEnvironmentVariable("DB_NAME") ?? "ConfidantsDB";
            _connStr = $"Host={host};Port={port};Username={user};Password={pass};Database={db}";
        }

        // GET /api/Users/me/tutors
        // Returns the authenticated student's tutors with last lesson + optional rating.
        [AuthorizeJwt]
        [HttpGet("me/tutors")]
        public async Task<IActionResult> GetMyTutors([FromQuery] Guid? areaId = null)
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            var items = await _myTutors.GetMyTutorsAsync(userId, areaId);
            return Ok(items);
        }

        public class SetUserRoleDto
        {
            public int RoleId { get; set; }
        }

        public class SetUserRolesRequest
        {
            public Guid UserId { get; set; }
            public List<SetUserRoleDto> UserRoles { get; set; } = new();
        }

        public class UpdateUserStatusRequest
        {
            public bool Inactive { get; set; }
        }

        public class UpdateMyProfileRequest
        {
            public string? Username { get; set; }
            public string? DisplayName { get; set; }
            public string? EducationLevel { get; set; }
            public string? Biography { get; set; }
            public string? MobileNumber { get; set; }
            public string? PhoneNumber { get; set; }
            public string? Website { get; set; }
        }

        public class SetProfileImageFromUrlRequest
        {
            public string? ImageUrl { get; set; }
        }

        public class ProfileImageResponse
        {
            public string? ProfileImageUrl { get; set; }
            public string? ProfileImageThumbnailUrl { get; set; }
            public string? ProfileImageCloudflareId { get; set; }
            public string? ProfileImageProvider { get; set; }
            public string? ProfileImageSource { get; set; }
        }

        public class MarkNotificationReadRequest
        {
            public bool IsRead { get; set; } = true;
        }

        // Compat update payload (similar to legacy API body for PUT /api/Users)
        public class LegacyUserUpdateRequest
        {
            public Guid Id { get; set; }
            public string? FirstName { get; set; }
            public string? LastName { get; set; }
            public string? Email { get; set; }
            public string? BirthDate { get; set; }
            public bool? Inactive { get; set; }
        }

        private bool TryGetAuthenticatedUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext?.Items == null) return false;
            if (!HttpContext.Items.TryGetValue("UserId", out var raw) || raw == null) return false;
            if (raw is Guid g)
            {
                userId = g;
                return userId != Guid.Empty;
            }

            return Guid.TryParse(raw.ToString(), out userId) && userId != Guid.Empty;
        }

        private async Task<bool> CurrentUserIsAdminAsync(Guid userId)
        {
            var auth = await _service.IssueTokenAsync(userId);
            if (auth?.Roles == null) return false;
            return auth.Roles.Any(r => string.Equals(r?.Trim(), "admin", StringComparison.OrdinalIgnoreCase));
        }

        // GET /api/Users/me
        [AuthorizeJwt]
        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            var response = await BuildMeResponseAsync(userId);
            return response == null ? NotFound() : Ok(response);
        }

        [AuthorizeJwt]
        [HttpGet("me/notifications")]
        public async Task<IActionResult> GetMyNotifications()
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            var items = await _service.GetNotificationsByUserIdAsync(userId);
            return Ok(items);
        }

        [AuthorizeJwt]
        [HttpPut("me/notifications/read-all")]
        public async Task<IActionResult> MarkAllMyNotificationsAsRead()
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            var rows = await _service.MarkAllNotificationsAsReadAsync(userId);
            return Ok(new { updated = rows });
        }

        [AuthorizeJwt]
        [HttpPut("me/notifications/{notificationId:guid}/read")]
        public async Task<IActionResult> MarkMyNotificationAsRead(Guid notificationId, [FromBody] MarkNotificationReadRequest? request = null)
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            if (request?.IsRead == false)
                return BadRequest(new { message = "Only mark-as-read is supported." });

            var updated = await _service.MarkNotificationAsReadAsync(userId, notificationId);
            if (!updated) return NotFound();
            return NoContent();
        }

        // PUT /api/Users/me
        // Updates a subset of profile fields used by the Flutter app.
        [AuthorizeJwt]
        [HttpPut("me")]
        public async Task<IActionResult> UpdateMe([FromBody] UpdateMyProfileRequest request)
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            var normalizedUsername = request?.Username?.Trim();
            if (request?.Username != null && string.IsNullOrWhiteSpace(normalizedUsername))
            {
                return BadRequest(new { message = "Username is required" });
            }

            if (!string.IsNullOrWhiteSpace(normalizedUsername))
            {
                var existing = await _service.GetByUsernameAsync(normalizedUsername);
                if (existing != null && existing.Id.HasValue && existing.Id.Value != userId)
                {
                    return Conflict(new { message = "Username already exists" });
                }
            }

            await using var conn = new NpgsqlConnection(_connStr);
            await conn.OpenAsync();

            try
            {
                await using var cmd = conn.CreateCommand();
                cmd.CommandText = @"
                    UPDATE public.users
                    SET
                        username = COALESCE(@p_username, username),
                        display_name = @p_display_name,
                        education_level = @p_education_level,
                        biography = @p_biography,
                        mobile_number = @p_mobile_number,
                        phone_number = @p_phone_number,
                        website = @p_website,
                        last_update = now(),
                        last_user_id = @p_last_user_id
                    WHERE id_user = @p_id;";

                cmd.Parameters.AddWithValue("p_id", userId);
                cmd.Parameters.AddWithValue("p_username", string.IsNullOrWhiteSpace(normalizedUsername) ? DBNull.Value : normalizedUsername);
                cmd.Parameters.AddWithValue("p_display_name", (object?)request?.DisplayName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("p_education_level", (object?)request?.EducationLevel ?? DBNull.Value);
                cmd.Parameters.AddWithValue("p_biography", (object?)request?.Biography ?? DBNull.Value);
                cmd.Parameters.AddWithValue("p_mobile_number", (object?)request?.MobileNumber ?? DBNull.Value);
                cmd.Parameters.AddWithValue("p_phone_number", (object?)request?.PhoneNumber ?? DBNull.Value);
                cmd.Parameters.AddWithValue("p_website", (object?)request?.Website ?? DBNull.Value);
                cmd.Parameters.AddWithValue("p_last_user_id", userId);

                var rows = await cmd.ExecuteNonQueryAsync();
                if (rows == 0) return NotFound();

                var response = await BuildMeResponseAsync(userId);
                return response == null ? NotFound() : Ok(response);
            }
            catch (PostgresException ex) when (
                ex.SqlState == "23505" &&
                (string.Equals(ex.ConstraintName, "idx_users_username", StringComparison.OrdinalIgnoreCase) ||
                 string.Equals(ex.ConstraintName, "users_username_key", StringComparison.OrdinalIgnoreCase) ||
                 (ex.MessageText?.Contains("username", StringComparison.OrdinalIgnoreCase) ?? false)))
            {
                return Conflict(new { message = "Username already exists" });
            }
        }

        [AuthorizeJwt]
        [HttpPost("me/profile-image/upload")]
        [RequestSizeLimit(8 * 1024 * 1024)]
        public async Task<IActionResult> UploadMyProfileImage([FromForm] IFormFile? file, CancellationToken cancellationToken)
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            if (!_cloudflareOptions.Value.IsConfigured)
            {
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new { message = "Cloudflare Images não está configurado." });
            }

            if (file == null || file.Length <= 0)
            {
                return BadRequest(new { message = "Imagem é obrigatória." });
            }

            if (!IsSupportedImageUpload(file))
            {
                return BadRequest(new { message = "Apenas ficheiros de imagem são suportados." });
            }

            await using var stream = file.OpenReadStream();
            return await SaveProfileImageAsync(
                userId,
                source: "upload",
                uploader: (client, ct) => client.UploadFileAsync(
                    stream,
                    string.IsNullOrWhiteSpace(file.FileName) ? $"profile-{userId:N}.bin" : file.FileName,
                    id: null,
                    metadata: new Dictionary<string, string>
                    {
                        ["userId"] = userId.ToString(),
                        ["source"] = "upload"
                    },
                    ct),
                cancellationToken);
        }

        private static bool IsSupportedImageUpload(IFormFile file)
        {
            var contentType = file.ContentType?.Trim();
            if (!string.IsNullOrWhiteSpace(contentType) &&
                contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }

            var extension = Path.GetExtension(file.FileName)?.Trim().ToLowerInvariant();
            return extension is ".png" or ".jpg" or ".jpeg" or ".gif" or ".webp" or ".svg" or ".heic";
        }

        [AuthorizeJwt]
        [HttpPost("me/profile-image/from-url")]
        public async Task<IActionResult> SetMyProfileImageFromUrl([FromBody] SetProfileImageFromUrlRequest request, CancellationToken cancellationToken)
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            if (!_cloudflareOptions.Value.IsConfigured)
            {
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new { message = "Cloudflare Images não está configurado." });
            }

            var imageUrl = request?.ImageUrl?.Trim();
            if (string.IsNullOrWhiteSpace(imageUrl))
            {
                return BadRequest(new { message = "URL da imagem é obrigatória." });
            }

            if (!Uri.TryCreate(imageUrl, UriKind.Absolute, out var uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                return BadRequest(new { message = "URL de imagem inválida." });
            }

            return await SaveProfileImageAsync(
                userId,
                source: "external_url",
                uploader: (client, ct) => client.UploadViaUrlAsync(
                    imageUrl,
                    id: null,
                    metadata: new Dictionary<string, string>
                    {
                        ["userId"] = userId.ToString(),
                        ["source"] = "external_url"
                    },
                    ct),
                cancellationToken);
        }

        [AuthorizeJwt]
        [HttpDelete("me/profile-image")]
        public async Task<IActionResult> DeleteMyProfileImage(CancellationToken cancellationToken)
        {
            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            var profile = await _userProfileService.GetOrCreateAsync(userId);
            await DeleteCloudflareImageIfNeededAsync(profile, cancellationToken);

            await _userProfileService.UpdateAsync(new UpdateUserProfileRequest
            {
                UserId = userId,
                ClearProfileImage = true,
            });

            return NoContent();
        }

        private async Task<object?> BuildMeResponseAsync(Guid userId)
        {
            var user = await _service.GetByIdAsync(userId);
            if (user == null) return null;

            var profile = await _userProfileService.GetOrCreateAsync(userId);

            return new
            {
                id = user.Id,
                email = user.Email,
                username = user.Username,
                displayName = user.DisplayName,
                educationLevel = user.EducationLevel,
                mobileNumber = user.MobileNumber,
                phoneNumber = user.PhoneNumber,
                nif = user.Nif,
                website = user.Website,
                biography = user.Biography,
                creationDate = user.CreationDate,
                profileImageUrl = profile.ProfileImageUrl,
                profileImageThumbnailUrl = profile.ProfileImageThumbnailUrl,
                profileImageCloudflareId = profile.ProfileImageCloudflareId,
                profileImageProvider = profile.ProfileImageProvider,
                profileImageSource = profile.ProfileImageSource,
            };
        }

        private async Task<IActionResult> SaveProfileImageAsync(
            Guid userId,
            string source,
            Func<ICloudflareImagesClient, CancellationToken, Task<CloudflareImagesClient.UploadResponse>> uploader,
            CancellationToken cancellationToken)
        {
            var profile = await _userProfileService.GetOrCreateAsync(userId);
            var previousCloudflareId = profile.ProfileImageCloudflareId;
            var previousProvider = profile.ProfileImageProvider;

            var client = _services.GetRequiredService<ICloudflareImagesClient>();
            CloudflareImagesClient.UploadResponse upload;
            CloudflareImagesClient.ImageDetails details;

            try
            {
                upload = await uploader(client, cancellationToken);
                details = await client.GetAsync(upload.Id, cancellationToken);
            }
            catch (CloudflareImagesApiException ex)
            {
                var statusCode = ex.StatusCode switch
                {
                    HttpStatusCode.BadRequest => StatusCodes.Status400BadRequest,
                    HttpStatusCode.Unauthorized => StatusCodes.Status502BadGateway,
                    HttpStatusCode.Forbidden => StatusCodes.Status502BadGateway,
                    HttpStatusCode.UnprocessableEntity => StatusCodes.Status422UnprocessableEntity,
                    _ => StatusCodes.Status502BadGateway,
                };

                return StatusCode(statusCode, new
                {
                    message = "Falha ao guardar imagem no Cloudflare.",
                    providerStatus = (int)ex.StatusCode,
                    providerError = ex.ResponseBody,
                });
            }

            var imageUrl = ResolveCloudflareImageUrl(upload.Id, details.Variants);

            await _userProfileService.UpdateAsync(new UpdateUserProfileRequest
            {
                UserId = userId,
                ProfileImageUrl = imageUrl,
                ProfileImageThumbnailUrl = imageUrl,
                ProfileImageCloudflareId = upload.Id,
                ProfileImageProvider = "cloudflare",
                ProfileImageSource = source,
            });

            if (string.Equals(previousProvider, "cloudflare", StringComparison.OrdinalIgnoreCase) &&
                !string.IsNullOrWhiteSpace(previousCloudflareId) &&
                !string.Equals(previousCloudflareId, upload.Id, StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    await client.DeleteAsync(previousCloudflareId, cancellationToken);
                }
                catch
                {
                }
            }

            return Ok(new ProfileImageResponse
            {
                ProfileImageUrl = imageUrl,
                ProfileImageThumbnailUrl = imageUrl,
                ProfileImageCloudflareId = upload.Id,
                ProfileImageProvider = "cloudflare",
                ProfileImageSource = source,
            });
        }

        private string ResolveCloudflareImageUrl(string imageId, List<string>? variants)
        {
            var variantUrl = variants?.FirstOrDefault(v => !string.IsNullOrWhiteSpace(v));
            if (!string.IsNullOrWhiteSpace(variantUrl))
            {
                return variantUrl!;
            }

            var deliveryBase = _cloudflareOptions.Value.DeliveryBase?.Trim();
            var variant = string.IsNullOrWhiteSpace(_cloudflareOptions.Value.DefaultVariant)
                ? "public"
                : _cloudflareOptions.Value.DefaultVariant.Trim();

            if (!string.IsNullOrWhiteSpace(deliveryBase))
            {
                return $"{deliveryBase.TrimEnd('/')}/{imageId}/{variant}";
            }

            return imageId;
        }

        private async Task DeleteCloudflareImageIfNeededAsync(Modules.UserProfile.Models.UserProfile? profile, CancellationToken cancellationToken)
        {
            if (profile == null ||
                !string.Equals(profile.ProfileImageProvider, "cloudflare", StringComparison.OrdinalIgnoreCase) ||
                string.IsNullOrWhiteSpace(profile.ProfileImageCloudflareId) ||
                !_cloudflareOptions.Value.IsConfigured)
            {
                return;
            }

            try
            {
                var client = _services.GetRequiredService<ICloudflareImagesClient>();
                await client.DeleteAsync(profile.ProfileImageCloudflareId, cancellationToken);
            }
            catch
            {
            }
        }

        // GET /api/Users
        // Minimal compatibility endpoint for legacy admin UI.
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromHeader(Name = "pageNumber")] int pageNumber = 1,
            [FromHeader(Name = "pageSize")] int pageSize = 50)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 1;
            if (pageSize > 500) pageSize = 500;

            var users = await _service.GetAllAsync();
            var page = users
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize);

            return Ok(page);
        }

        [HttpGet("{id:guid}")]
        public async Task<IActionResult> Get(Guid id)
        {
            var user = await _service.GetByIdAsync(id);
            if (user == null) return NotFound();
            return Ok(user);
        }

        [HttpGet("by-email")]
        public async Task<IActionResult> GetByEmail([FromQuery] string email)
        {
            // assume repository/service exposes GetByEmailAsync
            var user = await _service.GetByEmailAsync(email);
            if (user == null) return NotFound();
            return Ok(user);
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] User user)
        {
            var id = await _service.InsertAsync(user);
            user.Id = id;
            return CreatedAtAction(nameof(Get), new { id = id }, user);
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(
            [FromBody] RegisterModel model,
            [FromHeader(Name = "culture")] string? culture = null)
        {
            if (model == null || string.IsNullOrEmpty(model.Email) || string.IsNullOrEmpty(model.Password))
                return BadRequest("Email and password required");

            Guid? storeIdGuid = null;
            if (!string.IsNullOrWhiteSpace(model.StoreId) && Guid.TryParse(model.StoreId, out var parsedStoreId))
                storeIdGuid = parsedStoreId;

            var user = new User
            {
                Email = model.Email,
                FirstName = model.FirstName ?? "",
                LastName = model.LastName ?? "",
                BirthDate = model.BirthDate,
                StoreId = storeIdGuid,
                Nif = model.Nif,
                MobileNumber = model.MobileNumber,
                PhoneNumber = model.PhoneNumber,
                CompanyName = model.CompanyName,
                Website = model.Website,
            };
            Guid id;
            try
            {
                id = await _service.RegisterAsync(user, model.Password);
                user.Id = id;
                
                // Auto-create user profile with email verification
                try
                {
                    // Generate email verification token
                    var verificationToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));
                    
                    var profileRequest = new InsertUserProfileRequest
                    {
                        UserId = id,
                        TotalSpent = 0,
                        PreferedLanguage = culture ?? "pt-PT",
                        Status = "active"
                    };
                    var profileId = await _userProfileService.InsertAsync(profileRequest);
                    
                    // Update profile with verification token
                    var updateRequest = new UpdateUserProfileRequest
                    {
                        UserId = id,
                        EmailVerificationToken = verificationToken
                    };
                    await _userProfileService.UpdateAsync(updateRequest);
                    
                    // Send verification email
                    try
                    {
                        await _emailService.SendEmailVerificationAsync(
                            model.Email, 
                            verificationToken, 
                            culture ?? "pt-PT"
                        );
                    }
                    catch (Exception emailEx)
                    {
                        Console.WriteLine($"Failed to send verification email for user {id}: {emailEx.Message}");
                    }
                }
                catch (Exception ex)
                {
                    // Log but don't fail registration if profile creation fails
                    Console.WriteLine($"Failed to create user profile for user {id}: {ex.Message}");
                }
            }
            catch (PostgresException ex) when (ex.SqlState == "23505" && (ex.ConstraintName == "users_email_key" || ex.Message?.Contains("email") == true))
            {
                return Conflict(new { message = "Email already exists" });
            }
            catch (PostgresException ex) when (ex.SqlState == "23505" && ex.ConstraintName == "users_pkey")
            {
                // Usually indicates the users.id identity/sequence is out of sync after a restore.
                Console.WriteLine($"Register failed (users_pkey collision). Likely identity sequence out of sync. Detail: {ex.Message}");
                return StatusCode(500, new { message = "Registration failed due to a server configuration issue. Please try again." });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Register failed: {ex.Message}");
                return StatusCode(500, new { message = "Registration failed. Please try again." });
            }
            
            return CreatedAtAction(nameof(Get), new { id = id }, user);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.Email) || string.IsNullOrEmpty(model.Password))
                return BadRequest("Email and password required");

            var auth = await _service.AuthenticateAsync(model.Email, model.Password);
            if (auth == null) return Unauthorized();
            return Ok(auth);
        }

        // Full update by id (new API)
        [HttpPut("{id:guid}")]
        public async Task<IActionResult> Put(Guid id, [FromBody] User user)
        {
            if (id != user.Id) return BadRequest();
            var res = await _service.UpdateAsync(user);
            if (res == 0) return NotFound();
            return NoContent();
        }

        // Compat: accept legacy-style payload without id in route
        // PUT /api/Users
        // Body example:
        // { "id": 1007, "firstName": "estt", "lastName": "tess", "email": "x@y.com", "birthDate": "2026-01-07T14:37:21", "inactive": true, "lastUpdate": "...", "updating": true }
        [HttpPut]
        [AuthorizeJwt]
        public async Task<IActionResult> PutLegacy([FromBody] LegacyUserUpdateRequest request, [FromHeader] string? token = null, [FromHeader] string? culture = null)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (request == null || request.Id == Guid.Empty)
            {
                return BadRequest("Valid id is required");
            }

            var user = await _service.GetByIdAsync(request.Id);
            if (user == null) return NotFound();

            if (!string.IsNullOrEmpty(request.FirstName)) user.FirstName = request.FirstName;
            if (!string.IsNullOrEmpty(request.LastName)) user.LastName = request.LastName;
            if (!string.IsNullOrEmpty(request.Email)) user.Email = request.Email;
            if (!string.IsNullOrEmpty(request.BirthDate)) user.BirthDate = request.BirthDate;
            if (request.Inactive.HasValue) user.Inactive = request.Inactive.Value;

            var res = await _service.UpdateAsync(user);
            if (res == 0) return NotFound();

            return Ok(user);
        }

        // Compatibilidade com frontend antigo:
        // PUT /api/Users/Roles
        // Body: { "userId": 4, "userRoles": [ { "roleId": 1 }, { "roleId": 2 } ] }
        [HttpPut("Roles")]
        [AuthorizeJwt]
        public async Task<IActionResult> Set([FromBody] SetUserRolesRequest request, [FromHeader] string? token = null, [FromHeader] string? culture = null)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (!TryGetAuthenticatedUserId(out var actorUserId))
                return Unauthorized();
            if (!await CurrentUserIsAdminAsync(actorUserId))
                return Forbid();

            if (request == null || request.UserRoles == null || request.UserRoles.Count == 0)
            {
                return BadRequest("userId and at least one role are required");
            }

            var userId = request.UserId;

            try
            {
                await using var conn = new NpgsqlConnection(_connStr);
                await conn.OpenAsync();

                // Delete existing roles for user
                await using (var delCmd = new NpgsqlCommand(
                    "DELETE FROM user_role WHERE user_id = @userId", conn))
                {
                    delCmd.Parameters.AddWithValue("userId", userId);
                    await delCmd.ExecuteNonQueryAsync();
                }

                // Insert new roles
                foreach (var role in request.UserRoles)
                {
                    await using var insCmd = new NpgsqlCommand(
                        "INSERT INTO user_role (role_id, user_id) VALUES (@roleId, @userId)", conn);

                    insCmd.Parameters.AddWithValue("roleId", role.RoleId);
                    insCmd.Parameters.AddWithValue("userId", userId);
                    await insCmd.ExecuteNonQueryAsync();
                }

                return Ok(new { userId, roles = request.UserRoles });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }


        // Ativar/desativar utilizador
        // PUT /api/Users/{id}/Inactive
        // Body: { "inactive": true }
        [HttpPut("{id:guid}/Inactive")]
        [AuthorizeJwt]
        public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateUserStatusRequest request, [FromHeader] string? token = null, [FromHeader] string? culture = null)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (request == null)
            {
                return BadRequest("Inactive flag is required");
            }

            var updated = await _service.SetInactiveAsync(id, request.Inactive);
            if (!updated) return NotFound();

            return Ok(new { userId = id, inactive = request.Inactive });
        }

        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            var res = await _service.DeleteAsync(id);
            if (res == 0) return NotFound();
            return NoContent();
        }
    }
}
