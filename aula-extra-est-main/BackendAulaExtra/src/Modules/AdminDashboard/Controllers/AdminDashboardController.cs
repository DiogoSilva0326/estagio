using System;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.AdminDashboard.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.AdminDashboard.Controllers
{
    [ApiController]
    [Route("api/admin")]
    [ServiceFilter(typeof(JwtFilter))]
    public class AdminDashboardController : ControllerBase
    {
        private readonly IAdminDashboardService _service;
        private readonly IUserService _users;

        public AdminDashboardController(IAdminDashboardService service, IUserService users)
        {
            _service = service;
            _users = users;
        }

        private bool TryGetAuthenticatedUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext?.Items == null) return false;
            if (!HttpContext.Items.TryGetValue("UserId", out var raw) || raw == null) return false;
            if (raw is Guid value)
            {
                userId = value;
                return userId != Guid.Empty;
            }

            return Guid.TryParse(raw.ToString(), out userId) && userId != Guid.Empty;
        }

        private async Task<bool> CurrentUserIsAdminAsync(Guid userId)
        {
            var auth = await _users.IssueTokenAsync(userId);
            if (auth?.Roles == null) return false;
            return auth.Roles.Any(role => string.Equals(role?.Trim(), "admin", StringComparison.OrdinalIgnoreCase));
        }

        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboard()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(userId)) return Forbid();

            return Ok(await _service.GetAsync());
        }

        [HttpGet("session-logs")]
        public async Task<IActionResult> GetSessionLogs()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(userId)) return Forbid();

            return Ok(await _service.GetSessionLogsAsync());
        }

        [HttpGet("evaluations")]
        public async Task<IActionResult> GetEvaluations()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(userId)) return Forbid();

            return Ok(await _service.GetEvaluationsAsync());
        }

        [HttpPut("evaluations/{kind}/{evaluationId:guid}/moderation")]
        public async Task<IActionResult> ModerateEvaluation(
            string kind,
            Guid evaluationId,
            [FromBody] ModerateEvaluationRequest? request)
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(userId)) return Forbid();
            if (request == null) return BadRequest(new { message = "Request body is required." });

            var normalizedKind = kind?.Trim().ToLowerInvariant();
            if (normalizedKind != "lesson" && normalizedKind != "professor")
            {
                return BadRequest(new { message = "Kind must be 'lesson' or 'professor'." });
            }

            var rows = await _service.ModerateEvaluationAsync(normalizedKind, evaluationId, request.Approved);
            return rows == 0 ? NotFound() : NoContent();
        }

        public class ModerateEvaluationRequest
        {
            [Required]
            public bool Approved { get; set; }
        }
    }
}