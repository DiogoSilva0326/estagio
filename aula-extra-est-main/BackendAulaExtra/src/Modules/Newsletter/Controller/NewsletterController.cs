using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Newsletter.Models;
using ConfidantPostgreSQL.Modules.Newsletter.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Newsletter.Controller;

[ApiController]
[Route("api/[controller]")]
[AuthorizeJwt]
public class NewsletterController : ControllerBase
{
    private readonly INewsletterService _service;
    private readonly IUserService _users;

    public NewsletterController(INewsletterService service, IUserService users)
    {
        _service = service;
        _users = users;
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

    private async Task<bool> CurrentUserIsAdminAsync(Guid userId)
    {
        if (userId == Guid.Empty) return false;

        var auth = await _users.IssueTokenAsync(userId);
        if (auth?.Roles == null) return false;

        return auth.Roles.Any(role =>
            string.Equals(role?.Trim(), "admin", StringComparison.OrdinalIgnoreCase));
    }

    private async Task<IActionResult?> RequireAdminAsync()
    {
        if (!TryGetAuthenticatedUserId(out var userId))
        {
            return Unauthorized();
        }

        if (!await CurrentUserIsAdminAsync(userId))
        {
            return Forbid();
        }

        return null;
    }

    [AllowAnonymous]
    [HttpPost("subscribe")]
    public async Task<IActionResult> Subscribe([FromBody] SubscribeRequest request, CancellationToken cancellationToken = default)
    {
        var (ok, message) = await _service.SubscribeAsync(request, cancellationToken);
        return Ok(new { success = ok, message });
    }

    [AllowAnonymous]
    [HttpPost("unsubscribe-request")]
    public async Task<IActionResult> RequestUnsubscribe([FromBody] NewsletterEmailRequest request, CancellationToken cancellationToken = default)
    {
        var (ok, message) = await _service.RequestUnsubscribeByEmailAsync(request.Email, cancellationToken);
        return Ok(new { success = ok, message });
    }

    [AllowAnonymous]
    [HttpGet("confirm")]
    public async Task<IActionResult> Confirm([FromQuery] string token, CancellationToken cancellationToken = default)
    {
        var (ok, message) = await _service.ConfirmAsync((token ?? string.Empty).Trim(), cancellationToken);
        return Ok(new { success = ok, message });
    }

    [AllowAnonymous]
    [HttpGet("unsubscribe")]
    public async Task<IActionResult> Unsubscribe([FromQuery] string token, CancellationToken cancellationToken = default)
    {
        var (ok, message) = await _service.UnsubscribeAsync((token ?? string.Empty).Trim(), cancellationToken);
        return Ok(new { success = ok, message });
    }

    [AllowAnonymous]
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
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

        var id = await _service.CreateCampaignAsync(request, cancellationToken);
        return Ok(new { id });
    }

    [HttpGet("campaigns/{id:guid}")]
    public async Task<IActionResult> GetCampaign([FromRoute] Guid id, CancellationToken cancellationToken = default)
    {
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

        var campaign = await _service.GetCampaignByIdAsync(id, cancellationToken);
        return campaign == null ? NotFound(new { error = "Campaign not found." }) : Ok(campaign);
    }

    [HttpPut("campaigns/{id:guid}")]
    public async Task<IActionResult> UpdateCampaign([FromRoute] Guid id, [FromBody] UpdateCampaignRequest request, CancellationToken cancellationToken = default)
    {
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

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
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

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
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

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
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

        var campaigns = await _service.GetCampaignsAsync(pageNumber, pageSize, cancellationToken);
        return Ok(campaigns);
    }

    [HttpGet("subscribers")]
    public async Task<IActionResult> GetSubscribers([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 100, CancellationToken cancellationToken = default)
    {
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

        var subscribers = await _service.GetSubscribersAsync(pageNumber, pageSize, cancellationToken);
        return Ok(subscribers);
    }

    [HttpGet("subscribers/count")]
    public async Task<IActionResult> GetSubscriberCount(CancellationToken cancellationToken = default)
    {
        var adminResult = await RequireAdminAsync();
        if (adminResult != null) return adminResult;

        var count = await _service.GetSubscriberCountAsync(cancellationToken);
        return Ok(new { count });
    }
}