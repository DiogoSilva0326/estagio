using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Professors.Models;
using ConfidantPostgreSQL.Modules.Professors.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Professors.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ProfessorsController : ControllerBase
    {
        private readonly IProfessorsService _service;
        private readonly IUserService _users;

        public ProfessorsController(IProfessorsService service, IUserService users)
        {
            _service = service;
            _users = users;
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
            public string? FileUrl { get; set; }
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
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

        // PROFESSORS
        [HttpGet("professors")]
        public async Task<IActionResult> GetProfessors()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetProfessorsAllAsync());
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
                CurrentSchool = string.IsNullOrWhiteSpace(request.CurrentSchool) ? existing?.CurrentSchool : request.CurrentSchool?.Trim(),
                YearsExperience = request.YearsExperience ?? existing?.YearsExperience,
                Photo = string.IsNullOrWhiteSpace(request.Photo) ? existing?.Photo : request.Photo?.Trim(),
                Biography = string.IsNullOrWhiteSpace(request.Biography) ? existing?.Biography : request.Biography?.Trim(),
                PresentationVideoUrl = string.IsNullOrWhiteSpace(request.PresentationVideoUrl) ? existing?.PresentationVideoUrl : request.PresentationVideoUrl?.Trim(),
                Vat = string.IsNullOrWhiteSpace(request.Vat) ? existing?.Vat : request.Vat?.Trim(),
                Iban = string.IsNullOrWhiteSpace(request.Iban) ? existing?.Iban : request.Iban?.Trim(),
                IbanDocumentUrl = string.IsNullOrWhiteSpace(request.IbanDocumentUrl) ? existing?.IbanDocumentUrl : request.IbanDocumentUrl?.Trim(),
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
        [AuthorizeJwt]
        public async Task<IActionResult> GetStudents()
        {
            if (!TryGetAuthenticatedUserId(out var userId)) 
                return Unauthorized();
                
            var students = await _service.GetAlunosByProfessorIdAsync(userId);
            return Ok(students);
        }

        [HttpGet("professors/{idProfessor:guid}")]
        public async Task<IActionResult> GetProfessor(Guid idProfessor)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetProfessorByIdAsync(idProfessor);
            return item == null ? NotFound() : Ok(item);
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

        [HttpDelete("certificates/{idCertificate:guid}")]
        public async Task<IActionResult> DeleteCertificate(Guid idCertificate)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteCertificateAsync(idCertificate);
            return rows == 0 ? NotFound() : NoContent();
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
