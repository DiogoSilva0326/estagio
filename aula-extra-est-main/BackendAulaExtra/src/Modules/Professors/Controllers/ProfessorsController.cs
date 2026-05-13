using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Integrations.AgoraLessons;
using ConfidantPostgreSQL.Modules.Education.Models;
using ConfidantPostgreSQL.Modules.Lessons.Service;
using ConfidantPostgreSQL.Modules.Professors.Models;
using ConfidantPostgreSQL.Modules.Professors.Service;
using ConfidantPostgreSQL.Modules.Schedule.Service;
using ConfidantPostgreSQL.Modules.UserProfile.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Hosting;

namespace ConfidantPostgreSQL.Modules.Professors.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ProfessorsController : ControllerBase
    {
        private const long MaxProfessorDocumentBytes = 12 * 1024 * 1024;
        private static readonly HashSet<string> AllowedProfessorDocumentExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".pdf",
            ".png",
            ".jpg",
            ".jpeg",
            ".doc",
            ".docx"
        };

        private readonly IProfessorsService _service;
        private readonly ILessonsService _lessonsService;
        private readonly IScheduleService _scheduleService;
        private readonly IUserProfileService _userProfiles;
        private readonly IUserService _users;
        private readonly IWebHostEnvironment _environment;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly AgoraLessonOptions _agoraLessonOptions;

        public ProfessorsController(
            IProfessorsService service,
            ILessonsService lessonsService,
            IScheduleService scheduleService,
            IUserProfileService userProfiles,
            IUserService users,
            IWebHostEnvironment environment,
            IHttpClientFactory httpClientFactory,
            AgoraLessonOptions agoraLessonOptions)
        {
            _service = service;
            _lessonsService = lessonsService;
            _scheduleService = scheduleService;
            _userProfiles = userProfiles;
            _users = users;
            _environment = environment;
            _httpClientFactory = httpClientFactory;
            _agoraLessonOptions = agoraLessonOptions;
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

        public class UpsertMyProfessorRequest
        {
            public string? Username { get; set; }
            public string? MobileNumber { get; set; }
            public string? Nif { get; set; }

            public string? CurrentSchool { get; set; }
            public int? YearsExperience { get; set; }
            public string? Photo { get; set; }
            public string? Biography { get; set; }
            public string? PresentationVideoUrl { get; set; }
            public string? Vat { get; set; }
            public string? Iban { get; set; }
            public string? IbanDocumentUrl { get; set; }

            public List<CertificateInput>? Certificates { get; set; }
        }

        public class CertificateInput
        {
            public string? Name { get; set; }
            public string? Description { get; set; }
            public string? FileUrl { get; set; }
        }

        public class UpsertMyCertificateRequest
        {
            public string? Name { get; set; }
            public string? Description { get; set; }
            public string? FileUrl { get; set; }
            public IFormFile? File { get; set; }
        }

        public class ReviewCertificateRequest
        {
            public bool? Approved { get; set; }
            public bool? Verified { get; set; }
        }

        public class SetMyDisciplinasRequest
        {
            public List<Guid>? Ids { get; set; }
        }

        public class UpsertMyDisciplinaRequest
        {
            public Guid? IdDisciplina { get; set; }
            public Guid? IdArea { get; set; }
            public Guid? IdCicloEstudo { get; set; }
            public string? Nome { get; set; }
            public string? Descricao { get; set; }
            public bool? IsActive { get; set; }
        }

        public class ProfessorLanguageInput
        {
            public Guid IdLanguage { get; set; }
            public string? ProficiencyLevel { get; set; }
        }

        public class SetMyLanguagesRequest
        {
            public List<ProfessorLanguageInput>? Items { get; set; }
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        private static string BuildDisplayName(dynamic? user, string fallback)
        {
            if (user == null) return fallback;

            var displayName = user.DisplayName as string;
            if (!string.IsNullOrWhiteSpace(displayName))
            {
                return displayName.Trim();
            }

            var firstName = user.FirstName as string;
            var lastName = user.LastName as string;
            var fullName = string.Join(" ", new[] { firstName?.Trim(), lastName?.Trim() }
                .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

            if (!string.IsNullOrWhiteSpace(fullName))
            {
                return fullName;
            }

            var username = user.Username as string;
            return !string.IsNullOrWhiteSpace(username) ? username.Trim() : fallback;
        }

        private async Task<bool> CurrentUserIsAdminAsync(Guid userId)
        {
            if (userId == Guid.Empty) return false;
            var auth = await _users.IssueTokenAsync(userId);
            if (auth?.Roles == null) return false;

            foreach (var r in auth.Roles)
            {
                if (string.Equals(r?.Trim(), "admin", StringComparison.OrdinalIgnoreCase))
                    return true;
            }

            return false;
        }

        private async Task<object> BuildProfessorAdminReviewPayloadAsync(Professor professor, Modules.Users.Models.User user)
        {
            var displayName = !string.IsNullOrWhiteSpace(user.DisplayName)
                ? user.DisplayName.Trim()
                : string.Join(" ", new[] { user.FirstName?.Trim(), user.LastName?.Trim() }
                    .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

            if (string.IsNullOrWhiteSpace(displayName))
            {
                displayName = !string.IsNullOrWhiteSpace(user.Username)
                    ? user.Username.Trim()
                    : "Professor";
            }

            var stats = await _service.GetProfessorStatsAsync(professor.IdProfessor);
            var disciplinas = (await _service.GetDisciplinasByProfessorIdAsync(professor.IdProfessor)).ToArray();
            var languages = (await _service.GetLanguagesByProfessorIdAsync(professor.IdProfessor)).ToArray();
            var profile = await _userProfiles.GetByUserIdAsync(professor.IdUser);
            var days = (await _scheduleService.GetDaysAllAsync())
                .Where(day => day.DayIndex.HasValue)
                .ToDictionary(day => day.IdDay, day => day.DayIndex!.Value);
            var availability = (await _scheduleService.GetScheduleBlocksAllAsync())
                .Where(item => item.IdProfessor == professor.IdProfessor)
                .Where(item => item.StartTime.HasValue)
                .OrderBy(item => item.StartTime ?? DateTime.MaxValue)
                .Select(item => new
                {
                    idScheduleBlock = item.IdScheduleBlock,
                    dayIndex = item.IdDay.HasValue && days.TryGetValue(item.IdDay.Value, out var mappedDayIndex)
                        ? mappedDayIndex
                        : (((int)item.StartTime!.Value.DayOfWeek + 6) % 7),
                    startTime = item.StartTime,
                    endTime = item.EndTime,
                    isAvailable = item.IsAvailable ?? true,
                    defaultDurationMinutes = item.DefaultDurationMinutes,
                    recurrenceRule = item.RecurrenceRule,
                })
                .ToArray();
            var certificates = (await _service.GetCertificatesByProfessorIdAsync(professor.IdProfessor))
                .Where(item => !string.IsNullOrWhiteSpace(item.Name) || !string.IsNullOrWhiteSpace(item.FileUrl))
                .OrderBy(item => item.Name ?? item.FileUrl ?? string.Empty)
                .Select(item => new
                {
                    idCertificate = item.IdCertificate,
                    idProfessor = item.IdProfessor,
                    name = string.IsNullOrWhiteSpace(item.Name) ? null : item.Name.Trim(),
                    description = string.IsNullOrWhiteSpace(item.Description) ? null : item.Description.Trim(),
                    fileUrl = string.IsNullOrWhiteSpace(item.FileUrl) ? null : item.FileUrl.Trim(),
                    approved = item.Approved ?? false,
                    approvedByUserId = item.ApprovedByUserId,
                    verified = item.Verified ?? false,
                    verifiedByUserId = item.VerifiedByUserId,
                    createdAt = item.CreatedAt,
                    updatedAt = item.UpdatedAt,
                })
                .ToArray();
            var reviews = (await _service.GetProfessorFeedbackAllAsync())
                .Where(item => item.IdProfessor == professor.IdProfessor)
                .Where(item => item.IsValid != false)
                .Where(item => item.Rating.HasValue || !string.IsNullOrWhiteSpace(item.Comments))
                .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
                .Take(10)
                .ToArray();

            var reviewItems = await Task.WhenAll(reviews.Select(async review =>
            {
                var reviewUser = await _users.GetByIdAsync(review.IdUser);
                var reviewProfile = await _userProfiles.GetByUserIdAsync(review.IdUser);

                var reviewDisplayName = reviewUser == null
                    ? "Aluno"
                    : !string.IsNullOrWhiteSpace(reviewUser.DisplayName)
                        ? reviewUser.DisplayName.Trim()
                        : string.Join(" ", new[] { reviewUser.FirstName?.Trim(), reviewUser.LastName?.Trim() }
                            .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

                if (string.IsNullOrWhiteSpace(reviewDisplayName))
                {
                    reviewDisplayName = !string.IsNullOrWhiteSpace(reviewUser?.Username)
                        ? reviewUser!.Username!.Trim()
                        : "Aluno";
                }

                return new
                {
                    idProfessorFeedback = review.IdProfessorFeedback,
                    idUser = review.IdUser,
                    reviewerName = reviewDisplayName,
                    reviewerImageUrl = reviewProfile?.ProfileImageUrl,
                    rating = review.Rating ?? 0,
                    comment = string.IsNullOrWhiteSpace(review.Comments)
                        ? null
                        : review.Comments!.Trim(),
                    createdAt = review.CreatedAt,
                };
            }));

            var isApproved = professor.IsVerified == true
                && professor.IsVerifiedIban == true
                && professor.IsActive == true
                && professor.IsRejected != true;
            var statusLabel = professor.IsRejected == true
                ? "REJEITADO"
                : isApproved
                    ? "APROVADO"
                    : "PENDENTE";

            return new
            {
                idProfessor = professor.IdProfessor,
                idUser = professor.IdUser,
                displayName,
                username = user.Username,
                email = user.Email,
                mobileNumber = user.MobileNumber,
                phoneNumber = user.PhoneNumber,
                educationLevel = user.EducationLevel,
                website = user.Website,
                photo = !string.IsNullOrWhiteSpace(professor.Photo) ? professor.Photo : profile?.ProfileImageUrl,
                profileImageUrl = profile?.ProfileImageUrl,
                biography = professor.Biography,
                presentationVideoUrl = professor.PresentationVideoUrl,
                currentSchool = professor.CurrentSchool,
                yearsExperience = professor.YearsExperience,
                ibanDocumentUrl = professor.IbanDocumentUrl,
                memberSince = user.CreationDate,
                isApproved,
                isActive = professor.IsActive ?? false,
                isVerified = professor.IsVerified ?? false,
                isVerifiedIban = professor.IsVerifiedIban ?? false,
                isRejected = professor.IsRejected ?? false,
                statusLabel,
                stats = new
                {
                    lessonsCount = stats.LessonsCount,
                    avgRating = stats.AvgRating,
                    reviewCount = stats.ReviewCount,
                },
                areaNames = disciplinas
                    .Select(item => item.AreaNome)
                    .Where(value => !string.IsNullOrWhiteSpace(value))
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .ToArray(),
                disciplinas = disciplinas.Select(item => new
                {
                    idDisciplina = item.IdDisciplina,
                    nome = item.Nome,
                    areaNome = item.AreaNome,
                }).ToArray(),
                languages = languages.Select(item => new
                {
                    idLanguage = item.IdLanguage,
                    nome = item.Nome,
                    proficiencyLevel = item.ProficiencyLevel,
                }).ToArray(),
                availability,
                certificates,
                reviews = reviewItems,
            };
        }

        // PROFESSORS
        [HttpGet("professors")]
        public async Task<IActionResult> GetProfessors()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetProfessorsAllAsync());
        }

        [HttpGet("admin-directory")]
        public async Task<IActionResult> GetAdminDirectory([FromQuery] string? category)
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(userId)) return Forbid();

            var normalizedCategory = string.IsNullOrWhiteSpace(category)
                ? null
                : category.Trim().ToLowerInvariant();

            if (normalizedCategory != null
                && normalizedCategory != "explicadores"
                && normalizedCategory != "tutores"
                && normalizedCategory != "psicologos")
            {
                return BadRequest(new { error = "A categoria deve ser explicadores, tutores ou psicologos." });
            }

            var items = await _service.GetAdminProfessionalDirectoryAsync(normalizedCategory);
            return Ok(new { items });
        }

        // Public browse endpoint for "Mais explicadores" (student role).
        // GET /api/Professors/browse?q=...&areaId=...&disciplinaId=...&cicloId=...&anoId=...&maxPrice=...&minRating=...&availability=morning&availability=weekend&page=1&pageSize=4
        [AllowAnonymous]
        [HttpGet("browse")]
        public async Task<IActionResult> BrowseTutors(
            [FromQuery] string? q,
            [FromQuery] Guid? areaId,
            [FromQuery] Guid? disciplinaId,
            [FromQuery] Guid? cicloId,
            [FromQuery] Guid? anoId,
            [FromQuery] decimal? maxPrice,
            [FromQuery] decimal? minRating,
            [FromQuery] string[]? availability,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 4)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            var flags = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (availability != null)
            {
                foreach (var a in availability)
                {
                    if (string.IsNullOrWhiteSpace(a)) continue;
                    var parts = a.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (var part in parts)
                    {
                        var v = part.Trim();
                        if (!string.IsNullOrWhiteSpace(v)) flags.Add(v);
                    }
                }
            }

            var query = new TutorBrowseQuery
            {
                Q = q,
                AreaId = areaId,
                DisciplinaId = disciplinaId,
                CicloEstudoId = cicloId,
                AnoEscolaridadeId = anoId,
                MaxPrice = maxPrice,
                MinRating = minRating,
                Morning = flags.Contains("morning") || flags.Contains("manha") || flags.Contains("manhã"),
                Afternoon = flags.Contains("afternoon") || flags.Contains("tarde") || flags.Contains("tardes"),
                Evening = flags.Contains("evening") || flags.Contains("noite") || flags.Contains("noites"),
                Weekend = flags.Contains("weekend") || flags.Contains("fimdesemana") || flags.Contains("finsdesemana"),
                Page = page,
                PageSize = pageSize,
            };

            var res = await _service.BrowseTutorsAsync(query);
            return Ok(res);
        }

        // GET /api/Professors/me
        [HttpGet("me")]
        public async Task<IActionResult> GetMyProfessor()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var item = await _service.GetProfessorByUserIdAsync(userId);
            return item == null ? NotFound() : Ok(item);
        }

        // MY STATS (authenticated professor)
        // GET /api/Professors/me/stats
        [HttpGet("me/stats")]
        public async Task<IActionResult> GetMyStats()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null)
            {
                return Ok(new { lessonsCount = 0, avgRating = 0m, reviewCount = 0 });
            }

            var stats = await _service.GetProfessorStatsAsync(professor.IdProfessor);
            return Ok(new
            {
                lessonsCount = stats.LessonsCount,
                avgRating = stats.AvgRating,
                reviewCount = stats.ReviewCount,
            });
        }

        [AllowAnonymous]
        [HttpGet("ratings/summary")]
        public async Task<IActionResult> GetGlobalRatingSummary()
        {
            var stats = await _service.GetGlobalRatingSummaryAsync();
            return Ok(new
            {
                avgRating = stats.AvgRating,
                reviewCount = stats.ReviewCount,
            });
        }

        // GET /api/Professors/me/evaluations
        [HttpGet("me/evaluations")]
        public async Task<IActionResult> GetMyEvaluations()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null)
            {
                return NotFound(new { message = "Professor profile not found" });
            }

            var professorFeedback = (await _service.GetProfessorFeedbackAllAsync())
                .Where(item => item.IdProfessor == professor.IdProfessor)
                .Where(item => item.IsValid != false)
                .Where(item => item.Rating.HasValue || !string.IsNullOrWhiteSpace(item.Comments))
                .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
                .Take(20)
                .ToArray();

            var professorLessons = (await _lessonsService.GetLessonsAllAsync())
                .Where(item => item.IdProfessor == professor.IdProfessor)
                .ToDictionary(item => item.IdLesson, item => item);

            var lessonFeedback = (await _lessonsService.GetLessonFeedbackAllAsync())
                .Where(item => professorLessons.ContainsKey(item.IdLesson))
                .Where(item => item.IsValid)
                .Where(item => item.Rating.HasValue || !string.IsNullOrWhiteSpace(item.Comments))
                .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
                .Take(20)
                .ToArray();

            var professorItems = await Task.WhenAll(professorFeedback.Select(async item =>
            {
                var student = await _users.GetByIdAsync(item.IdUser);
                var profile = await _userProfiles.GetByUserIdAsync(item.IdUser);

                return new
                {
                    idProfessorFeedback = item.IdProfessorFeedback,
                    idUser = item.IdUser,
                    studentName = BuildDisplayName(student, "Aluno"),
                    studentAvatarUrl = string.IsNullOrWhiteSpace(profile?.ProfileImageUrl)
                        ? null
                        : profile!.ProfileImageUrl!.Trim(),
                    rating = item.Rating ?? 0,
                    comment = string.IsNullOrWhiteSpace(item.Comments) ? null : item.Comments!.Trim(),
                    createdAt = item.CreatedAt,
                };
            }));

            var lessonItems = await Task.WhenAll(lessonFeedback.Select(async item =>
            {
                var student = await _users.GetByIdAsync(item.IdUser);
                var profile = await _userProfiles.GetByUserIdAsync(item.IdUser);
                var lesson = professorLessons[item.IdLesson];

                return new
                {
                    idLessonFeedback = item.IdLessonFeedback,
                    idLesson = item.IdLesson,
                    idUser = item.IdUser,
                    studentName = BuildDisplayName(student, "Aluno"),
                    studentAvatarUrl = string.IsNullOrWhiteSpace(profile?.ProfileImageUrl)
                        ? null
                        : profile!.ProfileImageUrl!.Trim(),
                    rating = item.Rating ?? 0,
                    comment = string.IsNullOrWhiteSpace(item.Comments) ? null : item.Comments!.Trim(),
                    createdAt = item.CreatedAt,
                    lessonTitle = string.IsNullOrWhiteSpace(lesson.Title) ? "Aula" : lesson.Title!.Trim(),
                    scheduledStart = lesson.ScheduledStart,
                    scheduledEnd = lesson.ScheduledEnd,
                };
            }));

            return Ok(new
            {
                professorSummary = new
                {
                    averageRating = professorItems.Length == 0
                        ? 0.0
                        : Math.Round(professorItems.Average(item => item.rating), 1),
                    totalReviews = professorItems.Length,
                },
                lessonSummary = new
                {
                    averageRating = lessonItems.Length == 0
                        ? 0.0
                        : Math.Round(lessonItems.Average(item => item.rating), 1),
                    totalReviews = lessonItems.Length,
                },
                professorReviews = professorItems,
                lessonReviews = lessonItems,
            });
        }

        // MY DISCIPLINAS (authenticated professor)
        // GET /api/Professors/me/disciplinas
        [HttpGet("me/disciplinas")]
        public async Task<IActionResult> GetMyDisciplinas()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return Ok(Array.Empty<Disciplina>());

            var items = await _service.GetDisciplinasByProfessorIdAsync(professor.IdProfessor);
            return Ok(items);
        }

        // POST /api/Professors/me/disciplinas
        [HttpPost("me/disciplinas")]
        public async Task<IActionResult> CreateMyDisciplina([FromBody] UpsertMyDisciplinaRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            if (request?.IdArea == null || request.IdArea == Guid.Empty)
            {
                return BadRequest(new { message = "Área é obrigatória." });
            }


            var nome = request.Nome?.Trim();
            if (string.IsNullOrWhiteSpace(nome))
            {
                return BadRequest(new { message = "Nome da disciplina é obrigatório." });
            }

            var input = new ProfessorDisciplinaUpsert
            {
                IdDisciplina = request.IdDisciplina,
                IdArea = request.IdArea.Value,
                IdCicloEstudo = request.IdCicloEstudo,
                Nome = nome,
                Descricao = string.IsNullOrWhiteSpace(request.Descricao) ? null : request.Descricao.Trim(),
                IsActive = request.IsActive ?? true,
            };

            await _service.UpsertDisciplinaForProfessorAsync(professor.IdProfessor, input);
            var items = await _service.GetDisciplinasByProfessorIdAsync(professor.IdProfessor);
            return Ok(new { disciplinas = items });
        }

        // PUT /api/Professors/me/disciplinas
        // Body: { ids: [guid, ...] }  (empty or null clears)
        [HttpPut("me/disciplinas")]
        public async Task<IActionResult> SetMyDisciplinas([FromBody] SetMyDisciplinasRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            request ??= new SetMyDisciplinasRequest();
            var ids = request.Ids?.ToArray() ?? Array.Empty<Guid>();
            var count = await _service.SetDisciplinasForProfessorAsync(professor.IdProfessor, ids);
            var items = await _service.GetDisciplinasByProfessorIdAsync(professor.IdProfessor);

            return Ok(new { count, disciplinas = items });
        }

        // PUT /api/Professors/me/disciplinas/{idDisciplina}
        [HttpPut("me/disciplinas/{idDisciplina:guid}")]
        public async Task<IActionResult> UpdateMyDisciplina(Guid idDisciplina, [FromBody] UpsertMyDisciplinaRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            if (request?.IdArea == null || request.IdArea == Guid.Empty)
            {
                return BadRequest(new { message = "Área é obrigatória." });
            }

            var nome = request.Nome?.Trim();
            if (string.IsNullOrWhiteSpace(nome))
            {
                return BadRequest(new { message = "Nome da disciplina é obrigatório." });
            }

            var input = new ProfessorDisciplinaUpsert
            {
                IdDisciplina = request.IdDisciplina,
                IdArea = request.IdArea.Value,
                IdCicloEstudo = request.IdCicloEstudo.Value,
                Nome = nome,
                Descricao = string.IsNullOrWhiteSpace(request.Descricao) ? null : request.Descricao.Trim(),
                IsActive = request.IsActive ?? true,
            };

            await _service.UpsertDisciplinaForProfessorAsync(professor.IdProfessor, input, idDisciplina);
            var items = await _service.GetDisciplinasByProfessorIdAsync(professor.IdProfessor);
            return Ok(new { disciplinas = items });
        }

        // DELETE /api/Professors/me/disciplinas/{idDisciplina}
        [HttpDelete("me/disciplinas/{idDisciplina:guid}")]
        public async Task<IActionResult> RemoveMyDisciplina(Guid idDisciplina)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            var count = await _service.RemoveDisciplinaForProfessorAsync(professor.IdProfessor, idDisciplina);
            var items = await _service.GetDisciplinasByProfessorIdAsync(professor.IdProfessor);
            return Ok(new { count, disciplinas = items });
        }

        // LANGUAGES CATALOG
        // GET /api/Professors/languages
        [HttpGet("languages")]
        public async Task<IActionResult> GetLanguagesCatalog()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var items = await _service.GetLanguagesCatalogAsync();
            return Ok(items);
        }

        // GET /api/Professors/me/languages
        [HttpGet("me/languages")]
        public async Task<IActionResult> GetMyLanguages()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return Ok(Array.Empty<ProfessorLanguage>());

            var items = await _service.GetLanguagesByProfessorIdAsync(professor.IdProfessor);
            return Ok(items);
        }

        [HttpGet("me/certificates")]
        public async Task<IActionResult> GetMyCertificates()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return Ok(Array.Empty<Certificate>());

            var items = await _service.GetCertificatesByProfessorIdAsync(professor.IdProfessor);
            return Ok(items);
        }

        [HttpPost("me/certificates")]
        [RequestSizeLimit(MaxProfessorDocumentBytes)]
        public async Task<IActionResult> CreateMyCertificate([FromForm] UpsertMyCertificateRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            var validationError = ValidateCertificateRequest(request, requiresFileReference: true);
            if (validationError != null) return BadRequest(new { message = validationError });

            var fileUrl = await ResolveCertificateFileUrlAsync(request);

            var cert = new Certificate
            {
                IdProfessor = professor.IdProfessor,
                Name = request.Name!.Trim(),
                Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
                FileUrl = fileUrl,
                Approved = false,
                ApprovedByUserId = null,
                Verified = false,
                VerifiedByUserId = null,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
            };

            cert.IdCertificate = await _service.InsertCertificateAsync(cert);
            return CreatedAtAction(nameof(GetCertificate), new { idCertificate = cert.IdCertificate }, cert);
        }

        [HttpPut("me/certificates/{idCertificate:guid}")]
        [RequestSizeLimit(MaxProfessorDocumentBytes)]
        public async Task<IActionResult> UpdateMyCertificate(Guid idCertificate, [FromForm] UpsertMyCertificateRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            var existing = await _service.GetCertificateByIdAsync(idCertificate);
            if (existing == null || existing.IdProfessor != professor.IdProfessor)
            {
                return NotFound(new { message = "Documento não encontrado" });
            }

            var validationError = ValidateCertificateRequest(request, requiresFileReference: false);
            if (validationError != null) return BadRequest(new { message = validationError });

            var previousFileUrl = existing.FileUrl;
            var fileUrl = string.IsNullOrWhiteSpace(request.FileUrl)
                ? existing.FileUrl
                : request.FileUrl.Trim();

            if (request.File != null)
            {
                fileUrl = await ResolveCertificateFileUrlAsync(request);
            }

            if (string.IsNullOrWhiteSpace(fileUrl))
            {
                return BadRequest(new { message = "O documento precisa de um ficheiro associado." });
            }

            existing.Name = request.Name?.Trim();
            existing.Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim();
            existing.FileUrl = fileUrl;
            existing.Approved = false;
            existing.ApprovedByUserId = null;
            existing.Verified = false;
            existing.VerifiedByUserId = null;
            existing.UpdatedAt = DateTime.UtcNow;

            await _service.UpdateCertificateAsync(existing);

            if (request.File != null)
            {
                await TryDeleteProfessorDocumentAsync(previousFileUrl, HttpContext.RequestAborted);
            }

            return Ok(existing);
        }

        [HttpDelete("me/certificates/{idCertificate:guid}")]
        public async Task<IActionResult> DeleteMyCertificate(Guid idCertificate)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            var existing = await _service.GetCertificateByIdAsync(idCertificate);
            if (existing == null || existing.IdProfessor != professor.IdProfessor)
            {
                return NotFound(new { message = "Documento não encontrado" });
            }

            var rows = await _service.DeleteCertificateAsync(idCertificate);
            if (rows == 0) return NotFound(new { message = "Documento não encontrado" });

            await TryDeleteProfessorDocumentAsync(existing.FileUrl, HttpContext.RequestAborted);
            return NoContent();
        }

        // PUT /api/Professors/me/languages
        // Body: { items: [{ idLanguage, proficiencyLevel }] }
        [HttpPut("me/languages")]
        public async Task<IActionResult> SetMyLanguages([FromBody] SetMyLanguagesRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            request ??= new SetMyLanguagesRequest();
            var items = request.Items?
                .Where(item => item != null && item.IdLanguage != Guid.Empty)
                .Select(item => new ProfessorLanguage
                {
                    IdLanguage = item.IdLanguage,
                    ProficiencyLevel = string.IsNullOrWhiteSpace(item.ProficiencyLevel) ? null : item.ProficiencyLevel.Trim(),
                })
                .ToArray() ?? Array.Empty<ProfessorLanguage>();

            var count = await _service.SetLanguagesForProfessorAsync(professor.IdProfessor, items);
            var updatedItems = await _service.GetLanguagesByProfessorIdAsync(professor.IdProfessor);

            return Ok(new { count, languages = updatedItems });
        }

        // DELETE /api/Professors/me/languages/{idLanguage}
        [HttpDelete("me/languages/{idLanguage:guid}")]
        public async Task<IActionResult> RemoveMyLanguage(Guid idLanguage)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var professor = await _service.GetProfessorByUserIdAsync(userId);
            if (professor == null) return NotFound(new { message = "Professor profile not found" });

            var count = await _service.RemoveLanguageForProfessorAsync(professor.IdProfessor, idLanguage);
            var items = await _service.GetLanguagesByProfessorIdAsync(professor.IdProfessor);
            return Ok(new { count, languages = items });
        }

        // PUT /api/Professors/me
        // Upserts the professor record for the authenticated user and returns a refreshed auth payload
        // { user, token, roles }. Note: the "professor" role is NOT granted on submission; it must be
        // assigned by an admin after review.
        [HttpPut("me")]
        public async Task<IActionResult> UpsertMyProfessor([FromBody] UpsertMyProfessorRequest request)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            request ??= new UpsertMyProfessorRequest();

            // Update basic user fields (best-effort, only non-empty values)
            var user = await _users.GetByIdAsync(userId);
            if (user == null) return Unauthorized();

            if (!string.IsNullOrWhiteSpace(request.Username)) user.Username = request.Username.Trim();
            if (!string.IsNullOrWhiteSpace(request.MobileNumber)) user.MobileNumber = request.MobileNumber.Trim();
            if (!string.IsNullOrWhiteSpace(request.Nif)) user.Nif = request.Nif.Trim();
            await _users.UpdateAsync(user);

            // Upsert professor record
            var existing = await _service.GetProfessorByUserIdAsync(userId);
            var professor = new Professor
            {
                IdProfessor = existing?.IdProfessor ?? Guid.Empty,
                IdUser = userId,
                CurrentSchool = string.IsNullOrWhiteSpace(request.CurrentSchool) ? null : request.CurrentSchool?.Trim(),
                YearsExperience = request.YearsExperience,
                Photo = string.IsNullOrWhiteSpace(request.Photo) ? null : request.Photo?.Trim(),
                Biography = string.IsNullOrWhiteSpace(request.Biography) ? null : request.Biography?.Trim(),
                PresentationVideoUrl = string.IsNullOrWhiteSpace(request.PresentationVideoUrl) ? null : request.PresentationVideoUrl?.Trim(),
                Vat = string.IsNullOrWhiteSpace(request.Vat) ? null : request.Vat?.Trim(),
                Iban = string.IsNullOrWhiteSpace(request.Iban) ? null : request.Iban?.Trim(),
                IbanDocumentUrl = string.IsNullOrWhiteSpace(request.IbanDocumentUrl) ? null : request.IbanDocumentUrl?.Trim(),
                // Business rule: a submitted application starts inactive/unverified.
                // If the professor already exists and is verified/active, preserve that.
                IsActive = existing?.IsActive ?? false,
                IsVerified = existing?.IsVerified ?? false,
                IsVerifiedIban = existing?.IsVerifiedIban ?? false,
            };

            if (existing == null)
            {
                var id = await _service.InsertProfessorAsync(professor);
                professor.IdProfessor = id;
            }
            else
            {
                await _service.UpdateProfessorAsync(professor);
            }

            // Certificates are optional. If provided, replace the set for this professor.
            if (request.Certificates != null)
            {
                await _service.DeleteCertificatesByProfessorIdAsync(professor.IdProfessor);

                foreach (var c in request.Certificates)
                {
                    var name = c?.Name?.Trim();
                    var url = c?.FileUrl?.Trim();
                    if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(url)) continue;

                    await _service.InsertCertificateAsync(new Certificate
                    {
                        IdProfessor = professor.IdProfessor,
                        Name = name,
                        Description = string.IsNullOrWhiteSpace(c?.Description) ? null : c.Description.Trim(),
                        FileUrl = url,
                        Verified = false,
                        VerifiedByUserId = null,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow,
                    });
                }
            }

            var auth = await _users.IssueTokenAsync(userId);
            if (auth == null) return Unauthorized();

            return Ok(new
            {
                user = auth.User,
                token = auth.Token,
                roles = auth.Roles,
                message = "Candidatura submetida. Aguarda aprovação do administrador."
            });
        }

        [HttpGet("me/students")]
        public async Task<IActionResult> GetStudents([FromQuery] string? role)
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var students = await _service.GetAlunosByProfessorIdAsync(userId, role);
            return Ok(students);
        }

        [HttpGet("professors/{idProfessor:guid}")]
        public async Task<IActionResult> GetProfessor(Guid idProfessor)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetProfessorByIdAsync(idProfessor);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpGet("professors/{idProfessor:guid}/admin-review")]
        public async Task<IActionResult> GetProfessorAdminReview(Guid idProfessor)
        {
            if (!TryGetAuthenticatedUserId(out var actorUserId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(actorUserId)) return Forbid();

            var professor = await _service.GetProfessorByIdAsync(idProfessor);
            if (professor == null) return NotFound();

            var user = await _users.GetByIdAsync(professor.IdUser);
            if (user == null) return NotFound();

            return Ok(await BuildProfessorAdminReviewPayloadAsync(professor, user));
        }

        [AllowAnonymous]
        [HttpGet("professors/{idProfessor:guid}/public-profile")]
        public async Task<IActionResult> GetPublicProfessorProfile(Guid idProfessor)
        {
            RequestContext.ApplyCultureFromHeader(Request);

            var professor = await _service.GetProfessorByIdAsync(idProfessor);
            if (professor == null) return NotFound();

            var user = await _users.GetByIdAsync(professor.IdUser);
            if (user == null) return NotFound();

            var displayName = !string.IsNullOrWhiteSpace(user.DisplayName)
                ? user.DisplayName.Trim()
                : string.Join(" ", new[] { user.FirstName?.Trim(), user.LastName?.Trim() }
                    .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

            if (string.IsNullOrWhiteSpace(displayName))
            {
                displayName = !string.IsNullOrWhiteSpace(user.Username)
                    ? user.Username.Trim()
                    : "Professor";
            }

            var stats = await _service.GetProfessorStatsAsync(professor.IdProfessor);
            var disciplinas = await _service.GetDisciplinasByProfessorIdAsync(professor.IdProfessor);
            var languages = await _service.GetLanguagesByProfessorIdAsync(professor.IdProfessor);
            var days = (await _scheduleService.GetDaysAllAsync())
                .Where(day => day.DayIndex.HasValue)
                .ToDictionary(day => day.IdDay, day => day.DayIndex!.Value);
            var availability = (await _scheduleService.GetScheduleBlocksAllAsync())
                .Where(item => item.IdProfessor == professor.IdProfessor)
                .Where(item => item.IsAvailable != false)
                .Where(item => item.StartTime.HasValue)
                .OrderBy(item => item.StartTime ?? DateTime.MaxValue)
                .Select(item => new
                {
                    idScheduleBlock = item.IdScheduleBlock,
                    dayIndex = item.IdDay.HasValue && days.TryGetValue(item.IdDay.Value, out var mappedDayIndex)
                        ? mappedDayIndex
                        : (((int)item.StartTime!.Value.DayOfWeek + 6) % 7),
                    startTime = item.StartTime,
                    endTime = item.EndTime,
                    isAvailable = item.IsAvailable ?? true,
                    defaultDurationMinutes = item.DefaultDurationMinutes,
                    recurrenceRule = item.RecurrenceRule,
                })
                .ToArray();
            var certificates = (await _service.GetCertificatesByProfessorIdAsync(professor.IdProfessor))
                .Where(item => !string.IsNullOrWhiteSpace(item.Name) || !string.IsNullOrWhiteSpace(item.FileUrl))
                .OrderBy(item => item.Name ?? item.FileUrl ?? string.Empty)
                .Select(item => new
                {
                    idCertificate = item.IdCertificate,
                    idProfessor = item.IdProfessor,
                    name = string.IsNullOrWhiteSpace(item.Name) ? null : item.Name.Trim(),
                    description = string.IsNullOrWhiteSpace(item.Description) ? null : item.Description.Trim(),
                    fileUrl = string.IsNullOrWhiteSpace(item.FileUrl) ? null : item.FileUrl.Trim(),
                    verified = item.Verified,
                    verifiedByUserId = item.VerifiedByUserId,
                    createdAt = item.CreatedAt,
                    updatedAt = item.UpdatedAt,
                })
                .ToArray();
            var reviews = (await _service.GetProfessorFeedbackAllAsync())
                .Where(item => item.IdProfessor == professor.IdProfessor)
                .Where(item => item.IsValid != false)
                .Where(item => item.Rating.HasValue || !string.IsNullOrWhiteSpace(item.Comments))
                .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
                .Take(20)
                .ToArray();

            var reviewItems = await Task.WhenAll(reviews.Select(async review =>
            {
                var reviewUser = await _users.GetByIdAsync(review.IdUser);
                var reviewProfile = await _userProfiles.GetByUserIdAsync(review.IdUser);

                var reviewDisplayName = reviewUser == null
                    ? "Aluno"
                    : !string.IsNullOrWhiteSpace(reviewUser.DisplayName)
                        ? reviewUser.DisplayName.Trim()
                        : string.Join(" ", new[] { reviewUser.FirstName?.Trim(), reviewUser.LastName?.Trim() }
                            .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

                if (string.IsNullOrWhiteSpace(reviewDisplayName))
                {
                    reviewDisplayName = !string.IsNullOrWhiteSpace(reviewUser?.Username)
                        ? reviewUser!.Username!.Trim()
                        : "Aluno";
                }

                return new
                {
                    idProfessorFeedback = review.IdProfessorFeedback,
                    idUser = review.IdUser,
                    reviewerName = reviewDisplayName,
                    reviewerImageUrl = reviewProfile?.ProfileImageUrl,
                    rating = review.Rating ?? 0,
                    comment = string.IsNullOrWhiteSpace(review.Comments)
                        ? null
                        : review.Comments!.Trim(),
                    createdAt = review.CreatedAt,
                };
            }));

            return Ok(new
            {
                idProfessor = professor.IdProfessor,
                idUser = professor.IdUser,
                displayName,
                username = user.Username,
                photo = professor.Photo,
                biography = professor.Biography,
                presentationVideoUrl = professor.PresentationVideoUrl,
                currentSchool = professor.CurrentSchool,
                yearsExperience = professor.YearsExperience,
                website = user.Website,
                memberSince = user.CreationDate,
                isVerified = professor.IsVerified ?? false,
                stats = new
                {
                    lessonsCount = stats.LessonsCount,
                    avgRating = stats.AvgRating,
                    reviewCount = stats.ReviewCount,
                },
                availability,
                disciplinas,
                languages,
                certificates,
                reviews = reviewItems,
            });
        }

        // PUT /api/Professors/professors/{idProfessor}/approve
        // Admin-only: approves a professor application by setting the 3 approval flags true
        // and granting the "professor" role to the underlying user.
        [HttpPut("professors/{idProfessor:guid}/approve")]
        public async Task<IActionResult> ApproveProfessor(Guid idProfessor)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (!TryGetAuthenticatedUserId(out var actorUserId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(actorUserId)) return Forbid();

            var professor = await _service.GetProfessorByIdAsync(idProfessor);
            if (professor == null) return NotFound();

            professor.IsVerifiedIban = true;
            professor.IsActive = true;
            professor.IsVerified = true;
            professor.IsRejected = false;
            await _service.UpdateProfessorAsync(professor);

            // Grant role after approval.
            await _users.EnsureRoleAsync(professor.IdUser, "professor");

            return Ok(new
            {
                idProfessor = professor.IdProfessor,
                idUser = professor.IdUser,
                message = "Professor aprovado e role atribuída. O utilizador deve renovar o token para refletir a nova role."
            });
        }

        [HttpPut("professors/{idProfessor:guid}/reject")]
        public async Task<IActionResult> RejectProfessor(Guid idProfessor)
        {
            if (!TryGetAuthenticatedUserId(out var actorUserId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(actorUserId)) return Forbid();

            var professor = await _service.GetProfessorByIdAsync(idProfessor);
            if (professor == null) return NotFound();

            professor.IsVerifiedIban = false;
            professor.IsActive = false;
            professor.IsVerified = false;
            professor.IsRejected = true;
            await _service.UpdateProfessorAsync(professor);

            return Ok(new
            {
                idProfessor = professor.IdProfessor,
                idUser = professor.IdUser,
                message = "Professor rejeitado com sucesso."
            });
        }

        [HttpPost("professors")]
        public async Task<IActionResult> CreateProfessor([FromBody] Professor professor)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertProfessorAsync(professor);
            professor.IdProfessor = id;
            return CreatedAtAction(nameof(GetProfessor), new { idProfessor = id }, professor);
        }

        [HttpPut("professors/{idProfessor:guid}")]
        public async Task<IActionResult> UpdateProfessor(Guid idProfessor, [FromBody] Professor professor)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idProfessor != professor.IdProfessor) return BadRequest();
            var rows = await _service.UpdateProfessorAsync(professor);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("professors/{idProfessor:guid}")]
        public async Task<IActionResult> DeleteProfessor(Guid idProfessor)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteProfessorAsync(idProfessor);
            return rows == 0 ? NotFound() : NoContent();
        }

        // FEEDBACK
        [HttpGet("feedback")]
        public async Task<IActionResult> GetFeedback()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetProfessorFeedbackAllAsync());
        }

        [HttpGet("feedback/{idProfessorFeedback:guid}")]
        public async Task<IActionResult> GetFeedbackById(Guid idProfessorFeedback)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetProfessorFeedbackByIdAsync(idProfessorFeedback);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("feedback")]
        public async Task<IActionResult> CreateFeedback([FromBody] ProfessorFeedback feedback)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertProfessorFeedbackAsync(feedback);
            feedback.IdProfessorFeedback = id;
            return CreatedAtAction(nameof(GetFeedbackById), new { idProfessorFeedback = id }, feedback);
        }

        [HttpPut("feedback/{idProfessorFeedback:guid}")]
        public async Task<IActionResult> UpdateFeedback(Guid idProfessorFeedback, [FromBody] ProfessorFeedback feedback)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idProfessorFeedback != feedback.IdProfessorFeedback) return BadRequest();
            var rows = await _service.UpdateProfessorFeedbackAsync(feedback);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("feedback/{idProfessorFeedback:guid}")]
        public async Task<IActionResult> DeleteFeedback(Guid idProfessorFeedback)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteProfessorFeedbackAsync(idProfessorFeedback);
            return rows == 0 ? NotFound() : NoContent();
        }

        // CERTIFICATES
        [HttpGet("certificates")]
        public async Task<IActionResult> GetCertificates()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetCertificatesAllAsync());
        }

        [HttpGet("certificates/{idCertificate:guid}")]
        public async Task<IActionResult> GetCertificate(Guid idCertificate)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetCertificateByIdAsync(idCertificate);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("certificates")]
        public async Task<IActionResult> CreateCertificate([FromBody] Certificate cert)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertCertificateAsync(cert);
            cert.IdCertificate = id;
            return CreatedAtAction(nameof(GetCertificate), new { idCertificate = id }, cert);
        }

        [HttpPut("certificates/{idCertificate:guid}")]
        public async Task<IActionResult> UpdateCertificate(Guid idCertificate, [FromBody] Certificate cert)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idCertificate != cert.IdCertificate) return BadRequest();
            var rows = await _service.UpdateCertificateAsync(cert);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpPut("certificates/{idCertificate:guid}/review")]
        public async Task<IActionResult> ReviewCertificate(Guid idCertificate, [FromBody] ReviewCertificateRequest? request)
        {
            if (!TryGetAuthenticatedUserId(out var actorUserId)) return Unauthorized();
            if (!await CurrentUserIsAdminAsync(actorUserId)) return Forbid();
            if (request == null || (request.Approved == null && request.Verified == null))
            {
                return BadRequest(new { message = "Indique se o ficheiro foi aprovado e/ou verificado." });
            }

            var existing = await _service.GetCertificateByIdAsync(idCertificate);
            if (existing == null) return NotFound();

            if (request.Approved.HasValue)
            {
                existing.Approved = request.Approved.Value;
                existing.ApprovedByUserId = request.Approved.Value ? actorUserId : null;
            }

            if (request.Verified.HasValue)
            {
                existing.Verified = request.Verified.Value;
                existing.VerifiedByUserId = request.Verified.Value ? actorUserId : null;
            }

            existing.UpdatedAt = DateTime.UtcNow;

            var rows = await _service.UpdateCertificateAsync(existing);
            if (rows == 0) return NotFound();

            return Ok(existing);
        }

        [HttpDelete("certificates/{idCertificate:guid}")]
        public async Task<IActionResult> DeleteCertificate(Guid idCertificate)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var existing = await _service.GetCertificateByIdAsync(idCertificate);
            var rows = await _service.DeleteCertificateAsync(idCertificate);
            if (rows > 0)
            {
                await TryDeleteProfessorDocumentAsync(existing?.FileUrl, HttpContext.RequestAborted);
            }
            return rows == 0 ? NotFound() : NoContent();
        }

        private string? ValidateCertificateRequest(UpsertMyCertificateRequest? request, bool requiresFileReference)
        {
            if (request == null)
            {
                return "Pedido inválido.";
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                return "Indique a que se refere o documento.";
            }

            if (requiresFileReference && request.File == null && string.IsNullOrWhiteSpace(request.FileUrl))
            {
                return "Selecione um ficheiro ou indique o link do documento.";
            }

            if (request.File != null)
            {
                if (request.File.Length <= 0)
                {
                    return "O ficheiro selecionado está vazio.";
                }

                if (request.File.Length > MaxProfessorDocumentBytes)
                {
                    return "O ficheiro excede o limite de 12 MB.";
                }

                var extension = Path.GetExtension(request.File.FileName)?.Trim();
                if (string.IsNullOrWhiteSpace(extension) || !AllowedProfessorDocumentExtensions.Contains(extension))
                {
                    return "Formato de ficheiro não suportado. Use PDF, PNG, JPG, DOC ou DOCX.";
                }
            }

            var normalizedFileUrl = request.FileUrl?.Trim();
            if (!string.IsNullOrWhiteSpace(normalizedFileUrl) &&
                !IsStoredProfessorDocumentReference(normalizedFileUrl) &&
                !Uri.TryCreate(normalizedFileUrl, UriKind.Absolute, out _))
            {
                return "O link do documento é inválido.";
            }

            return null;
        }

        private async Task<string?> ResolveCertificateFileUrlAsync(UpsertMyCertificateRequest request)
        {
            if (request.File == null)
            {
                return NormalizeCertificateFileReference(request.FileUrl);
            }

            if (!string.IsNullOrWhiteSpace(_agoraLessonOptions.BaseUrl))
            {
                return await UploadProfessorDocumentAsync(request.File, HttpContext?.RequestAborted ?? default);
            }

            var folderPath = Path.Combine(_environment.ContentRootPath, "uploads", "professor-documents");
            Directory.CreateDirectory(folderPath);

            var extension = Path.GetExtension(request.File.FileName)?.Trim().ToLowerInvariant();
            var storedFileName = $"{Guid.NewGuid():N}{extension}";
            var storedPath = Path.Combine(folderPath, storedFileName);

            await using (var stream = System.IO.File.Create(storedPath))
            {
                await request.File.CopyToAsync(stream);
            }

            return storedFileName;
        }

        private async Task<string> UploadProfessorDocumentAsync(IFormFile file, CancellationToken cancellationToken)
        {
            var objectKey = BuildProfessorDocumentObjectKey(file.FileName, DateTime.UtcNow);
            var baseUrl = NormalizeBaseUrl(_agoraLessonOptions.BaseUrl);

            if (string.IsNullOrWhiteSpace(baseUrl))
            {
                throw new InvalidOperationException("O Agora Integrator não está configurado para receber documentos.");
            }

            using var request = new MultipartFormDataContent();
            await using var stream = file.OpenReadStream();
            using var fileContent = new StreamContent(stream);

            fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse(
                string.IsNullOrWhiteSpace(file.ContentType) ? "application/octet-stream" : file.ContentType);
            request.Add(fileContent, "file", file.FileName);

            using var client = _httpClientFactory.CreateClient();
            using var response = await client.PostAsync(
                $"{baseUrl}/api/files/upload?key={Uri.EscapeDataString(objectKey)}",
                request,
                cancellationToken);

            var payload = await response.Content.ReadAsStringAsync(cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                throw new InvalidOperationException(
                    $"Não foi possível guardar o documento na Cloudflare ({(int)response.StatusCode}).");
            }

            var result = JsonSerializer.Deserialize<AgoraUploadedFileResponse>(
                payload,
                new JsonSerializerOptions(JsonSerializerDefaults.Web));

            var fileUrl = result?.FileUrl?.Trim();
            if (string.IsNullOrWhiteSpace(fileUrl))
            {
                throw new InvalidOperationException("O upload do documento não devolveu um URL utilizável.");
            }

            return fileUrl;
        }

        private async Task TryDeleteProfessorDocumentAsync(string? fileUrl, CancellationToken cancellationToken)
        {
            var localPath = TryResolveLocalProfessorDocumentPath(fileUrl);
            if (localPath != null && System.IO.File.Exists(localPath))
            {
                try
                {
                    System.IO.File.Delete(localPath);
                }
                catch
                {
                }

                return;
            }

            await TryDeleteRemoteProfessorDocumentAsync(fileUrl, cancellationToken);
        }

        private async Task TryDeleteRemoteProfessorDocumentAsync(string? fileUrl, CancellationToken cancellationToken)
        {
            var objectKey = TryExtractProfessorDocumentObjectKey(fileUrl);
            if (string.IsNullOrWhiteSpace(objectKey))
            {
                return;
            }

            var r2BaseUrl = NormalizeBaseUrl(Environment.GetEnvironmentVariable("R2_INTEGRATOR_BASE_URL") ?? string.Empty);
            if (string.IsNullOrWhiteSpace(r2BaseUrl))
            {
                return;
            }

            var encodedObjectKey = string.Join(
                '/',
                objectKey
                    .Split('/', StringSplitOptions.RemoveEmptyEntries)
                    .Select(Uri.EscapeDataString));

            try
            {
                using var client = _httpClientFactory.CreateClient();
                await client.DeleteAsync($"{r2BaseUrl}/api/files/{encodedObjectKey}", cancellationToken);
            }
            catch
            {
            }
        }

        private static string BuildProfessorDocumentObjectKey(string originalFileName, DateTime createdAtUtc)
        {
            return $"professor-documents/{createdAtUtc:yyyy/MM}/{Guid.NewGuid():N}-{SlugifyFileName(originalFileName)}";
        }

        private static string SlugifyFileName(string fileName)
        {
            var extension = Path.GetExtension(fileName).ToLowerInvariant();
            var nameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);
            var normalized = nameWithoutExtension.Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder(normalized.Length);

            foreach (var character in normalized)
            {
                var category = System.Globalization.CharUnicodeInfo.GetUnicodeCategory(character);
                if (category == System.Globalization.UnicodeCategory.NonSpacingMark)
                {
                    continue;
                }

                if (char.IsLetterOrDigit(character))
                {
                    builder.Append(char.ToLowerInvariant(character));
                    continue;
                }

                builder.Append('-');
            }

            var slug = System.Text.RegularExpressions.Regex.Replace(builder.ToString(), "-+", "-").Trim('-');
            if (string.IsNullOrWhiteSpace(slug))
            {
                slug = "ficheiro";
            }

            return string.IsNullOrWhiteSpace(extension) ? slug : $"{slug}{extension}";
        }

        private static string NormalizeBaseUrl(string value)
        {
            var trimmed = value.Trim();
            if (string.IsNullOrWhiteSpace(trimmed))
            {
                return string.Empty;
            }

            return trimmed.EndsWith('/') ? trimmed[..^1] : trimmed;
        }

        private string? TryExtractProfessorDocumentObjectKey(string? fileUrl)
        {
            if (string.IsNullOrWhiteSpace(fileUrl) ||
                !Uri.TryCreate(fileUrl, UriKind.Absolute, out var storageUri))
            {
                return null;
            }

            var agoraBaseUrl = NormalizeBaseUrl(_agoraLessonOptions.BaseUrl);
            if (!string.IsNullOrWhiteSpace(agoraBaseUrl) &&
                Uri.TryCreate(agoraBaseUrl, UriKind.Absolute, out var agoraUri) &&
                string.Equals(agoraUri.Host, storageUri.Host, StringComparison.OrdinalIgnoreCase))
            {
                var basePath = agoraUri.AbsolutePath.TrimEnd('/');
                var absolutePath = storageUri.AbsolutePath;

                if (!string.IsNullOrWhiteSpace(basePath) && absolutePath.StartsWith(basePath, StringComparison.OrdinalIgnoreCase))
                {
                    return Uri.UnescapeDataString(absolutePath[basePath.Length..].TrimStart('/'));
                }
            }

            return Uri.UnescapeDataString(storageUri.AbsolutePath.TrimStart('/'));
        }

        private string? TryResolveLocalProfessorDocumentPath(string? fileUrl)
        {
            if (string.IsNullOrWhiteSpace(fileUrl)) return null;

            var normalized = NormalizeCertificateFileReference(fileUrl);
            if (!string.IsNullOrWhiteSpace(normalized))
            {
                return Path.Combine(_environment.ContentRootPath, "uploads", "professor-documents", normalized);
            }

            if (!Uri.TryCreate(fileUrl, UriKind.Absolute, out var absoluteUri))
            {
                return null;
            }

            var path = absoluteUri.AbsolutePath;
            if (!path.StartsWith("/uploads/professor-documents/", StringComparison.OrdinalIgnoreCase))
            {
                return null;
            }

            var fileName = Path.GetFileName(path);
            if (string.IsNullOrWhiteSpace(fileName)) return null;

            return Path.Combine(_environment.ContentRootPath, "uploads", "professor-documents", fileName);
        }

        private static bool IsStoredProfessorDocumentReference(string? value)
        {
            var normalized = NormalizeCertificateFileReference(value);
            return !string.IsNullOrWhiteSpace(normalized);
        }

        private static string? NormalizeCertificateFileReference(string? value)
        {
            if (string.IsNullOrWhiteSpace(value)) return null;

            var trimmed = value.Trim();
            if (trimmed.Contains("://", StringComparison.Ordinal)) return null;

            var normalized = trimmed.Replace('\\', '/');
            if (normalized.StartsWith("/uploads/professor-documents/", StringComparison.OrdinalIgnoreCase))
            {
                normalized = normalized["/uploads/professor-documents/".Length..];
            }

            normalized = Path.GetFileName(normalized);
            return string.IsNullOrWhiteSpace(normalized) ? null : normalized;
        }

        private sealed class AgoraUploadedFileResponse
        {
            public string? FileUrl { get; set; }
        }

        // ROOMS
        [HttpGet("rooms")]
        public async Task<IActionResult> GetRooms()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetProfessorRoomsAllAsync());
        }

        [HttpGet("rooms/{id:guid}")]
        public async Task<IActionResult> GetRoom(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetProfessorRoomByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("rooms")]
        public async Task<IActionResult> CreateRoom([FromBody] ProfessorRoom room)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertProfessorRoomAsync(room);
            room.Id = id;
            return CreatedAtAction(nameof(GetRoom), new { id }, room);
        }

        [HttpPut("rooms/{id:guid}")]
        public async Task<IActionResult> UpdateRoom(Guid id, [FromBody] ProfessorRoom room)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (id != room.Id) return BadRequest();
            var rows = await _service.UpdateProfessorRoomAsync(room);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("rooms/{id:guid}")]
        public async Task<IActionResult> DeleteRoom(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteProfessorRoomAsync(id);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
