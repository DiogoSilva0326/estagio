using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.SystemSettings.Models;
using ConfidantPostgreSQL.Modules.SystemSettings.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.SystemSettings.Controller;

[ApiController]
[Route("api/[controller]")]
public class SystemSettingsController : ControllerBase
{
    private readonly ISystemSettingsService _service;

    public SystemSettingsController(ISystemSettingsService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<SystemSetting>>> Get(
        [FromQuery] string? orderColumn = "settings_key",
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken cancellationToken = default)
    {
        var settings = await _service.GetSummaryAsync(orderColumn ?? string.Empty, pageNumber, pageSize, cancellationToken);
        return Ok(settings);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<SystemSetting>> GetById(Guid id, CancellationToken cancellationToken = default)
    {
        var setting = await _service.GetByIdAsync(id, cancellationToken);
        return setting == null ? NotFound() : Ok(setting);
    }

    [HttpGet("search")]
    public async Task<ActionResult<IEnumerable<SystemSetting>>> Search(
        [FromQuery] string search,
        [FromQuery] string? orderColumn = "settings_key",
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken cancellationToken = default)
    {
        var result = await _service.SearchAsync(search, orderColumn ?? string.Empty, pageNumber, pageSize, cancellationToken);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<Guid>> Insert([FromBody] InsertSystemSettingRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            var id = await _service.InsertAsync(request, cancellationToken);
            return CreatedAtAction(nameof(GetById), new { id }, id);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPut]
    public async Task<ActionResult<SystemSetting>> Update([FromBody] UpdateSystemSettingRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            var setting = await _service.UpdateAsync(request, cancellationToken);
            return setting == null ? NotFound() : Ok(setting);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> Delete(Guid id, CancellationToken cancellationToken = default)
    {
        var rows = await _service.DeleteAsync(id, cancellationToken);
        return rows <= 0 ? NotFound() : NoContent();
    }
}