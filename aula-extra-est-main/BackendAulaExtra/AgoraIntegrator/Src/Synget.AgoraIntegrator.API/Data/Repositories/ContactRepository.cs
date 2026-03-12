using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository implementation for contact operations.
/// </summary>
public class ContactRepository : IContactRepository
{
    private readonly ChatDbContext _db;

    public ContactRepository(ChatDbContext db)
    {
        _db = db;
    }

    public async Task<ContactEntity> AddAsync(long ownerUserId, long contactUserId, string? displayNameOverride = null)
    {
        var existing = await GetAsync(ownerUserId, contactUserId);
        if (existing != null)
        {
            return existing;
        }

        var contact = new ContactEntity
        {
            OwnerUserId = ownerUserId,
            ContactUserId = contactUserId,
            DisplayNameOverride = displayNameOverride,
            Status = ContactStatus.Pending,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _db.Contacts.Add(contact);
        await _db.SaveChangesAsync();
        return contact;
    }

    public async Task<ContactEntity?> GetAsync(long ownerUserId, long contactUserId)
    {
        return await _db.Contacts
            .Include(c => c.ContactUser)
            .FirstOrDefaultAsync(c => c.OwnerUserId == ownerUserId && c.ContactUserId == contactUserId);
    }

    public async Task<List<ContactEntity>> GetByOwnerAsync(long ownerUserId, string? status = null)
    {
        var query = _db.Contacts
            .Include(c => c.ContactUser)
            .Where(c => c.OwnerUserId == ownerUserId);

        if (!string.IsNullOrEmpty(status))
        {
            query = query.Where(c => c.Status == status);
        }

        return await query.OrderBy(c => c.ContactUser!.DisplayName ?? c.ContactUser.Username).ToListAsync();
    }

    public async Task<List<ContactEntity>> GetPendingRequestsAsync(long userId)
    {
        // Get contacts where this user is the contact (i.e., requests TO this user)
        return await _db.Contacts
            .Include(c => c.OwnerUser)
            .Where(c => c.ContactUserId == userId && c.Status == ContactStatus.Pending)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<ContactEntity?> UpdateStatusAsync(long ownerUserId, long contactUserId, string status)
    {
        var contact = await _db.Contacts.FirstOrDefaultAsync(
            c => c.OwnerUserId == ownerUserId && c.ContactUserId == contactUserId);

        if (contact == null) return null;

        contact.Status = status;
        contact.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return contact;
    }

    public async Task<bool> AcceptRequestAsync(long ownerUserId, long contactUserId, string? displayNameOverride = null)
    {
        // Find the original request (where contactUserId sent request to ownerUserId)
        var request = await _db.Contacts.FirstOrDefaultAsync(
            c => c.OwnerUserId == contactUserId && c.ContactUserId == ownerUserId && c.Status == ContactStatus.Pending);

        if (request == null) return false;

        // Update original request to accepted
        request.Status = ContactStatus.Accepted;
        request.UpdatedAt = DateTime.UtcNow;

        // Create reverse contact (ownerUserId -> contactUserId)
        var reverseContact = await _db.Contacts.FirstOrDefaultAsync(
            c => c.OwnerUserId == ownerUserId && c.ContactUserId == contactUserId);

        if (reverseContact == null)
        {
            reverseContact = new ContactEntity
            {
                OwnerUserId = ownerUserId,
                ContactUserId = contactUserId,
                DisplayNameOverride = displayNameOverride,
                Status = ContactStatus.Accepted,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _db.Contacts.Add(reverseContact);
        }
        else
        {
            reverseContact.Status = ContactStatus.Accepted;
            reverseContact.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<bool> RemoveAsync(long ownerUserId, long contactUserId)
    {
        var contact = await _db.Contacts.FirstOrDefaultAsync(
            c => c.OwnerUserId == ownerUserId && c.ContactUserId == contactUserId);

        if (contact == null) return false;

        _db.Contacts.Remove(contact);
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<ContactEntity?> BlockAsync(long ownerUserId, long contactUserId)
    {
        var contact = await _db.Contacts.FirstOrDefaultAsync(
            c => c.OwnerUserId == ownerUserId && c.ContactUserId == contactUserId);

        if (contact == null)
        {
            // Create blocked contact entry
            contact = new ContactEntity
            {
                OwnerUserId = ownerUserId,
                ContactUserId = contactUserId,
                Status = ContactStatus.Blocked,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _db.Contacts.Add(contact);
        }
        else
        {
            contact.Status = ContactStatus.Blocked;
            contact.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return contact;
    }

    public async Task<bool> AcceptByRequestIdAsync(long requestId, string? displayNameOverride = null)
    {
        // Find the pending contact request by its ID
        var request = await _db.Contacts.FirstOrDefaultAsync(
            c => c.Id == requestId && c.Status == ContactStatus.Pending);

        if (request == null)
        {
            return false;
        }

        // In the stored request, OwnerUserId is the sender and ContactUserId is the receiver.
        var receiverUserId = request.ContactUserId;
        var senderUserId = request.OwnerUserId;

        // Reuse the existing logic that accepts a request based on the
        // receiver (ownerUserId) and sender (contactUserId).
        return await AcceptRequestAsync(receiverUserId, senderUserId, displayNameOverride);
    }
}
