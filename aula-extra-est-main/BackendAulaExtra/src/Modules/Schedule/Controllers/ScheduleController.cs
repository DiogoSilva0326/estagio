using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Schedule.Models;
using ConfidantPostgreSQL.Modules.Schedule.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Schedule.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ScheduleController : ControllerBase
    {
        private readonly IScheduleService _service;

        public ScheduleController(IScheduleService service)
        {
            _service = service;
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        // DAYS
        [HttpGet("days")]
        public async Task<IActionResult> GetDays()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetDaysAllAsync());
        }

        [HttpGet("days/{idDay:guid}")]
        public async Task<IActionResult> GetDay(Guid idDay)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetDayByIdAsync(idDay);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("days")]
        public async Task<IActionResult> CreateDay([FromBody] Day day)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertDayAsync(day);
            day.IdDay = id;
            return CreatedAtAction(nameof(GetDay), new { idDay = id }, day);
        }

        [HttpPut("days/{idDay:guid}")]
        public async Task<IActionResult> UpdateDay(Guid idDay, [FromBody] Day day)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idDay != day.IdDay) return BadRequest();
            var rows = await _service.UpdateDayAsync(day);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("days/{idDay:guid}")]
        public async Task<IActionResult> DeleteDay(Guid idDay)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteDayAsync(idDay);
            return rows == 0 ? NotFound() : NoContent();
        }

        // SCHEDULE BLOCKS
        [HttpGet("blocks")]
        public async Task<IActionResult> GetBlocks()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetScheduleBlocksAllAsync());
        }

        [HttpGet("blocks/{idScheduleBlock:guid}")]
        public async Task<IActionResult> GetBlock(Guid idScheduleBlock)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetScheduleBlockByIdAsync(idScheduleBlock);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("blocks")]
        public async Task<IActionResult> CreateBlock([FromBody] ScheduleBlock block)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertScheduleBlockAsync(block);
            block.IdScheduleBlock = id;
            return CreatedAtAction(nameof(GetBlock), new { idScheduleBlock = id }, block);
        }

        [HttpPut("blocks/{idScheduleBlock:guid}")]
        public async Task<IActionResult> UpdateBlock(Guid idScheduleBlock, [FromBody] ScheduleBlock block)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idScheduleBlock != block.IdScheduleBlock) return BadRequest();
            var rows = await _service.UpdateScheduleBlockAsync(block);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("blocks/{idScheduleBlock:guid}")]
        public async Task<IActionResult> DeleteBlock(Guid idScheduleBlock)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteScheduleBlockAsync(idScheduleBlock);
            return rows == 0 ? NotFound() : NoContent();
        }

        // BLOCK PARTS
        [HttpGet("block-parts")]
        public async Task<IActionResult> GetBlockParts()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetBlockPartsAllAsync());
        }

        [HttpGet("block-parts/{idBlockPart:guid}")]
        public async Task<IActionResult> GetBlockPart(Guid idBlockPart)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetBlockPartByIdAsync(idBlockPart);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("block-parts")]
        public async Task<IActionResult> CreateBlockPart([FromBody] BlockPart part)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertBlockPartAsync(part);
            part.IdBlockPart = id;
            return CreatedAtAction(nameof(GetBlockPart), new { idBlockPart = id }, part);
        }

        [HttpPut("block-parts/{idBlockPart:guid}")]
        public async Task<IActionResult> UpdateBlockPart(Guid idBlockPart, [FromBody] BlockPart part)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idBlockPart != part.IdBlockPart) return BadRequest();
            var rows = await _service.UpdateBlockPartAsync(part);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("block-parts/{idBlockPart:guid}")]
        public async Task<IActionResult> DeleteBlockPart(Guid idBlockPart)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteBlockPartAsync(idBlockPart);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
