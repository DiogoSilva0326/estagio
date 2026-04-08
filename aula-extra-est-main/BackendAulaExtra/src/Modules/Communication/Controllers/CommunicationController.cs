using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Communication.DTOs;
using ConfidantPostgreSQL.Modules.Communication.Models;
using ConfidantPostgreSQL.Modules.Communication.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Communication.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class CommunicationController : ControllerBase
    {
        private readonly ICommunicationService _service;
        private readonly IUserService _userService;

        public CommunicationController(ICommunicationService service, IUserService userService)
        {
            _service = service;
            _userService = userService;
        }

        private bool TryGetCurrentUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext.Items.TryGetValue("UserId", out var val) && val is Guid guid && guid != Guid.Empty)
            {
                userId = guid;
                return true;
            }
            return false;
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        // NOTIFICATIONS
        [HttpGet("notifications")]
        public async Task<IActionResult> GetNotifications()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetNotificationsAllAsync());
        }

        [HttpGet("notifications/{idNotification:guid}")]
        public async Task<IActionResult> GetNotification(Guid idNotification)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetNotificationByIdAsync(idNotification);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("notifications")]
        public async Task<IActionResult> CreateNotification([FromBody] Notification notification)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertNotificationAsync(notification);
            notification.IdNotification = id;
            return CreatedAtAction(nameof(GetNotification), new { idNotification = id }, notification);
        }

        [HttpPut("notifications/{idNotification:guid}")]
        public async Task<IActionResult> UpdateNotification(Guid idNotification, [FromBody] Notification notification)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idNotification != notification.IdNotification) return BadRequest();
            var rows = await _service.UpdateNotificationAsync(notification);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("notifications/{idNotification:guid}")]
        public async Task<IActionResult> DeleteNotification(Guid idNotification)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteNotificationAsync(idNotification);
            return rows == 0 ? NotFound() : NoContent();
        }

        // MESSAGES
        [HttpGet("messages")]
        public async Task<IActionResult> GetMessages()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetMessagesAllAsync());
        }

        [HttpGet("messages/{idMessage:guid}")]
        public async Task<IActionResult> GetMessage(Guid idMessage)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetMessageByIdAsync(idMessage);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("messages")]
        public async Task<IActionResult> CreateMessage([FromBody] Message message)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertMessageAsync(message);
            message.IdMessage = id;
            return CreatedAtAction(nameof(GetMessage), new { idMessage = id }, message);
        }

        [HttpPut("messages/{idMessage:guid}")]
        public async Task<IActionResult> UpdateMessage(Guid idMessage, [FromBody] Message message)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idMessage != message.IdMessage) return BadRequest();
            var rows = await _service.UpdateMessageAsync(message);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("messages/{idMessage:guid}")]
        public async Task<IActionResult> DeleteMessage(Guid idMessage)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteMessageAsync(idMessage);
            return rows == 0 ? NotFound() : NoContent();
        }

        // CONTACTS
        [HttpGet("contacts")]
        public async Task<IActionResult> GetContacts()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetContactsAllAsync());
        }

        [HttpGet("contacts/me")]
        public async Task<IActionResult> GetMyContacts()
        {
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized(new { error = "token_invalid" });
            return Ok(await _service.GetContactUserSummariesByOwnerAsync(userId));
        }

        [HttpPost("contacts/by-username")]
        public async Task<IActionResult> AddContactByUsername([FromBody] AddContactByUsernameRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Username)) return BadRequest();

            if (!TryGetCurrentUserId(out var ownerUserId)) return Unauthorized(new { error = "token_invalid" });
            var target = await _userService.GetByUsernameAsync(request.Username.Trim());
            if (target?.Id == null || target.Id.Value == Guid.Empty) return NotFound(new { error = "user_not_found" });
            if (target.Id.Value == ownerUserId) return BadRequest(new { error = "cannot_add_self" });

            var targetUserId = target.Id.Value;

            // If the relationship already exists, avoid flipping accepted back to pending.
            var existingOwnerToTarget = await _service.GetContactByOwnerAndContactAsync(ownerUserId, targetUserId);
            if (existingOwnerToTarget != null && string.Equals(existingOwnerToTarget.Status, "accepted", StringComparison.OrdinalIgnoreCase))
            {
                return Ok(await _service.GetContactUserSummariesByOwnerAsync(ownerUserId));
            }

            // If I already have a pending invite from the target, treat this as accepting it.
            if (existingOwnerToTarget != null && string.Equals(existingOwnerToTarget.Status, "pending", StringComparison.OrdinalIgnoreCase))
            {
                await _service.UpsertContactAsync(new Contact
                {
                    OwnerUserId = ownerUserId,
                    ContactUserId = targetUserId,
                    Status = "accepted"
                });
                await _service.UpsertContactAsync(new Contact
                {
                    OwnerUserId = targetUserId,
                    ContactUserId = ownerUserId,
                    Status = "accepted"
                });

                return Ok(await _service.GetContactUserSummariesByOwnerAsync(ownerUserId));
            }

            // Create an invite: requester sees 'requested', receiver sees 'pending'.
            await _service.UpsertContactAsync(new Contact
            {
                OwnerUserId = ownerUserId,
                ContactUserId = targetUserId,
                Status = "requested"
            });
            await _service.UpsertContactAsync(new Contact
            {
                OwnerUserId = targetUserId,
                ContactUserId = ownerUserId,
                Status = "pending"
            });

            return Ok(await _service.GetContactUserSummariesByOwnerAsync(ownerUserId));
        }

        [HttpPost("contacts/by-user-id")]
        public async Task<IActionResult> AddContactByUserId([FromBody] AddContactByUserIdRequest request)
        {
            if (request == null || request.UserId == Guid.Empty) return BadRequest();

            if (!TryGetCurrentUserId(out var ownerUserId)) return Unauthorized(new { error = "token_invalid" });
            if (request.UserId == ownerUserId) return BadRequest(new { error = "cannot_add_self" });

            var target = await _userService.GetByIdAsync(request.UserId);
            if (target?.Id == null || target.Id.Value == Guid.Empty) return NotFound(new { error = "user_not_found" });

            var targetUserId = request.UserId;

            var existingOwnerToTarget = await _service.GetContactByOwnerAndContactAsync(ownerUserId, targetUserId);
            if (existingOwnerToTarget != null && string.Equals(existingOwnerToTarget.Status, "accepted", StringComparison.OrdinalIgnoreCase))
            {
                return Ok(await _service.GetContactUserSummariesByOwnerAsync(ownerUserId));
            }

            await _service.UpsertContactAsync(new Contact
            {
                OwnerUserId = ownerUserId,
                ContactUserId = targetUserId,
                Status = "accepted"
            });
            await _service.UpsertContactAsync(new Contact
            {
                OwnerUserId = targetUserId,
                ContactUserId = ownerUserId,
                Status = "accepted"
            });

            return Ok(await _service.GetContactUserSummariesByOwnerAsync(ownerUserId));
        }

        [HttpPost("contacts/by-username/{username}/accept")]
        public async Task<IActionResult> AcceptContactInviteByUsername([FromRoute] string username)
        {
            if (string.IsNullOrWhiteSpace(username)) return BadRequest();

            if (!TryGetCurrentUserId(out var ownerUserId)) return Unauthorized(new { error = "token_invalid" });
            var target = await _userService.GetByUsernameAsync(username.Trim());
            if (target?.Id == null || target.Id.Value == Guid.Empty) return NotFound(new { error = "user_not_found" });
            if (target.Id.Value == ownerUserId) return BadRequest(new { error = "cannot_add_self" });

            var targetUserId = target.Id.Value;

            // Only accept if I have something pending/requested; idempotent if already accepted.
            await _service.UpsertContactAsync(new Contact
            {
                OwnerUserId = ownerUserId,
                ContactUserId = targetUserId,
                Status = "accepted"
            });
            await _service.UpsertContactAsync(new Contact
            {
                OwnerUserId = targetUserId,
                ContactUserId = ownerUserId,
                Status = "accepted"
            });

            return Ok(await _service.GetContactUserSummariesByOwnerAsync(ownerUserId));
        }

        [HttpPost("contacts/by-username/{username}/reject")]
        public async Task<IActionResult> RejectContactInviteByUsername([FromRoute] string username)
        {
            if (string.IsNullOrWhiteSpace(username)) return BadRequest();

            if (!TryGetCurrentUserId(out var ownerUserId)) return Unauthorized(new { error = "token_invalid" });
            var target = await _userService.GetByUsernameAsync(username.Trim());
            if (target?.Id == null || target.Id.Value == Guid.Empty) return NotFound(new { error = "user_not_found" });
            if (target.Id.Value == ownerUserId) return BadRequest(new { error = "cannot_add_self" });

            var targetUserId = target.Id.Value;

            // Reject by removing both rows (simplest semantics).
            var a = await _service.GetContactByOwnerAndContactAsync(ownerUserId, targetUserId);
            if (a != null) await _service.DeleteContactAsync(a.Id);

            var b = await _service.GetContactByOwnerAndContactAsync(targetUserId, ownerUserId);
            if (b != null) await _service.DeleteContactAsync(b.Id);

            return Ok(await _service.GetContactUserSummariesByOwnerAsync(ownerUserId));
        }

        [HttpGet("contacts/{id:guid}")]
        public async Task<IActionResult> GetContact(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetContactByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("contacts")]
        public async Task<IActionResult> CreateContact([FromBody] Contact contact)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertContactAsync(contact);
            contact.Id = id;
            return CreatedAtAction(nameof(GetContact), new { id }, contact);
        }

        [HttpPut("contacts/{id:guid}")]
        public async Task<IActionResult> UpdateContact(Guid id, [FromBody] Contact contact)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (id != contact.Id) return BadRequest();
            var rows = await _service.UpdateContactAsync(contact);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("contacts/{id:guid}")]
        public async Task<IActionResult> DeleteContact(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteContactAsync(id);
            return rows == 0 ? NotFound() : NoContent();
        }

        // GROUP ROOMS
        [HttpGet("group-rooms")]
        public async Task<IActionResult> GetGroupRooms()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetGroupRoomsAllAsync());
        }

        [HttpGet("group-rooms/{id:guid}")]
        public async Task<IActionResult> GetGroupRoom(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetGroupRoomByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("group-rooms")]
        public async Task<IActionResult> CreateGroupRoom([FromBody] GroupRoom room)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertGroupRoomAsync(room);
            room.Id = id;
            return CreatedAtAction(nameof(GetGroupRoom), new { id }, room);
        }

        [HttpPut("group-rooms/{id:guid}")]
        public async Task<IActionResult> UpdateGroupRoom(Guid id, [FromBody] GroupRoom room)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (id != room.Id) return BadRequest();
            var rows = await _service.UpdateGroupRoomAsync(room);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("group-rooms/{id:guid}")]
        public async Task<IActionResult> DeleteGroupRoom(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteGroupRoomAsync(id);
            return rows == 0 ? NotFound() : NoContent();
        }

        // GROUP ROOM MEMBERS
        [HttpGet("group-room-members")]
        public async Task<IActionResult> GetGroupRoomMembers()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetGroupRoomMembersAllAsync());
        }

        [HttpGet("group-room-members/{id:guid}")]
        public async Task<IActionResult> GetGroupRoomMember(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetGroupRoomMemberByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("group-room-members")]
        public async Task<IActionResult> CreateGroupRoomMember([FromBody] GroupRoomMember member)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertGroupRoomMemberAsync(member);
            member.Id = id;
            return CreatedAtAction(nameof(GetGroupRoomMember), new { id }, member);
        }

        [HttpPut("group-room-members/{id:guid}")]
        public async Task<IActionResult> UpdateGroupRoomMember(Guid id, [FromBody] GroupRoomMember member)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (id != member.Id) return BadRequest();
            var rows = await _service.UpdateGroupRoomMemberAsync(member);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("group-room-members/{id:guid}")]
        public async Task<IActionResult> DeleteGroupRoomMember(Guid id)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteGroupRoomMemberAsync(id);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
