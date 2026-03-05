using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Reservations.Models;
using ConfidantPostgreSQL.Modules.Reservations.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Reservations.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ReservationsController : ControllerBase
    {
        private readonly IReservationsService _service;

        public ReservationsController(IReservationsService service)
        {
            _service = service;
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        // RESERVATIONS
        [HttpGet]
        public async Task<IActionResult> GetAllReservations()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetReservationsAllAsync());
        }

        [HttpGet("{idReservation:guid}")]
        public async Task<IActionResult> GetReservation(Guid idReservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetReservationByIdAsync(idReservation);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> CreateReservation([FromBody] Reservation reservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertReservationAsync(reservation);
            reservation.IdReservation = id;
            return CreatedAtAction(nameof(GetReservation), new { idReservation = id }, reservation);
        }

        [HttpPut("{idReservation:guid}")]
        public async Task<IActionResult> UpdateReservation(Guid idReservation, [FromBody] Reservation reservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idReservation != reservation.IdReservation) return BadRequest();
            var rows = await _service.UpdateReservationAsync(reservation);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("{idReservation:guid}")]
        public async Task<IActionResult> DeleteReservation(Guid idReservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteReservationAsync(idReservation);
            return rows == 0 ? NotFound() : NoContent();
        }

        // EXCEPTION RULES
        [HttpGet("exception-rules")]
        public async Task<IActionResult> GetAllExceptionRules()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetExceptionRulesAllAsync());
        }

        [HttpGet("exception-rules/{idExceptionRule:guid}")]
        public async Task<IActionResult> GetExceptionRule(Guid idExceptionRule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetExceptionRuleByIdAsync(idExceptionRule);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("exception-rules")]
        public async Task<IActionResult> CreateExceptionRule([FromBody] ExceptionRule rule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertExceptionRuleAsync(rule);
            rule.IdExceptionRule = id;
            return CreatedAtAction(nameof(GetExceptionRule), new { idExceptionRule = id }, rule);
        }

        [HttpPut("exception-rules/{idExceptionRule:guid}")]
        public async Task<IActionResult> UpdateExceptionRule(Guid idExceptionRule, [FromBody] ExceptionRule rule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idExceptionRule != rule.IdExceptionRule) return BadRequest();
            var rows = await _service.UpdateExceptionRuleAsync(rule);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("exception-rules/{idExceptionRule:guid}")]
        public async Task<IActionResult> DeleteExceptionRule(Guid idExceptionRule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteExceptionRuleAsync(idExceptionRule);
            return rows == 0 ? NotFound() : NoContent();
        }

        // EXCEPTION REQUESTS
        [HttpGet("exception-requests")]
        public async Task<IActionResult> GetAllExceptionRequests()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetExceptionRequestsAllAsync());
        }

        [HttpGet("exception-requests/{idExceptionRequest:guid}")]
        public async Task<IActionResult> GetExceptionRequest(Guid idExceptionRequest)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetExceptionRequestByIdAsync(idExceptionRequest);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("exception-requests")]
        public async Task<IActionResult> CreateExceptionRequest([FromBody] ExceptionRequest request)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertExceptionRequestAsync(request);
            request.IdExceptionRequest = id;
            return CreatedAtAction(nameof(GetExceptionRequest), new { idExceptionRequest = id }, request);
        }

        [HttpPut("exception-requests/{idExceptionRequest:guid}")]
        public async Task<IActionResult> UpdateExceptionRequest(Guid idExceptionRequest, [FromBody] ExceptionRequest request)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idExceptionRequest != request.IdExceptionRequest) return BadRequest();
            var rows = await _service.UpdateExceptionRequestAsync(request);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("exception-requests/{idExceptionRequest:guid}")]
        public async Task<IActionResult> DeleteExceptionRequest(Guid idExceptionRequest)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteExceptionRequestAsync(idExceptionRequest);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
