using Synget.AgoraIntegrator.API.Data.Entities;

namespace Synget.AgoraIntegrator.API.Data.Repositories;

/// <summary>
/// Repository interface for contact operations.
/// </summary>
public interface IContactRepository
{
    /// <summary>
    /// Add a contact (creates pending request).
    /// </summary>
    Task<ContactEntity> AddAsync(long ownerUserId, long contactUserId, string? displayNameOverride = null);

    /// <summary>
    /// Get contact by owner and contact user IDs.
    /// </summary>
    Task<ContactEntity?> GetAsync(long ownerUserId, long contactUserId);

    /// <summary>
    /// Get all contacts for a user.
    /// </summary>
    Task<List<ContactEntity>> GetByOwnerAsync(long ownerUserId, string? status = null);

    /// <summary>
    /// Get pending contact requests received by a user.
    /// </summary>
    Task<List<ContactEntity>> GetPendingRequestsAsync(long userId);

    /// <summary>
    /// Update contact status.
    /// </summary>
    Task<ContactEntity?> UpdateStatusAsync(long ownerUserId, long contactUserId, string status);

    /// <summary>
    /// Accept a contact request (updates both directions).
    /// </summary>
    Task<bool> AcceptRequestAsync(long ownerUserId, long contactUserId, string? displayNameOverride = null);

    /// <summary>
    /// Remove a contact.
    /// </summary>
    Task<bool> RemoveAsync(long ownerUserId, long contactUserId);

    /// <summary>
    /// Block a contact.
    /// </summary>
    Task<ContactEntity?> BlockAsync(long ownerUserId, long contactUserId);

    /// <summary>
    /// Accept a contact request by its request/contact ID.
    /// This is used by the legacy API that works with a requestId string.
    /// </summary>
    Task<bool> AcceptByRequestIdAsync(long requestId, string? displayNameOverride = null);
}
