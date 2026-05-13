using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Complaints.Models;
using ConfidantPostgreSQL.Modules.Complaints.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Complaints.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ComplaintsController : ControllerBase
    {
        private readonly IComplaintsService _service;

        public ComplaintsController(IComplaintsService service)
        {
            _service = service;
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

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        [HttpGet]
        public async Task<IActionResult> GetComplaints()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetComplaintsAllAsync());
        }

        [HttpGet("{idComplaint:guid}")]
        public async Task<IActionResult> GetComplaint(Guid idComplaint)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetComplaintByIdAsync(idComplaint);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> CreateComplaint([FromBody] Complaint complaint)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertComplaintAsync(complaint);
            complaint.IdComplaint = id;
            return CreatedAtAction(nameof(GetComplaint), new { idComplaint = id }, complaint);
        }

        [HttpPost("me/related-user")]
        public async Task<IActionResult> CreateComplaintAgainstRelatedUser([FromBody] CreateRelatedComplaintRequest request)
        {
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            try
            {
                var complaint = await _service.CreateComplaintAgainstRelatedUserAsync(userId, request);
                return CreatedAtAction(nameof(GetComplaint), new { idComplaint = complaint.IdComplaint }, complaint);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPut("{idComplaint:guid}")]
        public async Task<IActionResult> UpdateComplaint(Guid idComplaint, [FromBody] Complaint complaint)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idComplaint != complaint.IdComplaint) return BadRequest();
            var rows = await _service.UpdateComplaintAsync(complaint);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpPost("{idComplaint:guid}/reply")]
        public async Task<IActionResult> ReplyToComplaint(Guid idComplaint, [FromBody] ReplyToComplaintRequest request)
        {
            if (request == null)
            {
                return BadRequest(new { message = "Pedido inválido." });
            }

            if (!TryGetAuthenticatedUserId(out var responderUserId))
            {
                return Unauthorized();
            }

            try
            {
                var updated = await _service.ReplyToComplaintAsync(
                    idComplaint,
                    responderUserId,
                    request.ResponseMessage,
                    request.Status);
                return updated ? NoContent() : NotFound();
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{idComplaint:guid}")]
        public async Task<IActionResult> DeleteComplaint(Guid idComplaint)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteComplaintAsync(idComplaint);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpGet("resolutions")]
        public async Task<IActionResult> GetResolutions()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetComplaintResolutionsAllAsync());
        }

        [HttpGet("resolutions/{idComplaintResolution:guid}")]
        public async Task<IActionResult> GetResolution(Guid idComplaintResolution)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetComplaintResolutionByIdAsync(idComplaintResolution);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("resolutions")]
        public async Task<IActionResult> CreateResolution([FromBody] ComplaintResolution resolution)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertComplaintResolutionAsync(resolution);
            resolution.IdComplaintResolution = id;
            return CreatedAtAction(nameof(GetResolution), new { idComplaintResolution = id }, resolution);
        }

        [HttpPut("resolutions/{idComplaintResolution:guid}")]
        public async Task<IActionResult> UpdateResolution(Guid idComplaintResolution, [FromBody] ComplaintResolution resolution)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idComplaintResolution != resolution.IdComplaintResolution) return BadRequest();
            var rows = await _service.UpdateComplaintResolutionAsync(resolution);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("resolutions/{idComplaintResolution:guid}")]
        public async Task<IActionResult> DeleteResolution(Guid idComplaintResolution)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteComplaintResolutionAsync(idComplaintResolution);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
