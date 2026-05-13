using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Newsletter.Models;

namespace ConfidantPostgreSQL.Modules.Newsletter.Repository;

public interface INewsletterRepository
{
    Task<NewsletterSubscriber?> GetSubscriberByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<NewsletterSubscriber?> GetSubscriberByConfirmTokenAsync(string token, CancellationToken cancellationToken = default);
    Task<NewsletterSubscriber?> GetSubscriberByUnsubscribeTokenAsync(string token, CancellationToken cancellationToken = default);
    Task<Guid> InsertSubscriberAsync(NewsletterSubscriber subscriber, CancellationToken cancellationToken = default);
    Task<bool> UpdateSubscriberAsync(NewsletterSubscriber subscriber, CancellationToken cancellationToken = default);
    Task<bool> MarkBouncedAsync(string email, CancellationToken cancellationToken = default);
    Task<List<NewsletterSubscriber>> GetActiveSubscribersAsync(string? segment = null, CancellationToken cancellationToken = default);
    Task<int> GetActiveSubscriberCountAsync(CancellationToken cancellationToken = default);
    Task<Guid> InsertCampaignAsync(NewsletterCampaign campaign, CancellationToken cancellationToken = default);
    Task<NewsletterCampaign?> GetCampaignByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> UpdateCampaignAsync(NewsletterCampaign campaign, CancellationToken cancellationToken = default);
    Task<bool> UpdateCampaignContentAsync(Guid id, string title, string subject, string? preheader, string? htmlBody, string? plainBody, string segment, CancellationToken cancellationToken = default);
    Task<bool> DeleteCampaignAsync(Guid id, CancellationToken cancellationToken = default);
    Task<List<NewsletterCampaign>> GetCampaignsAsync(int pageNumber = 1, int pageSize = 20, CancellationToken cancellationToken = default);
    Task<Guid> InsertSendAsync(NewsletterSend send, CancellationToken cancellationToken = default);
    Task<bool> UpdateSendStatusAsync(Guid sendId, string status, string? postmarkMessageId = null, string? errorMessage = null, CancellationToken cancellationToken = default);
}