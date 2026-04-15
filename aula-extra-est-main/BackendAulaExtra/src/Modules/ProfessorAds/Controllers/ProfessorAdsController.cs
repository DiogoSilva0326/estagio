using System;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Courses.Service;
using ConfidantPostgreSQL.Modules.ProfessorAds.Models;
using ConfidantPostgreSQL.Modules.ProfessorAds.Service;
using ConfidantPostgreSQL.Modules.Professors.Service;
using ConfidantPostgreSQL.Modules.UserProfile.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.ProfessorAds.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ProfessorAdsController : ControllerBase
    {
        private readonly IProfessorAdsService _adsService;
        private readonly IProfessorsService _professorsService;
        private readonly ICoursesService _coursesService;
        private readonly IUserProfileService _userProfiles;

        public ProfessorAdsController(
            IProfessorAdsService adsService,
            IProfessorsService professorsService,
            ICoursesService coursesService,
            IUserProfileService userProfiles)
        {
            _adsService = adsService;
            _professorsService = professorsService;
            _coursesService = coursesService;
            _userProfiles = userProfiles;
        }

        public class UpsertProfessorAdRequest
        {
            public Guid? IdDisciplina { get; set; }
            public Guid? IdTutoringType { get; set; }
            public string? Description { get; set; }
            public decimal? SessionPrice { get; set; }
            public string? PhotoUrl { get; set; }
            public string? Status { get; set; }
        }

        public class UpdateProfessorAdStatusRequest
        {
            public string? Status { get; set; }
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

        [HttpGet("me")]
        public async Task<IActionResult> GetMyAdsData()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _professorsService.GetProfessorByUserIdAsync(userId);
            if (professor == null)
            {
                return NotFound(new { message = "Professor profile not found" });
            }

            var profile = await _userProfiles.GetByUserIdAsync(userId);
            var disciplinas = (await _professorsService.GetDisciplinasByProfessorIdAsync(professor.IdProfessor))
                .Where(item => item.IsActive)
                .OrderBy(item => item.Nome)
                .ToArray();
            var tutoringTypes = (await _coursesService.GetTutoringTypesAllAsync())
                .OrderBy(item => item.Name)
                .Select(item => new
                {
                    idTutoringType = item.IdTutoringType,
                    name = item.Name,
                    description = item.Description,
                })
                .ToArray();
            var ads = (await _adsService.GetProfessorAdsByProfessorIdAsync(professor.IdProfessor)).ToArray();

            return Ok(new
            {
                profilePhotoUrl = string.IsNullOrWhiteSpace(profile?.ProfileImageUrl)
                    ? professor.Photo
                    : profile!.ProfileImageUrl,
                disciplinas,
                tutoringTypes,
                ads,
            });
        }

        [HttpPost("me")]
        public async Task<IActionResult> UpsertMyAd([FromBody] UpsertProfessorAdRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _professorsService.GetProfessorByUserIdAsync(userId);
            if (professor == null)
            {
                return NotFound(new { message = "Professor profile not found" });
            }

            if (request?.IdDisciplina == null || request.IdDisciplina == Guid.Empty)
            {
                return BadRequest(new { message = "Disciplina é obrigatória." });
            }

            if (request.IdTutoringType == null || request.IdTutoringType == Guid.Empty)
            {
                return BadRequest(new { message = "Tipo de aula é obrigatório." });
            }

            if (request.SessionPrice == null || request.SessionPrice <= 0)
            {
                return BadRequest(new { message = "Preço deve ser maior que zero." });
            }

            try
            {
                var ad = await _adsService.UpsertProfessorAdAsync(
                    professor.IdProfessor,
                    new ProfessorAdUpsert
                    {
                        IdDisciplina = request.IdDisciplina.Value,
                        IdTutoringType = request.IdTutoringType.Value,
                        Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
                        SessionPrice = request.SessionPrice.Value,
                        PhotoUrl = string.IsNullOrWhiteSpace(request.PhotoUrl) ? null : request.PhotoUrl.Trim(),
                        Status = string.IsNullOrWhiteSpace(request.Status) ? "published" : request.Status.Trim(),
                    });

                return Ok(ad);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("me/{idProfessorAd:guid}")]
        public async Task<IActionResult> DeleteMyAd(Guid idProfessorAd)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _professorsService.GetProfessorByUserIdAsync(userId);
            if (professor == null)
            {
                return NotFound(new { message = "Professor profile not found" });
            }

            var rows = await _adsService.DeleteProfessorAdAsync(idProfessorAd, professor.IdProfessor);
            return rows == 0 ? NotFound(new { message = "Anúncio não encontrado." }) : NoContent();
        }

        [HttpPatch("me/{idProfessorAd:guid}/status")]
        public async Task<IActionResult> UpdateMyAdStatus(
            Guid idProfessorAd,
            [FromBody] UpdateProfessorAdStatusRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _professorsService.GetProfessorByUserIdAsync(userId);
            if (professor == null)
            {
                return NotFound(new { message = "Professor profile not found" });
            }

            var normalizedStatus = request?.Status?.Trim().ToLowerInvariant();
            if (normalizedStatus != "published" && normalizedStatus != "inactive")
            {
                return BadRequest(new { message = "Estado inválido para o anúncio." });
            }

            var updated = await _adsService.UpdateProfessorAdStatusAsync(
                idProfessorAd,
                professor.IdProfessor,
                normalizedStatus);

            return updated == null
                ? NotFound(new { message = "Anúncio não encontrado." })
                : Ok(updated);
        }
    }
}
