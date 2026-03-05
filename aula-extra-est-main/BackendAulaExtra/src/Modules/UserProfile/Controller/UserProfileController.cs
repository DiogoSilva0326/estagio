using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.UserProfile.Models;
using ConfidantPostgreSQL.Modules.UserProfile.Service;

namespace ConfidantPostgreSQL.Modules.UserProfile.Controller;

[ApiController]
[Route("api/[controller]")]
[AuthorizeJwt]
public class UserProfileController : ControllerBase
{
    private readonly IUserProfileService _service;

    public UserProfileController(IUserProfileService service)
    {
        _service = service;
    }

    /// <summary>
    /// Get UserProfile by user ID - auto-creates if not exists
    /// </summary>
    [HttpGet("{userId:guid}")]
    public async Task<ActionResult> GetByUserId(
        [FromRoute] Guid userId,
        [FromHeader] string? culture = "pt-PT")
    {
        RequestContext.ApplyCulture(culture);
        try
        {
            // Auto-create profile if not exists (legacy compatibility)
            var profile = await _service.GetOrCreateAsync(userId);
            return Ok(new { profile });
        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Create UserProfile
    /// </summary>
    [HttpPost]
    public async Task<ActionResult> Insert(
        [FromBody] InsertUserProfileRequest request,
        [FromHeader] string? culture = "pt-PT")
    {
        RequestContext.ApplyCulture(culture);
        try
        {
            var id = await _service.InsertAsync(request);
            var profile = await _service.GetByUserIdAsync(request.UserId);
            return Ok(new { profile });
        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Update UserProfile
    /// </summary>
    [HttpPut]
    public async Task<ActionResult> Update(
        [FromBody] UpdateUserProfileRequest request,
        [FromHeader] string? culture = "pt-PT")
    {
        RequestContext.ApplyCulture(culture);
        try
        {
            var rows = await _service.UpdateAsync(request);
            
            if (rows <= 0)
            {
                return NotFound(new { error = $"UserProfile not found for userId={request.UserId}" });
            }
            
            var profile = await _service.GetByUserIdAsync(request.UserId);
            return Ok(new { profile });
        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new { error = ex.Message });
        }
    }
}
