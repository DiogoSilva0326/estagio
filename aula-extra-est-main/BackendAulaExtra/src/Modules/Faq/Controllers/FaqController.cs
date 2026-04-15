using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Faq.Models;
using ConfidantPostgreSQL.Modules.Faq.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Faq.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class FaqController : ControllerBase
    {
        public class UpsertFaqRequest
        {
            public Guid IdFaqCategory { get; set; }
            public string Question { get; set; } = string.Empty;
            public string Description { get; set; } = string.Empty;
        }

        public class UpsertFaqCategoryRequest
        {
            public string Name { get; set; } = string.Empty;
            public string? Description { get; set; }
        }

        private readonly IFaqService _service;

        public FaqController(IFaqService service)
        {
            _service = service;
        }

        private void ApplyCulture()
        {
            RequestContext.ApplyCultureFromHeader(Request);
        }

        private bool TryGetAuthenticatedUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext?.Items == null) return false;
            if (!HttpContext.Items.TryGetValue("UserId", out var raw) || raw == null) return false;
            if (raw is Guid guid)
            {
                userId = guid;
                return userId != Guid.Empty;
            }

            return Guid.TryParse(raw.ToString(), out userId) && userId != Guid.Empty;
        }

        [AllowAnonymous]
        [HttpGet]
        public async Task<IActionResult> GetPublicFaqs([FromQuery] Guid? categoryId = null, [FromQuery(Name = "q")] string? query = null)
        {
            ApplyCulture();
            return Ok(await _service.GetPublicFaqsAsync(categoryId, query));
        }

        [AllowAnonymous]
        [HttpGet("categories")]
        public async Task<IActionResult> GetPublicCategories()
        {
            ApplyCulture();
            return Ok(await _service.GetPublicCategoriesAsync());
        }

        [HttpGet("admin")]
        public async Task<IActionResult> GetFaqs()
        {
            ApplyCulture();
            return Ok(await _service.GetFaqsAllAsync());
        }

        [HttpGet("admin/{idFaq:guid}")]
        public async Task<IActionResult> GetFaq(Guid idFaq)
        {
            ApplyCulture();
            var item = await _service.GetFaqByIdAsync(idFaq);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("admin")]
        public async Task<IActionResult> CreateFaq([FromBody] UpsertFaqRequest request)
        {
            ApplyCulture();
            if (request.IdFaqCategory == Guid.Empty) return BadRequest("Categoria inválida.");
            if (string.IsNullOrWhiteSpace(request.Question)) return BadRequest("Pergunta é obrigatória.");
            if (string.IsNullOrWhiteSpace(request.Description)) return BadRequest("Descrição é obrigatória.");

            var faq = new FaqEntry
            {
                IdFaqCategory = request.IdFaqCategory,
                Question = request.Question.Trim(),
                Description = request.Description.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                UserId = TryGetAuthenticatedUserId(out var userId) ? userId : null
            };

            var id = await _service.InsertFaqAsync(faq);
            faq.IdFaq = id;
            var created = await _service.GetFaqByIdAsync(id);
            return CreatedAtAction(nameof(GetFaq), new { idFaq = id }, created ?? faq);
        }

        [HttpPut("admin/{idFaq:guid}")]
        public async Task<IActionResult> UpdateFaq(Guid idFaq, [FromBody] UpsertFaqRequest request)
        {
            ApplyCulture();
            if (request.IdFaqCategory == Guid.Empty) return BadRequest("Categoria inválida.");
            if (string.IsNullOrWhiteSpace(request.Question)) return BadRequest("Pergunta é obrigatória.");
            if (string.IsNullOrWhiteSpace(request.Description)) return BadRequest("Descrição é obrigatória.");

            var faq = new FaqEntry
            {
                IdFaq = idFaq,
                IdFaqCategory = request.IdFaqCategory,
                Question = request.Question.Trim(),
                Description = request.Description.Trim(),
                UpdatedAt = DateTime.UtcNow,
                UserId = TryGetAuthenticatedUserId(out var userId) ? userId : null
            };

            var rows = await _service.UpdateFaqAsync(faq);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("admin/{idFaq:guid}")]
        public async Task<IActionResult> DeleteFaq(Guid idFaq)
        {
            ApplyCulture();
            var rows = await _service.DeleteFaqAsync(idFaq);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpGet("admin/categories")]
        public async Task<IActionResult> GetCategories()
        {
            ApplyCulture();
            return Ok(await _service.GetCategoriesAllAsync());
        }

        [HttpGet("admin/categories/{idFaqCategory:guid}")]
        public async Task<IActionResult> GetCategory(Guid idFaqCategory)
        {
            ApplyCulture();
            var item = await _service.GetCategoryByIdAsync(idFaqCategory);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("admin/categories")]
        public async Task<IActionResult> CreateCategory([FromBody] UpsertFaqCategoryRequest request)
        {
            ApplyCulture();
            if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest("Nome da categoria é obrigatório.");

            var category = new FaqCategory
            {
                Name = request.Name.Trim(),
                Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                UserId = TryGetAuthenticatedUserId(out var userId) ? userId : null
            };

            var id = await _service.InsertCategoryAsync(category);
            category.IdFaqCategory = id;
            var created = await _service.GetCategoryByIdAsync(id);
            return CreatedAtAction(nameof(GetCategory), new { idFaqCategory = id }, created ?? category);
        }

        [HttpPut("admin/categories/{idFaqCategory:guid}")]
        public async Task<IActionResult> UpdateCategory(Guid idFaqCategory, [FromBody] UpsertFaqCategoryRequest request)
        {
            ApplyCulture();
            if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest("Nome da categoria é obrigatório.");

            var category = new FaqCategory
            {
                IdFaqCategory = idFaqCategory,
                Name = request.Name.Trim(),
                Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
                UpdatedAt = DateTime.UtcNow,
                UserId = TryGetAuthenticatedUserId(out var userId) ? userId : null
            };

            var rows = await _service.UpdateCategoryAsync(category);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("admin/categories/{idFaqCategory:guid}")]
        public async Task<IActionResult> DeleteCategory(Guid idFaqCategory)
        {
            ApplyCulture();

            try
            {
                var rows = await _service.DeleteCategoryAsync(idFaqCategory);
                return rows == 0 ? NotFound() : NoContent();
            }
            catch (Npgsql.PostgresException ex) when (ex.SqlState == "23503")
            {
                return Conflict("Não é possível eliminar a categoria porque ainda existem FAQs associadas.");
            }
        }
    }
}
