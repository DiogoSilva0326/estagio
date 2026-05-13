using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Users.Service;
using ConfidantPostgreSQL.Modules.UserProfile.Service;
using ConfidantPostgreSQL.Integrations.Email;
using Npgsql;
using System.Security.Cryptography;

namespace ConfidantPostgreSQL.Modules.Authentication.Controller
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthenticationController : ControllerBase
    {
        private readonly IUserService _users;
        private readonly IUserProfileService _userProfileService;
        private readonly IEmailTemplateService _emailService;

        public AuthenticationController(
            IUserService users, 
            IUserProfileService userProfileService,
            IEmailTemplateService emailService)
        {
            _users = users;
            _userProfileService = userProfileService;
            _emailService = emailService;
        }

        private static object BuildAuthResponse(ConfidantPostgreSQL.Modules.Users.DTOs.AuthResult auth, string message)
        {
            return new
            {
                user = auth.User,
                token = auth.Token,
                roles = auth.Roles,
                message
            };
        }

        private static bool HasRole(IEnumerable<string>? roles, string role)
        {
            if (roles == null) return false;
            return roles.Any(item => string.Equals(item?.Trim(), role, StringComparison.OrdinalIgnoreCase));
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

        // Compatibility endpoint for existing admin UI:
        // POST /api/Authentication/Login
        [AllowAnonymous]
        [HttpPost("Login")]
        public async Task<IActionResult> Login(
            [FromBody] AuthenticationLoginRequest request,
            [FromHeader(Name = "culture")] string? culture = null)
        {
            RequestContext.ApplyCulture(culture);
            if (request == null || string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Email and password required");

            var auth = await _users.AuthenticateAsync(request.Email, request.Password);
            if (auth == null)
                return Unauthorized();

            return Ok(BuildAuthResponse(auth, "Login successful."));
        }

        [AllowAnonymous]
        [HttpPost("AdminLogin")]
        public async Task<IActionResult> AdminLogin(
            [FromBody] AuthenticationLoginRequest request,
            [FromHeader(Name = "culture")] string? culture = null)
        {
            RequestContext.ApplyCulture(culture);
            if (request == null || string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Email and password required");

            var auth = await _users.AuthenticateAsync(request.Email, request.Password);
            if (auth == null)
                return Unauthorized();

            if (!HasRole(auth.Roles, "admin"))
            {
                return StatusCode(403, new { message = "Admin access required." });
            }

            return Ok(BuildAuthResponse(auth, "Admin login successful."));
        }

        // POST /api/Authentication/Register
        // New endpoint for the Flutter app: registers a user (password hashed) + assigns default role + returns JWT.
        [AllowAnonymous]
        [HttpPost("Register")]
        public async Task<IActionResult> Register(
            [FromBody] AuthenticationRegisterRequest request,
            [FromHeader(Name = "culture")] string? culture = null)
        {
            RequestContext.ApplyCulture(culture);
            if (request == null || string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                return BadRequest("Email and password required");

            var user = new ConfidantPostgreSQL.Modules.Users.Models.User
            {
                Email = request.Email,
                FirstName = request.FirstName ?? string.Empty,
                LastName = request.LastName ?? string.Empty,
                EducationLevel = request.EducationLevel,
                Username = request.Username,
                DisplayName = request.DisplayName,
                MobileNumber = request.MobileNumber,
                Nif = request.Nif,
                Inactive = false,
            };

            Guid userId;
            try
            {
                userId = await _users.RegisterAsync(user, request.Password);
                user.Id = userId;
            }
            catch (PostgresException ex) when (ex.SqlState == "23505" && (ex.ConstraintName == "users_email_key" || ex.Message?.Contains("email") == true))
            {
                return Conflict(new { message = "Email already exists" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Register failed: {ex.Message}");
                return StatusCode(500, new { message = "Registration failed. Please try again." });
            }

            // Optional: create profile rows for downstream procs (best-effort)
            try
            {
                await _userProfileService.GetOrCreateAsync(userId);
            }
            catch
            {
                // ignored (registration should still succeed)
            }

            var auth = await _users.AuthenticateAsync(request.Email, request.Password);
            if (auth == null)
            {
                return Ok(new { user, message = "Registered successfully." });
            }

            return Ok(new
            {
                user = auth.User,
                token = auth.Token,
                roles = auth.Roles,
                message = "Registered successfully."
            });
        }

        // POST /api/Authentication/Refresh
        // Re-issues a JWT for the current user, reflecting current roles (used after role changes).
        [AuthorizeJwt]
        [HttpPost("Refresh")]
        public async Task<IActionResult> Refresh(
            [FromHeader(Name = "culture")] string? culture = null)
        {
            RequestContext.ApplyCulture(culture);

            if (!TryGetAuthenticatedUserId(out var userId))
                return Unauthorized();

            var auth = await _users.IssueTokenAsync(userId);
            if (auth == null)
                return Unauthorized();

            return Ok(BuildAuthResponse(auth, "Token refreshed."));
        }

        [AuthorizeJwt]
        [HttpPost("Logout")]
        public IActionResult Logout(
            [FromHeader(Name = "culture")] string? culture = null)
        {
            RequestContext.ApplyCulture(culture);
            return Ok(new { message = "Logout successful." });
        }

        // POST /api/Authentication/RequestPasswordReset
        // POST /api/Authentication/ForgotPassword (alias for compatibility)
        [AllowAnonymous]
        [HttpPost("RequestPasswordReset")]
        [HttpPost("ForgotPassword")]
        public async Task<IActionResult> RequestPasswordReset(
            [FromBody] PasswordResetRequest request,
            [FromHeader(Name = "culture")] string? culture = null)
        {
            RequestContext.ApplyCulture(culture);
            if (request == null || string.IsNullOrWhiteSpace(request.Email))
                return BadRequest("Email is required");

            // Get user by email
            var user = await _users.GetByEmailAsync(request.Email);
            if (user == null)
            {
                // Return success even if user doesn't exist (security best practice)
                return Ok(new { message = "If the email exists, a password reset link will be sent." });
            }

            // Generate reset token
            var resetToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));
            var tokenExpiry = DateTime.UtcNow.AddHours(24);

            // Get or create user profile and update with reset token
            if (user.Id == null || user.Id == Guid.Empty)
                return StatusCode(500, new { message = "User record is missing an id." });

            var profile = await _userProfileService.GetOrCreateAsync(user.Id.Value);
            if (profile != null)
            {
                var updateRequest = new ConfidantPostgreSQL.Modules.UserProfile.Models.UpdateUserProfileRequest
                {
                    UserId = profile.UserId,
                    ResetPasswordToken = resetToken,
                    ResetPasswordTokenExpiry = tokenExpiry
                };
                await _userProfileService.UpdateAsync(updateRequest);

                // Send email
                await _emailService.SendPasswordResetEmailAsync(request.Email, resetToken, culture ?? "pt-PT");
            }

            return Ok(new { message = "If the email exists, a password reset link will be sent." });
        }

        // POST /api/Authentication/ResetPassword
        [AllowAnonymous]
        [HttpPost("ResetPassword")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Token) || string.IsNullOrWhiteSpace(request.NewPassword))
                return BadRequest("Token and new password are required");

            // Find user profile by reset token using stored procedure
            var profile = await _userProfileService.GetByResetTokenAsync(request.Token);

            if (profile == null)
                return BadRequest(new { message = "Invalid or expired token" });

            // Get user and update password
            var user = await _users.GetByIdAsync(profile.UserId);
            if (user == null)
                return NotFound(new { message = "User not found" });

            // Update password (this will hash it)
            await _users.UpdatePasswordAsync(profile.UserId, request.NewPassword);

            // Clear reset token
            var updateRequest = new ConfidantPostgreSQL.Modules.UserProfile.Models.UpdateUserProfileRequest
            {
                UserId = profile.UserId,
                ResetPasswordToken = null,
                ResetPasswordTokenExpiry = null
            };
            await _userProfileService.UpdateAsync(updateRequest);

            return Ok(new { message = "Password reset successfully" });
        }

        // POST /api/Authentication/SendVerificationEmail
        [AllowAnonymous]
        [HttpPost("SendVerificationEmail")]
        public async Task<IActionResult> SendVerificationEmail(
            [FromBody] SendVerificationEmailRequest request,
            [FromHeader(Name = "culture")] string? culture = null)
        {
            RequestContext.ApplyCulture(culture);
            if (request == null || string.IsNullOrWhiteSpace(request.Email))
                return BadRequest("Email is required");

            var user = await _users.GetByEmailAsync(request.Email);
            if (user == null)
                return NotFound(new { message = "User not found" });

            // Get or create profile
            if (user.Id == null || user.Id == Guid.Empty)
                return StatusCode(500, new { message = "User record is missing an id." });

            var profile = await _userProfileService.GetOrCreateAsync(user.Id.Value);
            if (profile != null)
            {
                // Generate verification token
                var verificationToken = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));

                var updateRequest = new ConfidantPostgreSQL.Modules.UserProfile.Models.UpdateUserProfileRequest
                {
                    UserId = profile.UserId,
                    EmailVerificationToken = verificationToken
                };
                await _userProfileService.UpdateAsync(updateRequest);

                // Send email
                await _emailService.SendEmailVerificationAsync(request.Email, verificationToken, culture ?? "pt-PT");
            }

            return Ok(new { message = "Verification email sent" });
        }
        //

        // POST /api/Authentication/VerifyEmail
        [AllowAnonymous]
        [HttpPost("VerifyEmail")]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Token))
                return BadRequest("Token is required");

            // Find user profile by verification token using stored procedure
            var profile = await _userProfileService.GetByVerificationTokenAsync(request.Token);

            if (profile == null)
                return BadRequest(new { message = "Invalid token" });

            // Mark email as verified
            var updateRequest = new ConfidantPostgreSQL.Modules.UserProfile.Models.UpdateUserProfileRequest
            {
                UserId = profile.UserId,
                EmailVerificationToken = null,
                EmailVerifiedAt = DateTime.UtcNow
            };
            await _userProfileService.UpdateAsync(updateRequest);

            return Ok(new { message = "Email verified successfully" });
        }
    }

    public sealed class AuthenticationLoginRequest
    {
        public string? Email { get; set; }
        public string? Password { get; set; }
        // Kept for payload compatibility with the older API; not required by this service.
        public Guid? StoreId { get; set; }
    }

    public sealed class PasswordResetRequest
    {
        public string? Email { get; set; }
    }

    public sealed class AuthenticationRegisterRequest
    {
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? EducationLevel { get; set; }
        public string? Username { get; set; }
        public string? DisplayName { get; set; }
        public string? MobileNumber { get; set; }
        public string? Nif { get; set; }
    }

    public sealed class ResetPasswordRequest
    {
        public string? Token { get; set; }
        public string? NewPassword { get; set; }
    }

    public sealed class SendVerificationEmailRequest
    {
        public string? Email { get; set; }
    }

    public sealed class VerifyEmailRequest
    {
        public string? Token { get; set; }
    }
}
