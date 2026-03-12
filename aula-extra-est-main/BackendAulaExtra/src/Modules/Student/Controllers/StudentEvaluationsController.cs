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
    public class StudentEvaluationsController : ControllerBase
    {
        private readonly IStudentEvaluationsService _service;

        public StudentEvaluationsController(IStudentEvaluationsService service)
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

        // GET /api/StudentEvaluations/submitted
        [HttpGet("submitted")]
        public async Task<IActionResult> GetSubmitted()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            var items = await _service.GetSubmittedAsync(userId);
            return Ok(items);
        }

        // GET /api/StudentEvaluations/pending
        // Returns latest completed lesson per professor without feedback.
        [HttpGet("pending")]
        public async Task<IActionResult> GetPending()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            var items = await _service.GetPendingAsync(userId);
            return Ok(items);
        }

        public class SubmitEvaluationRequest
        {
            public Guid LessonId { get; set; }
            public int Rating { get; set; }
            public string? Comments { get; set; }
        }

        // POST /api/StudentEvaluations
        [HttpPost]
        public async Task<IActionResult> Submit([FromBody] SubmitEvaluationRequest request)
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            request ??= new SubmitEvaluationRequest();

            if (request.LessonId == Guid.Empty)
                return BadRequest(new { error = "lessonId is required" });

            if (request.Rating < 1 || request.Rating > 5)
                return BadRequest(new { error = "rating must be between 1 and 5" });

            var comments = string.IsNullOrWhiteSpace(request.Comments) ? null : request.Comments.Trim();
            if (comments != null && comments.Length > 2000)
                return BadRequest(new { error = "comments max length is 2000" });

            var (lessonFeedbackId, pending) = await _service.SubmitAsync(userId, request.LessonId, request.Rating, comments);
            if (lessonFeedbackId == Guid.Empty)
                return BadRequest(new { error = "Lesson not eligible for evaluation (not completed, not enrolled, or already evaluated)" });

            return CreatedAtAction(nameof(GetSubmitted), new
            {
                lessonFeedbackId,
                lessonId = pending.LessonId,
                professorId = pending.ProfessorId,
                professorName = pending.ProfessorName,
                subject = pending.Subject,
                lessonStart = pending.LessonStart,
                lessonEnd = pending.LessonEnd,
                rating = request.Rating,
                comments,
                createdAt = DateTime.UtcNow
            });
        }
    }
}
