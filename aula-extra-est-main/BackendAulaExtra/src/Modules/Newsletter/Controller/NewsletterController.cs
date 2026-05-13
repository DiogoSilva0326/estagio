using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Newsletter.Models;
using ConfidantPostgreSQL.Modules.Newsletter.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Newsletter.Controller;

[ApiController]
[Route("api/[controller]")]
public class NewsletterController : ControllerBase
{
    private readonly INewsletterService _service;

    public NewsletterController(INewsletterService service)
    {
        _service = service;
    }

    [HttpPost("subscribe")]
    public async Task<IActionResult> Subscribe([FromBody] SubscribeRequest request, CancellationToken cancellationToken = default)
    {
        var (ok, message) = await _service.SubscribeAsync(request, cancellationToken);
        return Ok(new { success = ok, message });
    }

    [HttpGet("confirm")]
    public async Task<IActionResult> Confirm([FromQuery] string token, CancellationToken cancellationToken = default)
    {
        var (ok, message) = await _service.ConfirmAsync((token ?? string.Empty).Trim(), cancellationToken);
        return Ok(new { success = ok, message });
    }

    [HttpGet("unsubscribe")]
    public async Task<IActionResult> Unsubscribe([FromQuery] string token, CancellationToken cancellationToken = default)
    {
        var (ok, message) = await _service.UnsubscribeAsync((token ?? string.Empty).Trim(), cancellationToken);
        return Ok(new { success = ok, message });
    }

    [HttpPost("webhook/bounce")]
    public async Task<IActionResult> BounceWebhook([FromBody] dynamic payload, CancellationToken cancellationToken = default)
    {
        try
        {
            var email = (string?)payload?.Email;
            if (!string.IsNullOrWhiteSpace(email))
            {
                await _service.HandleBounceAsync(email, cancellationToken);
            }
        }
        catch
        {
        }

        return Ok();
    }

    [HttpPost("campaigns")]
    public async Task<IActionResult> CreateCampaign([FromBody] CreateCampaignRequest request, CancellationToken cancellationToken = default)
    {
        var id = await _service.CreateCampaignAsync(request, cancellationToken);
        return Ok(new { id });
    }

    [HttpGet("campaigns/{id:guid}")]
    public async Task<IActionResult> GetCampaign([FromRoute] Guid id, CancellationToken cancellationToken = default)
    {
        var campaign = await _service.GetCampaignByIdAsync(id, cancellationToken);
        return campaign == null ? NotFound(new { error = "Campaign not found." }) : Ok(campaign);
    }

    [HttpPut("campaigns/{id:guid}")]
    public async Task<IActionResult> UpdateCampaign([FromRoute] Guid id, [FromBody] UpdateCampaignRequest request, CancellationToken cancellationToken = default)
    {
        try
        {
            await _service.UpdateCampaignAsync(id, request, cancellationToken);
            return Ok();
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { error = "Campaign not found." });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpDelete("campaigns/{id:guid}")]
    public async Task<IActionResult> DeleteCampaign([FromRoute] Guid id, CancellationToken cancellationToken = default)
    {
        try
        {
            await _service.DeleteCampaignAsync(id, cancellationToken);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { error = "Campaign not found." });
        }
    }

    [HttpPost("campaigns/{id:guid}/send")]
    public async Task<IActionResult> SendCampaign([FromRoute] Guid id, CancellationToken cancellationToken = default)
    {
        try
        {
            var (sent, failed) = await _service.SendCampaignAsync(id, cancellationToken);
            return Ok(new { sent, failed });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { error = "Campaign not found." });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("campaigns")]
    public async Task<IActionResult> GetCampaigns([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20, CancellationToken cancellationToken = default)
    {
        var campaigns = await _service.GetCampaignsAsync(pageNumber, pageSize, cancellationToken);
        return Ok(campaigns);
    }

    [HttpGet("subscribers/count")]
    public async Task<IActionResult> GetSubscriberCount(CancellationToken cancellationToken = default)
    {
        var count = await _service.GetSubscriberCountAsync(cancellationToken);
        return Ok(new { count });
    }
}