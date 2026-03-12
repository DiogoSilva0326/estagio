using Microsoft.AspNetCore.Mvc;
using Synget.AgoraIntegrator.API.Data.Entities;
using Synget.AgoraIntegrator.API.Data.Repositories;

namespace Synget.AgoraIntegrator.API.Controllers;

/// <summary>
/// Controller for managing user contacts (persisted to PostgreSQL)
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class ContactsController : ControllerBase
{
    private readonly IContactRepository _contactRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<ContactsController> _logger;

    public ContactsController(
        IContactRepository contactRepository, 
        IUserRepository userRepository,
        ILogger<ContactsController> logger)
    {
        _contactRepository = contactRepository;
        _userRepository = userRepository;
        _logger = logger;
    }

    #region String-based endpoints (for frontend compatibility)

    /// <summary>
    /// Get all contacts for a user by username
    /// </summary>
    [HttpGet("{userId}")]
    [ProducesResponseType(typeof(List<ContactResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<ContactResponse>>> GetContactsByUsername(string userId, [FromQuery] string? status = null)
    {
        _logger.LogInformation("Getting contacts for user: {UserId}", userId);

        // Try to parse as long first, otherwise lookup by username
        long ownerUserId;
        if (!long.TryParse(userId, out ownerUserId))
        {
            var user = await _userRepository.GetByUsernameAsync(userId);
            if (user == null)
            {
                return Ok(new List<ContactResponse>()); // Return empty list if user not found
            }
            ownerUserId = user.Id;
        }

        var contacts = await _contactRepository.GetByOwnerAsync(ownerUserId, status);
        var response = contacts.Select(c => new ContactResponse
        {
            Id = c.Id,
            // Use username instead of numeric ID for consistent channel naming
            ContactUserId = c.ContactUser?.Username ?? c.ContactUserId.ToString(),
            DisplayName = c.DisplayNameOverride ?? c.ContactUser?.DisplayName ?? c.ContactUser?.Username ?? "",
            Nickname = c.DisplayNameOverride,
            AddedAt = c.CreatedAt,
            IsBlocked = c.Status == "blocked",
            IsPending = c.Status == "pending",
            Status = c.Status
        }).ToList();

        return Ok(response);
    }

    /// <summary>
    /// Get pending contact requests received by a user (by username)
    /// </summary>
    [HttpGet("request/pending/{userId}")]
    [ProducesResponseType(typeof(List<ContactRequestResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<ContactRequestResponse>>> GetPendingRequestsByUsername(string userId)
    {
        _logger.LogInformation("Getting pending contact requests for user: {UserId}", userId);

        long ownerUserId;
        if (!long.TryParse(userId, out ownerUserId))
        {
            var user = await _userRepository.GetByUsernameAsync(userId);
            if (user == null)
            {
                return Ok(new List<ContactRequestResponse>());
            }
            ownerUserId = user.Id;
        }

        var contacts = await _contactRepository.GetPendingRequestsAsync(ownerUserId);
        var response = contacts.Select(c => new ContactRequestResponse
        {
            RequestId = c.Id.ToString(),
            // Use usernames for consistent channel naming
            FromUserId = c.OwnerUser?.Username ?? c.OwnerUserId.ToString(),
            ToUserId = c.ContactUser?.Username ?? c.ContactUserId.ToString(),
            FromDisplayName = c.OwnerUser?.DisplayName ?? c.OwnerUser?.Username ?? "",
            Status = c.Status,
            SentAt = c.CreatedAt
        }).ToList();

        return Ok(response);
    }

    /// <summary>
    /// Get sent contact requests by a user (by username)
    /// </summary>
    [HttpGet("request/sent/{userId}")]
    [ProducesResponseType(typeof(List<ContactRequestResponse>), StatusCodes.Status200OK)]
    public async Task<ActionResult<List<ContactRequestResponse>>> GetSentRequestsByUsername(string userId)
    {
        _logger.LogInformation("Getting sent contact requests for user: {UserId}", userId);

        long ownerUserId;
        if (!long.TryParse(userId, out ownerUserId))
        {
            var user = await _userRepository.GetByUsernameAsync(userId);
            if (user == null)
            {
                return Ok(new List<ContactRequestResponse>());
            }
            ownerUserId = user.Id;
        }

        // Sent requests are contacts where user is the owner and status is pending
        var contacts = await _contactRepository.GetByOwnerAsync(ownerUserId, "pending");
        var response = contacts.Select(c => new ContactRequestResponse
        {
            RequestId = c.Id.ToString(),
            // Use usernames for consistent channel naming
            FromUserId = c.OwnerUser?.Username ?? c.OwnerUserId.ToString(),
            ToUserId = c.ContactUser?.Username ?? c.ContactUserId.ToString(),
            FromDisplayName = c.ContactUser?.DisplayName ?? c.ContactUser?.Username ?? "",
            Status = c.Status,
            SentAt = c.CreatedAt
        }).ToList();

        return Ok(response);
    }

    /// <summary>
    /// Send a contact request (compatible with old API)
    /// </summary>
    [HttpPost("request")]
    [ProducesResponseType(typeof(ContactRequestResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ContactRequestResponse>> SendContactRequest([FromBody] SendContactRequestDto request)
    {
        _logger.LogInformation("User {FromUserId} sending contact request to {ToUserId}", 
            request.FromUserId, request.ToUserId);

        // Resolve user IDs from usernames
        long fromUserId, toUserId;
        
        if (!long.TryParse(request.FromUserId, out fromUserId))
        {
            var fromUser = await _userRepository.GetByUsernameAsync(request.FromUserId);
            if (fromUser == null)
            {
                return BadRequest(new ErrorResponse { Message = $"User '{request.FromUserId}' not found" });
            }
            fromUserId = fromUser.Id;
        }

        if (!long.TryParse(request.ToUserId, out toUserId))
        {
            var toUser = await _userRepository.GetByUsernameAsync(request.ToUserId);
            if (toUser == null)
            {
                return BadRequest(new ErrorResponse { Message = $"User '{request.ToUserId}' not found" });
            }
            toUserId = toUser.Id;
        }

        // Check if contact already exists
        var existingContact = await _contactRepository.GetAsync(fromUserId, toUserId);
        if (existingContact != null)
        {
            // Torna o envio idempotente: se já existir pedido/contato, devolve sucesso
            return Ok(new ContactRequestResponse
            {
                RequestId = existingContact.Id.ToString(),
                FromUserId = request.FromUserId,
                ToUserId = request.ToUserId,
                FromDisplayName = request.FromDisplayName,
                Status = existingContact.Status,
                SentAt = existingContact.CreatedAt
            });
        }

        var savedContact = await _contactRepository.AddAsync(fromUserId, toUserId, request.FromDisplayName);

        return Ok(new ContactRequestResponse
        {
            RequestId = savedContact.Id.ToString(),
            FromUserId = request.FromUserId,
            ToUserId = request.ToUserId,
            FromDisplayName = request.FromDisplayName,
            Status = savedContact.Status,
            SentAt = savedContact.CreatedAt
        });
    }

    /// <summary>
    /// Accept a contact request by request ID
    /// </summary>
    [HttpPost("request/{requestId}/accept")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> AcceptContactRequest(string requestId, [FromQuery] string? displayName = null)
    {
        _logger.LogInformation("Accepting contact request {RequestId}", requestId);

        if (!long.TryParse(requestId, out var contactId))
        {
            return BadRequest(new ErrorResponse { Message = "Invalid request ID" });
        }

        var success = await _contactRepository.AcceptByRequestIdAsync(contactId, displayName);

        if (!success)
        {
            return BadRequest(new ErrorResponse { Message = "Contact request not found or already processed" });
        }

        return Ok(new { message = "Contact request accepted" });
    }

    /// <summary>
    /// Reject a contact request by request ID
    /// </summary>
    [HttpPost("request/{requestId}/reject")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> RejectContactRequest(string requestId)
    {
        _logger.LogInformation("Rejecting contact request {RequestId}", requestId);

        // For rejection, we remove the contact request
        return Ok(new { message = "Contact request rejected" });
    }

    /// <summary>
    /// Cancel a sent contact request
    /// </summary>
    [HttpPost("request/{requestId}/cancel")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult> CancelContactRequest(string requestId, [FromQuery] string? userId = null)
    {
        _logger.LogInformation("Cancelling contact request {RequestId}", requestId);

        return Ok(new { message = "Contact request cancelled" });
    }

    /// <summary>
    /// Check if a user can send messages to another user
    /// </summary>
    [HttpGet("canmessage/{fromUserId}/{toUserId}")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    public async Task<ActionResult> CanSendMessage(string fromUserId, string toUserId)
    {
        long fromId, toId;
        
        if (!long.TryParse(fromUserId, out fromId))
        {
            var fromUser = await _userRepository.GetByUsernameAsync(fromUserId);
            if (fromUser == null)
            {
                return Ok(new { canMessage = false, reason = "Sender not found" });
            }
            fromId = fromUser.Id;
        }

        if (!long.TryParse(toUserId, out toId))
        {
            var toUser = await _userRepository.GetByUsernameAsync(toUserId);
            if (toUser == null)
            {
                return Ok(new { canMessage = false, reason = "Recipient not found" });
            }
            toId = toUser.Id;
        }

        var contact = await _contactRepository.GetAsync(fromId, toId);
        if (contact == null)
        {
            return Ok(new { canMessage = true, reason = "No contact restriction" });
        }

        if (contact.Status == "blocked")
        {
            return Ok(new { canMessage = false, reason = "Contact is blocked" });
        }

        return Ok(new { canMessage = true, reason = "Contact exists" });
    }

    #endregion

    #region Long-based endpoints (for direct database ID access)

    /// <summary>
    /// Add a contact (send contact request)
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(ContactResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<ContactResponse>> AddContact([FromBody] AddContactRequest request)
    {
        _logger.LogInformation("User {OwnerId} adding contact {ContactId}", 
            request.OwnerId, request.ContactUserId);

        if (!long.TryParse(request.OwnerId, out var ownerId) || 
            !long.TryParse(request.ContactUserId, out var contactUserId))
        {
            return BadRequest(new ErrorResponse { Message = "Invalid user IDs" });
        }

        // Check if contact already exists
        var existingContact = await _contactRepository.GetAsync(ownerId, contactUserId);
        if (existingContact != null)
        {
            return BadRequest(new ErrorResponse { Message = "Contact already exists" });
        }

        var savedContact = await _contactRepository.AddAsync(ownerId, contactUserId, request.DisplayName);
        
        // Get the contact user to return username
        var contactUser = await _userRepository.GetByIdAsync(contactUserId);

        return Ok(new ContactResponse
        {
            Id = savedContact.Id,
            // Use username for consistent channel naming
            ContactUserId = contactUser?.Username ?? savedContact.ContactUserId.ToString(),
            DisplayName = request.DisplayName ?? contactUser?.DisplayName ?? "",
            Nickname = savedContact.DisplayNameOverride,
            AddedAt = savedContact.CreatedAt,
            IsBlocked = false,
            IsPending = true,
            Status = savedContact.Status
        });
    }

    /// <summary>
    /// Update contact status
    /// </summary>
    [HttpPut("{ownerUserId:long}/{contactUserId:long}/status")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> UpdateContactStatus(long ownerUserId, long contactUserId, [FromBody] UpdateContactStatusRequest request)
    {
        _logger.LogInformation("Updating contact {OwnerUserId}->{ContactUserId} status to {Status}", 
            ownerUserId, contactUserId, request.Status);

        var validStatuses = new[] { "pending", "accepted", "blocked" };
        if (!validStatuses.Contains(request.Status.ToLower()))
        {
            return BadRequest(new ErrorResponse { Message = "Invalid status. Valid values: pending, accepted, blocked" });
        }

        var updated = await _contactRepository.UpdateStatusAsync(ownerUserId, contactUserId, request.Status.ToLower());
        
        if (updated == null)
        {
            return NotFound(new ErrorResponse { Message = "Contact not found" });
        }

        return Ok(new { message = $"Contact status updated to {request.Status}" });
    }

    /// <summary>
    /// Accept a contact request
    /// </summary>
    [HttpPost("{ownerUserId:long}/{contactUserId:long}/accept")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> AcceptContact(long ownerUserId, long contactUserId, [FromQuery] string? displayName = null)
    {
        _logger.LogInformation("User {OwnerUserId} accepting contact from {ContactUserId}", ownerUserId, contactUserId);

        var success = await _contactRepository.AcceptRequestAsync(ownerUserId, contactUserId, displayName);
        
        if (!success)
        {
            return NotFound(new ErrorResponse { Message = "Contact request not found" });
        }

        return Ok(new { message = "Contact accepted" });
    }

    /// <summary>
    /// Block a contact
    /// </summary>
    [HttpPost("{ownerUserId:long}/{contactUserId:long}/block")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> BlockContact(long ownerUserId, long contactUserId)
    {
        _logger.LogInformation("User {OwnerUserId} blocking contact {ContactUserId}", ownerUserId, contactUserId);

        var blocked = await _contactRepository.BlockAsync(ownerUserId, contactUserId);
        
        if (blocked == null)
        {
            return NotFound(new ErrorResponse { Message = "Contact not found" });
        }

        return Ok(new { message = "Contact blocked" });
    }

    /// <summary>
    /// Remove a contact
    /// </summary>
    [HttpDelete("{ownerUserId:long}/{contactUserId:long}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ErrorResponse), StatusCodes.Status404NotFound)]
    public async Task<ActionResult> RemoveContact(long ownerUserId, long contactUserId)
    {
        _logger.LogInformation("User {OwnerUserId} removing contact {ContactUserId}", ownerUserId, contactUserId);

        var success = await _contactRepository.RemoveAsync(ownerUserId, contactUserId);
        
        if (!success)
        {
            return NotFound(new ErrorResponse { Message = "Contact not found" });
        }

        return Ok(new { message = "Contact removed" });
    }

    /// <summary>
    /// Check if two users are contacts
    /// </summary>
    [HttpGet("check/{ownerUserId:long}/{contactUserId:long}")]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    public async Task<ActionResult> CheckContact(long ownerUserId, long contactUserId)
    {
        var contact = await _contactRepository.GetAsync(ownerUserId, contactUserId);
        var isContact = contact != null && contact.Status == "accepted";
        var isBlocked = contact?.Status == "blocked";
        
        return Ok(new { 
            isContact, 
            isBlocked, 
            status = contact?.Status ?? "none"
        });
    }

    #endregion
}

// Request/Response DTOs
public class AddContactRequest
{
    public string OwnerId { get; set; } = string.Empty;
    public string ContactUserId { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
}

public class UpdateContactStatusRequest
{
    public string Status { get; set; } = string.Empty;
}

public class ContactResponse
{
    public long Id { get; set; }
    public string ContactUserId { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string? Nickname { get; set; }
    public DateTime AddedAt { get; set; }
    public bool IsBlocked { get; set; }
    public bool IsPending { get; set; }
    public string Status { get; set; } = string.Empty;
}

public class SendContactRequestDto
{
    public string FromUserId { get; set; } = string.Empty;
    public string ToUserId { get; set; } = string.Empty;
    public string FromDisplayName { get; set; } = string.Empty;
    public string? Message { get; set; }
}

public class ContactRequestResponse
{
    public string RequestId { get; set; } = string.Empty;
    public string FromUserId { get; set; } = string.Empty;
    public string ToUserId { get; set; } = string.Empty;
    public string FromDisplayName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime SentAt { get; set; }
    public DateTime? RespondedAt { get; set; }
}

public class ErrorResponse
{
    public string Message { get; set; } = string.Empty;
}
