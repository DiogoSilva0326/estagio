using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.AgoraAPI.Models;
using ConfidantPostgreSQL.Modules.AgoraAPI.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.AgoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class AgoraApiController : ControllerBase
    {
        private readonly IAgoraService _service;

        public AgoraApiController(IAgoraService service)
        {
            _service = service;
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        // VIDEO CALLS
        [HttpGet("calls")]
        public async Task<IActionResult> GetCalls()
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetCallsAllAsync());
        }

        [HttpGet("calls/{id:guid}")]
        public async Task<IActionResult> GetCall(Guid id)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetCallByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("calls")]
        public async Task<IActionResult> CreateCall([FromBody] VideoCall call)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertCallAsync(call);
            call.Id = id;
            return CreatedAtAction(nameof(GetCall), new { id }, call);
        }

        [HttpPut("calls/{id:guid}")]
        public async Task<IActionResult> UpdateCall(Guid id, [FromBody] VideoCall call)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (id != call.Id) return BadRequest();
            var rows = await _service.UpdateCallAsync(call);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("calls/{id:guid}")]
        public async Task<IActionResult> DeleteCall(Guid id)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteCallAsync(id);
            return rows == 0 ? NotFound() : NoContent();
        }

        // PARTICIPANTS
        [HttpGet("participants")]
        public async Task<IActionResult> GetParticipants()
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetParticipantsAllAsync());
        }

        [HttpGet("participants/{id:guid}")]
        public async Task<IActionResult> GetParticipant(Guid id)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetParticipantByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("participants")]
        public async Task<IActionResult> CreateParticipant([FromBody] VideoCallParticipant participant)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertParticipantAsync(participant);
            participant.Id = id;
            return CreatedAtAction(nameof(GetParticipant), new { id }, participant);
        }

        [HttpPut("participants/{id:guid}")]
        public async Task<IActionResult> UpdateParticipant(Guid id, [FromBody] VideoCallParticipant participant)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (id != participant.Id) return BadRequest();
            var rows = await _service.UpdateParticipantAsync(participant);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("participants/{id:guid}")]
        public async Task<IActionResult> DeleteParticipant(Guid id)
        {
            if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteParticipantAsync(id);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
