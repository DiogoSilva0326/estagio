using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Student.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Student.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class StudentProfessorEvaluationsController : ControllerBase
    {
        private readonly IStudentProfessorEvaluationsService _service;

        public StudentProfessorEvaluationsController(IStudentProfessorEvaluationsService service)
        {
            _service = service;
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

        // GET /api/StudentProfessorEvaluations/submitted
        [HttpGet("submitted")]
        public async Task<IActionResult> GetSubmitted()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            var items = await _service.GetSubmittedAsync(userId);
            return Ok(items);
        }

        // GET /api/StudentProfessorEvaluations/pending
        [HttpGet("pending")]
        public async Task<IActionResult> GetPending()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            var items = await _service.GetPendingAsync(userId);
            return Ok(items);
        }

        public class SubmitProfessorEvaluationRequest
        {
            public Guid ProfessorId { get; set; }
            public int Rating { get; set; }
            public string? Comments { get; set; }
        }

        // POST /api/StudentProfessorEvaluations
        [HttpPost]
        public async Task<IActionResult> Submit([FromBody] SubmitProfessorEvaluationRequest request)
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            request ??= new SubmitProfessorEvaluationRequest();

            if (request.ProfessorId == Guid.Empty)
                return BadRequest(new { error = "professorId is required" });

            if (request.Rating < 1 || request.Rating > 5)
                return BadRequest(new { error = "rating must be between 1 and 5" });

            var comments = string.IsNullOrWhiteSpace(request.Comments) ? null : request.Comments.Trim();
            if (comments != null && comments.Length > 2000)
                return BadRequest(new { error = "comments max length is 2000" });

            var (professorFeedbackId, pending) = await _service.SubmitAsync(userId, request.ProfessorId, request.Rating, comments);
            if (professorFeedbackId == Guid.Empty)
                return BadRequest(new { error = "Professor not eligible for evaluation (no completed lesson or already evaluated)" });

            return CreatedAtAction(nameof(GetSubmitted), new
            {
                professorFeedbackId,
                professorId = pending.ProfessorId,
                professorName = pending.ProfessorName,
                lastLessonStart = pending.LastLessonStart,
                lastLessonEnd = pending.LastLessonEnd,
                rating = request.Rating,
                comments,
                createdAt = DateTime.UtcNow
            });
        }
    }
}
