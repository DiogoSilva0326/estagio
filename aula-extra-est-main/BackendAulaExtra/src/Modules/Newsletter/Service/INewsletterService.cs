using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Newsletter.Models;

namespace ConfidantPostgreSQL.Modules.Newsletter.Service;

public interface INewsletterService
{
    Task<(bool ok, string message)> SubscribeAsync(SubscribeRequest request, CancellationToken cancellationToken = default);
    Task<(bool ok, string message)> RequestUnsubscribeByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<(bool ok, string message)> ConfirmAsync(string token, CancellationToken cancellationToken = default);
    Task<(bool ok, string message)> UnsubscribeAsync(string token, CancellationToken cancellationToken = default);
    Task HandleBounceAsync(string email, CancellationToken cancellationToken = default);
    Task<Guid> CreateCampaignAsync(CreateCampaignRequest request, CancellationToken cancellationToken = default);
    Task<NewsletterCampaign?> GetCampaignByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task UpdateCampaignAsync(Guid id, UpdateCampaignRequest request, CancellationToken cancellationToken = default);
    Task DeleteCampaignAsync(Guid id, CancellationToken cancellationToken = default);
    Task<(int sent, int failed)> SendCampaignAsync(Guid campaignId, CancellationToken cancellationToken = default);
    Task<List<NewsletterCampaign>> GetCampaignsAsync(int pageNumber = 1, int pageSize = 20, CancellationToken cancellationToken = default);
    Task<List<NewsletterSubscriberSummary>> GetSubscribersAsync(int pageNumber = 1, int pageSize = 100, CancellationToken cancellationToken = default);
    Task<int> GetSubscriberCountAsync(CancellationToken cancellationToken = default);
}