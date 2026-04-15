using System;
using System.ComponentModel.DataAnnotations;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.ContactsForm.DTOs;
using ConfidantPostgreSQL.Modules.ContactsForm.Models;
using ConfidantPostgreSQL.Modules.ContactsForm.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.ContactsForm.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ContactsFormController : ControllerBase
    {
        private readonly IContactsFormService _service;
        private static readonly EmailAddressAttribute EmailValidator = new EmailAddressAttribute();

        public ContactsFormController(IContactsFormService service)
        {
            _service = service;
        }

        private bool TryGetCurrentUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext.Items.TryGetValue("UserId", out var val) && val is Guid guid && guid != Guid.Empty)
            {
                userId = guid;
                return true;
            }
            return false;
        }

        private Guid? TryGetCurrentOrBearerUserId()
        {
            if (TryGetCurrentUserId(out var userId)) return userId;
            return JwtActor.TryGetActorUserId(Request, out userId) ? userId : null;
        }

        private static bool TryNormalizeContactFormStatus(string? rawStatus, out string normalizedStatus)
        {
            normalizedStatus = "não lida";
            var normalized = rawStatus?.Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(normalized))
            {
                return false;
            }

            switch (normalized)
            {
                case "não lida":
                case "nao lida":
                case "nao_lida":
                case "não_lida":
                    normalizedStatus = "não lida";
                    return true;
                case "lida":
                    normalizedStatus = "lida";
                    return true;
                case "respondida":
                    normalizedStatus = "respondida";
                    return true;
                case "arquivada":
                    normalizedStatus = "arquivada";
                    return true;
                default:
                    return false;
            }
        }

        private async Task<ContactFormCategory?> ResolveContactFormCategoryAsync(Guid? idContactFormCategory)
        {
            if (idContactFormCategory == null || idContactFormCategory == Guid.Empty)
            {
                return null;
            }

            return await _service.GetContactFormCategoryByIdAsync(idContactFormCategory.Value);
        }

        private static bool IsValidEmail(string? email)
        {
            return !string.IsNullOrWhiteSpace(email) && EmailValidator.IsValid(email);
        }

        [AllowAnonymous]
        [HttpGet("categories")]
        public async Task<IActionResult> GetContactFormCategories()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetContactFormCategoriesAllAsync());
        }

        [HttpGet("categories/{idContactFormCategory:guid}")]
        public async Task<IActionResult> GetContactFormCategory(Guid idContactFormCategory)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetContactFormCategoryByIdAsync(idContactFormCategory);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("categories")]
        public async Task<IActionResult> CreateContactFormCategory([FromBody] UpsertContactFormCategoryRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (request == null || string.IsNullOrWhiteSpace(request.Name))
            {
                return BadRequest(new { message = "O nome do assunto é obrigatório." });
            }

            var category = new ContactFormCategory
            {
                Name = request.Name.Trim(),
                Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            var id = await _service.InsertContactFormCategoryAsync(category);
            category.IdContactFormCategory = id;
            return CreatedAtAction(nameof(GetContactFormCategory), new { idContactFormCategory = id }, category);
        }

        [HttpPut("categories/{idContactFormCategory:guid}")]
        public async Task<IActionResult> UpdateContactFormCategory(
            Guid idContactFormCategory,
            [FromBody] UpsertContactFormCategoryRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (request == null || string.IsNullOrWhiteSpace(request.Name))
            {
                return BadRequest(new { message = "O nome do assunto é obrigatório." });
            }

            var category = new ContactFormCategory
            {
                IdContactFormCategory = idContactFormCategory,
                Name = request.Name.Trim(),
                Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
                UpdatedAt = DateTimeOffset.UtcNow
            };

            var rows = await _service.UpdateContactFormCategoryAsync(category);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("categories/{idContactFormCategory:guid}")]
        public async Task<IActionResult> DeleteContactFormCategory(Guid idContactFormCategory)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteContactFormCategoryAsync(idContactFormCategory);
            return rows == 0 ? NotFound() : NoContent();
        }

        [AllowAnonymous]
        [HttpPost("submissions/public")]
        public async Task<IActionResult> CreatePublicContactFormSubmission([FromBody] PublicCreateContactFormSubmissionRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (request == null)
            {
                return BadRequest(new { message = "Pedido inválido." });
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                return BadRequest(new { message = "O nome é obrigatório." });
            }

            if (!IsValidEmail(request.Email))
            {
                return BadRequest(new { message = "O email é inválido." });
            }

            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return BadRequest(new { message = "A mensagem é obrigatória." });
            }

            var category = await ResolveContactFormCategoryAsync(request.IdContactFormCategory);
            if (category == null)
            {
                return BadRequest(new { message = "O assunto selecionado é inválido." });
            }

            var submission = new ContactFormSubmission
            {
                IdContactFormCategory = category.IdContactFormCategory,
                Name = request.Name.Trim(),
                Email = request.Email.Trim(),
                Subject = category.Name,
                Message = request.Message.Trim(),
                Status = "não lida",
                UserId = TryGetCurrentOrBearerUserId(),
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            var id = await _service.InsertContactFormSubmissionAsync(submission);
            var created = await _service.GetContactFormSubmissionByIdAsync(id);
            return Ok(created ?? submission);
        }

        [HttpGet("submissions")]
        public async Task<IActionResult> GetContactFormSubmissions([FromQuery] string? status = null)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            string? normalizedStatus = null;
            if (!string.IsNullOrWhiteSpace(status))
            {
                if (!TryNormalizeContactFormStatus(status, out var parsedStatus))
                {
                    return BadRequest(new { message = "O estado indicado é inválido." });
                }
                normalizedStatus = parsedStatus;
            }

            return Ok(await _service.GetContactFormSubmissionsAllAsync(normalizedStatus));
        }

        [HttpGet("submissions/{idContactFormSubmission:guid}")]
        public async Task<IActionResult> GetContactFormSubmission(Guid idContactFormSubmission)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetContactFormSubmissionByIdAsync(idContactFormSubmission);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("submissions")]
        public async Task<IActionResult> CreateContactFormSubmission([FromBody] UpsertContactFormSubmissionRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (request == null)
            {
                return BadRequest(new { message = "Pedido inválido." });
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                return BadRequest(new { message = "O nome é obrigatório." });
            }

            if (!IsValidEmail(request.Email))
            {
                return BadRequest(new { message = "O email é inválido." });
            }

            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return BadRequest(new { message = "A mensagem é obrigatória." });
            }

            var category = await ResolveContactFormCategoryAsync(request.IdContactFormCategory);
            var subject = category?.Name;
            if (string.IsNullOrWhiteSpace(subject))
            {
                subject = request.Subject?.Trim();
            }

            if (string.IsNullOrWhiteSpace(subject))
            {
                return BadRequest(new { message = "O assunto é obrigatório." });
            }

            var currentUserId = TryGetCurrentUserId(out var actorUserId) ? actorUserId : (Guid?)null;
            var normalizedStatus = "não lida";
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                if (!TryNormalizeContactFormStatus(request.Status, out normalizedStatus))
                {
                    return BadRequest(new { message = "O estado indicado é inválido." });
                }
            }

            var submission = new ContactFormSubmission
            {
                IdContactFormCategory = category?.IdContactFormCategory ?? request.IdContactFormCategory,
                Name = request.Name.Trim(),
                Email = request.Email.Trim(),
                Subject = subject.Trim(),
                Message = request.Message.Trim(),
                Status = normalizedStatus,
                UserId = request.UserId,
                UserIdResponse = normalizedStatus == "respondida"
                    ? (request.UserIdResponse ?? currentUserId)
                    : request.UserIdResponse,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            var id = await _service.InsertContactFormSubmissionAsync(submission);
            var created = await _service.GetContactFormSubmissionByIdAsync(id);
            return CreatedAtAction(nameof(GetContactFormSubmission), new { idContactFormSubmission = id }, created ?? submission);
        }

        [HttpPut("submissions/{idContactFormSubmission:guid}")]
        public async Task<IActionResult> UpdateContactFormSubmission(
            Guid idContactFormSubmission,
            [FromBody] UpsertContactFormSubmissionRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            if (request == null)
            {
                return BadRequest(new { message = "Pedido inválido." });
            }

            var existing = await _service.GetContactFormSubmissionByIdAsync(idContactFormSubmission);
            if (existing == null)
            {
                return NotFound();
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                return BadRequest(new { message = "O nome é obrigatório." });
            }

            if (!IsValidEmail(request.Email))
            {
                return BadRequest(new { message = "O email é inválido." });
            }

            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return BadRequest(new { message = "A mensagem é obrigatória." });
            }

            var category = await ResolveContactFormCategoryAsync(request.IdContactFormCategory);
            if (request.IdContactFormCategory != null && request.IdContactFormCategory != Guid.Empty && category == null)
            {
                return BadRequest(new { message = "O assunto selecionado é inválido." });
            }

            var subject = category?.Name ?? request.Subject?.Trim() ?? existing.Subject;
            if (string.IsNullOrWhiteSpace(subject))
            {
                return BadRequest(new { message = "O assunto é obrigatório." });
            }

            var normalizedStatus = existing.Status;
            if (!string.IsNullOrWhiteSpace(request.Status))
            {
                if (!TryNormalizeContactFormStatus(request.Status, out normalizedStatus))
                {
                    return BadRequest(new { message = "O estado indicado é inválido." });
                }
            }

            var currentUserId = TryGetCurrentUserId(out var actorUserId) ? actorUserId : (Guid?)null;
            var submission = new ContactFormSubmission
            {
                IdContactFormSubmission = idContactFormSubmission,
                IdContactFormCategory = category?.IdContactFormCategory ?? request.IdContactFormCategory ?? existing.IdContactFormCategory,
                Name = request.Name.Trim(),
                Email = request.Email.Trim(),
                Subject = subject.Trim(),
                Message = request.Message.Trim(),
                Status = normalizedStatus,
                UserId = request.UserId ?? existing.UserId,
                UserIdResponse = normalizedStatus == "respondida"
                    ? (request.UserIdResponse ?? currentUserId ?? existing.UserIdResponse)
                    : request.UserIdResponse ?? existing.UserIdResponse,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            var rows = await _service.UpdateContactFormSubmissionAsync(submission);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("submissions/{idContactFormSubmission:guid}")]
        public async Task<IActionResult> DeleteContactFormSubmission(Guid idContactFormSubmission)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteContactFormSubmissionAsync(idContactFormSubmission);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
