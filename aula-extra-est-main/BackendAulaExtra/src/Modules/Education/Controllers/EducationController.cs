using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Education.Models;
using ConfidantPostgreSQL.Modules.Education.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Education.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class EducationController : ControllerBase
    {
        private readonly IEducationService _service;

        public EducationController(IEducationService service)
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

        private void ApplyCulture()
        {
            RequestContext.ApplyCultureFromHeader(Request);
        }

        public class SetMyDisciplinasRequest
        {
            public List<Guid>? Ids { get; set; }
        }

        // DISCIPLINAS
        [HttpGet("disciplinas")]
        public async Task<IActionResult> GetDisciplinas()
        {
            ApplyCulture();
            return Ok(await _service.GetDisciplinasAllAsync());
        }

        [AllowAnonymous]
        [HttpGet("disciplinas/public")]
        public async Task<IActionResult> GetPublicDisciplinasWithProfessors()
        {
            ApplyCulture();
            return Ok(await _service.GetPublicDisciplinasWithProfessorsAsync());
        }

        [AllowAnonymous]
        [HttpGet("areas")]
        public async Task<IActionResult> GetAreas([FromQuery] string? targetRole = null, [FromQuery(Name = "target_role")] string? targetRoleFallback = null)
        {
            ApplyCulture();
            var roleToSearch = !string.IsNullOrWhiteSpace(targetRole) ? targetRole : targetRoleFallback;
            return Ok(await _service.GetAreasAllAsync(roleToSearch));
        }

        [HttpGet("areas/{idArea:guid}")]
        public async Task<IActionResult> GetArea(Guid idArea)
        {
            ApplyCulture();
            var item = await _service.GetAreaByIdAsync(idArea);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("areas")]
        public async Task<IActionResult> CreateArea([FromBody] Area area)
        {
            ApplyCulture();
            var id = await _service.InsertAreaAsync(area);
            area.IdArea = id;
            return CreatedAtAction(nameof(GetArea), new { idArea = id }, area);
        }

        [HttpPut("areas/{idArea:guid}")]
        public async Task<IActionResult> UpdateArea(Guid idArea, [FromBody] Area area)
        {
            ApplyCulture();
            if (idArea != area.IdArea) return BadRequest();
            var rows = await _service.UpdateAreaAsync(area);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("areas/{idArea:guid}")]
        public async Task<IActionResult> DeleteArea(Guid idArea)
        {
            ApplyCulture();
            var rows = await _service.DeleteAreaAsync(idArea);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpGet("areas/{idArea:guid}/disciplinas")]
        public async Task<IActionResult> GetDisciplinasByArea(Guid idArea)
        {
            ApplyCulture();
            return Ok(await _service.GetDisciplinasByAreaIdAsync(idArea));
        }

        // MY DISCIPLINAS (authenticated user)
        // GET /api/Education/me/disciplinas
        [HttpGet("me/disciplinas")]
        public async Task<IActionResult> GetMyDisciplinas()
        {
            ApplyCulture();
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            var items = await _service.GetMyDisciplinasAsync(userId);
            return Ok(items);
        }

        // PUT /api/Education/me/disciplinas
        // Body: { ids: [guid, ...] }  (empty or null clears)
        [HttpPut("me/disciplinas")]
        public async Task<IActionResult> SetMyDisciplinas([FromBody] SetMyDisciplinasRequest request)
        {
            ApplyCulture();
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            request ??= new SetMyDisciplinasRequest();
            var ids = request.Ids?.ToArray() ?? Array.Empty<Guid>();
            var count = await _service.SetMyDisciplinasAsync(userId, ids);
            var items = await _service.GetMyDisciplinasAsync(userId);

            return Ok(new { count, disciplinas = items });
        }

        // DELETE /api/Education/me/disciplinas/{idDisciplina}
        [HttpDelete("me/disciplinas/{idDisciplina:guid}")]
        public async Task<IActionResult> RemoveMyDisciplina(Guid idDisciplina)
        {
            ApplyCulture();
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var count = await _service.RemoveMyDisciplinaAsync(userId, idDisciplina);
            var items = await _service.GetMyDisciplinasAsync(userId);
            return Ok(new { count, disciplinas = items });
        }

        // DELETE /api/Education/me/areas/{idArea}
        [HttpDelete("me/areas/{idArea:guid}")]
        public async Task<IActionResult> RemoveMyArea(Guid idArea)
        {
            ApplyCulture();
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var count = await _service.RemoveMyDisciplinasByAreaAsync(userId, idArea);
            var items = await _service.GetMyDisciplinasAsync(userId);
            return Ok(new { count, disciplinas = items });
        }

        [HttpGet("disciplinas/{idDisciplina:guid}")]
        public async Task<IActionResult> GetDisciplina(Guid idDisciplina)
        {
            ApplyCulture();
            var item = await _service.GetDisciplinaByIdAsync(idDisciplina);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("disciplinas")]
        public async Task<IActionResult> CreateDisciplina([FromBody] Disciplina disciplina)
        {
            ApplyCulture();
            var id = await _service.InsertDisciplinaAsync(disciplina);
            disciplina.IdDisciplina = id;
            return CreatedAtAction(nameof(GetDisciplina), new { idDisciplina = id }, disciplina);
        }

        [HttpPut("disciplinas/{idDisciplina:guid}")]
        public async Task<IActionResult> UpdateDisciplina(Guid idDisciplina, [FromBody] Disciplina disciplina)
        {
            ApplyCulture();
            if (idDisciplina != disciplina.IdDisciplina) return BadRequest();
            var rows = await _service.UpdateDisciplinaAsync(disciplina);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("disciplinas/{idDisciplina:guid}")]
        public async Task<IActionResult> DeleteDisciplina(Guid idDisciplina)
        {
            ApplyCulture();
            var rows = await _service.DeleteDisciplinaAsync(idDisciplina);
            return rows == 0 ? NotFound() : NoContent();
        }

        // ANOS ESCOLARIDADE
        [HttpGet("anos-escolaridade")]
        public async Task<IActionResult> GetAnosEscolaridade()
        {
            ApplyCulture();
            return Ok(await _service.GetAnosEscolaridadeAllAsync());
        }

        [HttpGet("anos-escolaridade/{idAnoEscolaridade:guid}")]
        public async Task<IActionResult> GetAnoEscolaridade(Guid idAnoEscolaridade)
        {
            ApplyCulture();
            var item = await _service.GetAnoEscolaridadeByIdAsync(idAnoEscolaridade);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("anos-escolaridade")]
        public async Task<IActionResult> CreateAnoEscolaridade([FromBody] AnoEscolaridade ano)
        {
            ApplyCulture();
            var id = await _service.InsertAnoEscolaridadeAsync(ano);
            ano.IdAnoEscolaridade = id;
            return CreatedAtAction(nameof(GetAnoEscolaridade), new { idAnoEscolaridade = id }, ano);
        }

        [HttpPut("anos-escolaridade/{idAnoEscolaridade:guid}")]
        public async Task<IActionResult> UpdateAnoEscolaridade(Guid idAnoEscolaridade, [FromBody] AnoEscolaridade ano)
        {
            ApplyCulture();
            if (idAnoEscolaridade != ano.IdAnoEscolaridade) return BadRequest();
            var rows = await _service.UpdateAnoEscolaridadeAsync(ano);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("anos-escolaridade/{idAnoEscolaridade:guid}")]
        public async Task<IActionResult> DeleteAnoEscolaridade(Guid idAnoEscolaridade)
        {
            ApplyCulture();
            var rows = await _service.DeleteAnoEscolaridadeAsync(idAnoEscolaridade);
            return rows == 0 ? NotFound() : NoContent();
        }

        // CICLOS ESTUDO
        [AllowAnonymous]
        [HttpGet("ciclos-estudo")]
        public async Task<IActionResult> GetCiclosEstudo()
        {
            ApplyCulture();
            return Ok(await _service.GetCiclosEstudoAllAsync());
        }

        [HttpGet("ciclos-estudo/{idCicloEstudo:guid}")]
        public async Task<IActionResult> GetCicloEstudo(Guid idCicloEstudo)
        {
            ApplyCulture();
            var item = await _service.GetCicloEstudoByIdAsync(idCicloEstudo);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("ciclos-estudo")]
        public async Task<IActionResult> CreateCicloEstudo([FromBody] CicloEstudo ciclo)
        {
            ApplyCulture();
            var id = await _service.InsertCicloEstudoAsync(ciclo);
            ciclo.IdCicloEstudo = id;
            return CreatedAtAction(nameof(GetCicloEstudo), new { idCicloEstudo = id }, ciclo);
        }

        [HttpPut("ciclos-estudo/{idCicloEstudo:guid}")]
        public async Task<IActionResult> UpdateCicloEstudo(Guid idCicloEstudo, [FromBody] CicloEstudo ciclo)
        {
            ApplyCulture();
            if (idCicloEstudo != ciclo.IdCicloEstudo) return BadRequest();
            var rows = await _service.UpdateCicloEstudoAsync(ciclo);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("ciclos-estudo/{idCicloEstudo:guid}")]
        public async Task<IActionResult> DeleteCicloEstudo(Guid idCicloEstudo)
        {
            ApplyCulture();
            var rows = await _service.DeleteCicloEstudoAsync(idCicloEstudo);
            return rows == 0 ? NotFound() : NoContent();
        }

        // CICLOS ESTUDO ANOS
        [HttpGet("ciclos-estudo-anos")]
        public async Task<IActionResult> GetCiclosEstudoAnos()
        {
            ApplyCulture();
            return Ok(await _service.GetCiclosEstudoAnosAllAsync());
        }

        [HttpGet("ciclos-estudo-anos/{id:guid}")]
        public async Task<IActionResult> GetCicloEstudoAno(Guid id)
        {
            ApplyCulture();
            var item = await _service.GetCicloEstudoAnoByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("ciclos-estudo-anos")]
        public async Task<IActionResult> CreateCicloEstudoAno([FromBody] CicloEstudoAno rel)
        {
            ApplyCulture();
            var id = await _service.InsertCicloEstudoAnoAsync(rel);
            rel.IdCicloEstudoAnoEscolaridade = id;
            return CreatedAtAction(nameof(GetCicloEstudoAno), new { id }, rel);
        }

        [HttpPut("ciclos-estudo-anos/{id:guid}")]
        public async Task<IActionResult> UpdateCicloEstudoAno(Guid id, [FromBody] CicloEstudoAno rel)
        {
            ApplyCulture();
            if (id != rel.IdCicloEstudoAnoEscolaridade) return BadRequest();
            var rows = await _service.UpdateCicloEstudoAnoAsync(rel);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("ciclos-estudo-anos/{id:guid}")]
        public async Task<IActionResult> DeleteCicloEstudoAno(Guid id)
        {
            ApplyCulture();
            var rows = await _service.DeleteCicloEstudoAnoAsync(id);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
