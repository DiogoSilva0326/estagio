using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Integrations.Email;
using ConfidantPostgreSQL.Modules.Newsletter.Models;
using ConfidantPostgreSQL.Modules.Newsletter.Repository;
using ConfidantPostgreSQL.Modules.SystemSettings.Service;

namespace ConfidantPostgreSQL.Modules.Newsletter.Service;

public class NewsletterService : INewsletterService
{
    private const string SeoSiteUrlKey = "Seo:SiteUrl";
    private const string SeoEmailLinksBaseUrlKey = "Seo:EmailLinksBaseUrl";
    private const string PostmarkNewsletterEmailFromKey = "PostMarkClient.NewsletterEmailFrom";
    private readonly INewsletterRepository _repo;
    private readonly IPostmarkService _postmark;
    private readonly ISystemSettingsService _systemSettings;
    private readonly string _fallbackSiteUrl;
    private readonly string _fallbackNewsletterFrom;

    public NewsletterService(
        INewsletterRepository repo,
        IPostmarkService postmark,
        ISystemSettingsService systemSettings)
    {
        _repo = repo;
        _postmark = postmark;
        _systemSettings = systemSettings;
        _fallbackSiteUrl = (Environment.GetEnvironmentVariable("FRONTEND_URL")
            ?? Environment.GetEnvironmentVariable("SITE_URL")
            ?? "https://aulaextra.pt").Trim().TrimEnd('/');
        _fallbackNewsletterFrom = (Environment.GetEnvironmentVariable("POSTMARK_NEWSLETTER_FROM_EMAIL")
            ?? Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL_NEWSLETTER")
            ?? Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL")
            ?? Environment.GetEnvironmentVariable("SYSTEM_EMAIL")
            ?? "newsletter@aulaextra.pt").Trim();
    }

    public async Task<(bool ok, string message)> SubscribeAsync(SubscribeRequest request, CancellationToken cancellationToken = default)
    {
        var email = request.Email?.Trim().ToLowerInvariant() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(email) || !email.Contains('@'))
        {
            return (false, "Email inválido.");
        }

        var existing = await _repo.GetSubscriberByEmailAsync(email, cancellationToken);
        if (existing != null)
        {
            switch (existing.Status)
            {
                case "subscribed":
                    return (true, "Se o email existir, receberás um email de confirmação.");
                case "unsubscribed":
                case "pending":
                    existing.Status = "pending";
                    existing.Locale = request.Locale ?? existing.Locale;
                    existing.Source = request.Source ?? existing.Source;
                    existing.ConfirmToken = GenerateToken();
                    existing.ConfirmTokenExpiresAt = DateTime.UtcNow.AddDays(7);
                    existing.UnsubscribedAt = null;
                    await _repo.UpdateSubscriberAsync(existing, cancellationToken);
                    await SendConfirmationEmailAsync(existing, cancellationToken);
                    return (true, "Se o email existir, receberás um email de confirmação.");
                case "bounced":
                    return (true, "Se o email existir, receberás um email de confirmação.");
            }
        }

        var subscriber = new NewsletterSubscriber
        {
            Email = email,
            Status = "pending",
            Locale = request.Locale ?? "pt-PT",
            Source = request.Source ?? "footer",
            ConfirmToken = GenerateToken(),
            ConfirmTokenExpiresAt = DateTime.UtcNow.AddDays(7),
            UnsubscribeToken = GenerateToken(),
        };

        await _repo.InsertSubscriberAsync(subscriber, cancellationToken);
        await SendConfirmationEmailAsync(subscriber, cancellationToken);
        return (true, "Se o email existir, receberás um email de confirmação.");
    }

    public async Task<(bool ok, string message)> ConfirmAsync(string token, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return (false, "Token inválido.");
        }

        var subscriber = await _repo.GetSubscriberByConfirmTokenAsync(token.Trim(), cancellationToken);
        if (subscriber == null)
        {
            return (false, "Token não encontrado ou já usado.");
        }

        if (subscriber.ConfirmTokenExpiresAt.HasValue && subscriber.ConfirmTokenExpiresAt.Value < DateTime.UtcNow)
        {
            return (false, "Token expirado. Subscreve-te novamente.");
        }

        subscriber.Status = "subscribed";
        subscriber.ConfirmedAt = DateTime.UtcNow;
        subscriber.ConfirmToken = null;
        subscriber.ConfirmTokenExpiresAt = null;
        subscriber.UnsubscribeToken ??= GenerateToken();
        await _repo.UpdateSubscriberAsync(subscriber, cancellationToken);
        return (true, "Subscrição confirmada. Obrigado.");
    }

    public async Task<(bool ok, string message)> UnsubscribeAsync(string token, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return (false, "Token inválido.");
        }

        var subscriber = await _repo.GetSubscriberByUnsubscribeTokenAsync(token.Trim(), cancellationToken);
        if (subscriber == null)
        {
            return (false, "Link de cancelamento inválido.");
        }

        subscriber.Status = "unsubscribed";
        subscriber.UnsubscribedAt = DateTime.UtcNow;
        await _repo.UpdateSubscriberAsync(subscriber, cancellationToken);
        return (true, "Cancelaste a tua subscrição. Podes voltar a subscrever-te quando quiseres.");
    }

    public async Task HandleBounceAsync(string email, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrWhiteSpace(email))
        {
            await _repo.MarkBouncedAsync(email, cancellationToken);
        }
    }

    public async Task<Guid> CreateCampaignAsync(CreateCampaignRequest request, CancellationToken cancellationToken = default)
    {
        var campaign = new NewsletterCampaign
        {
            Title = request.Title,
            Subject = request.Subject,
            Preheader = request.Preheader,
            HtmlBody = request.HtmlBody,
            PlainBody = request.PlainBody,
            Segment = string.IsNullOrWhiteSpace(request.Segment) ? "all_subscribed" : request.Segment.Trim(),
            Status = "draft",
        };
        return await _repo.InsertCampaignAsync(campaign, cancellationToken);
    }

    public Task<NewsletterCampaign?> GetCampaignByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => _repo.GetCampaignByIdAsync(id, cancellationToken);

    public async Task UpdateCampaignAsync(Guid id, UpdateCampaignRequest request, CancellationToken cancellationToken = default)
    {
        var campaign = await _repo.GetCampaignByIdAsync(id, cancellationToken);
        if (campaign == null)
        {
            throw new KeyNotFoundException("Campaign not found.");
        }

        if (campaign.Status is not ("draft" or "failed"))
        {
            throw new InvalidOperationException("Só pode editar campanhas em rascunho ou com falha.");
        }

        await _repo.UpdateCampaignContentAsync(
            id,
            request.Title,
            request.Subject,
            request.Preheader,
            request.HtmlBody,
            request.PlainBody,
            string.IsNullOrWhiteSpace(request.Segment) ? "all_subscribed" : request.Segment.Trim(),
            cancellationToken);
    }

    public async Task DeleteCampaignAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var deleted = await _repo.DeleteCampaignAsync(id, cancellationToken);
        if (!deleted)
        {
            throw new KeyNotFoundException("Campaign not found.");
        }
    }

    public async Task<(int sent, int failed)> SendCampaignAsync(Guid campaignId, CancellationToken cancellationToken = default)
    {
        var campaign = await _repo.GetCampaignByIdAsync(campaignId, cancellationToken);
        if (campaign == null)
        {
            throw new KeyNotFoundException("Campaign not found.");
        }

        if (campaign.Status == "sending")
        {
            throw new InvalidOperationException("O envio desta campanha já está em curso.");
        }

        campaign.Status = "sending";
        await _repo.UpdateCampaignAsync(campaign, cancellationToken);

        var subscribers = await _repo.GetActiveSubscribersAsync(campaign.Segment, cancellationToken);
        campaign.TotalRecipients = subscribers.Count;
        var sent = 0;
        var failed = 0;
        var siteUrl = await ResolveEmailLinksBaseUrlAsync(cancellationToken);
        var fromEmail = await ResolveNewsletterFromAsync(cancellationToken);

        foreach (var subscriber in subscribers)
        {
            subscriber.UnsubscribeToken ??= GenerateToken();
            await _repo.UpdateSubscriberAsync(subscriber, cancellationToken);

            var sendId = await _repo.InsertSendAsync(
                new NewsletterSend
                {
                    CampaignId = campaignId,
                    SubscriberId = subscriber.Id,
                    Email = subscriber.Email,
                    Status = "queued",
                },
                cancellationToken);

            try
            {
                var unsubscribeLink = $"{siteUrl}/newsletter/cancelar?token={Uri.EscapeDataString(subscriber.UnsubscribeToken ?? string.Empty)}";
                var dto = new EmailSenderDto
                {
                    To = subscriber.Email,
                    From = fromEmail,
                    Subject = campaign.Subject,
                    HtmlBody = BuildNewsletterHtml(campaign.Subject, campaign.Preheader, campaign.HtmlBody ?? string.Empty, unsubscribeLink),
                    TextBody = BuildPlainText(campaign, unsubscribeLink),
                    Tag = $"newsletter-{campaignId}",
                    MessageStream = "broadcast",
                    TrackOpens = true,
                };

                var ok = await _postmark.SendEmailAsync(dto, cancellationToken);
                if (ok)
                {
                    await _repo.UpdateSendStatusAsync(sendId, "sent", cancellationToken: cancellationToken);
                    sent++;
                }
                else
                {
                    await _repo.UpdateSendStatusAsync(sendId, "failed", errorMessage: "Postmark returned false", cancellationToken: cancellationToken);
                    failed++;
                }
            }
            catch (Exception ex)
            {
                await _repo.UpdateSendStatusAsync(sendId, "failed", errorMessage: ex.Message, cancellationToken: cancellationToken);
                failed++;
            }
        }

        campaign.Status = failed == subscribers.Count && subscribers.Count > 0 ? "failed" : "sent";
        campaign.SentAt = DateTime.UtcNow;
        campaign.TotalSent = sent;
        campaign.TotalFailed = failed;
        campaign.TimesSent += 1;
        await _repo.UpdateCampaignAsync(campaign, cancellationToken);
        return (sent, failed);
    }

    public Task<List<NewsletterCampaign>> GetCampaignsAsync(int pageNumber = 1, int pageSize = 20, CancellationToken cancellationToken = default)
        => _repo.GetCampaignsAsync(pageNumber, pageSize, cancellationToken);

    public Task<int> GetSubscriberCountAsync(CancellationToken cancellationToken = default)
        => _repo.GetActiveSubscriberCountAsync(cancellationToken);

    private async Task<string> ResolveEmailLinksBaseUrlAsync(CancellationToken cancellationToken)
    {
        var setting = await _systemSettings.GetByKeyAsync(SeoEmailLinksBaseUrlKey, cancellationToken)
            ?? await _systemSettings.GetByKeyAsync(SeoSiteUrlKey, cancellationToken);
        var value = setting?.SettingsValue?.Trim().TrimEnd('/');
        return string.IsNullOrWhiteSpace(value) ? _fallbackSiteUrl : value;
    }

    private async Task<string> ResolveNewsletterFromAsync(CancellationToken cancellationToken)
    {
        var setting = await _systemSettings.GetByKeyAsync(PostmarkNewsletterEmailFromKey, cancellationToken);
        var value = setting?.SettingsValue?.Trim();
        return string.IsNullOrWhiteSpace(value) ? _fallbackNewsletterFrom : value;
    }

    private async Task SendConfirmationEmailAsync(NewsletterSubscriber subscriber, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(subscriber.ConfirmToken))
        {
            return;
        }

        var baseUrl = await ResolveEmailLinksBaseUrlAsync(cancellationToken);
        var confirmLink = $"{baseUrl}/newsletter/confirmar?token={Uri.EscapeDataString(subscriber.ConfirmToken)}";
        var dto = new EmailSenderDto
        {
            To = subscriber.Email,
            From = await ResolveNewsletterFromAsync(cancellationToken),
            Subject = "Confirma a tua subscrição na AulaExtra",
            HtmlBody = BuildConfirmationHtml(confirmLink),
            TextBody = $"Obrigado por te subscreveres à newsletter da AulaExtra.\n\nConfirma a tua subscrição em: {confirmLink}\n\nSe não fizeste este pedido, ignora este email.",
            Tag = "newsletter-confirm",
            MessageStream = "outbound",
        };

        await _postmark.SendEmailAsync(dto, cancellationToken);
    }

    private static string BuildPlainText(NewsletterCampaign campaign, string unsubscribeLink)
    {
        var baseText = string.IsNullOrWhiteSpace(campaign.PlainBody)
            ? StripHtml(campaign.HtmlBody ?? campaign.Subject)
            : campaign.PlainBody!;
        return $"{baseText}\n\n---\nPara cancelar a subscrição: {unsubscribeLink}";
    }

    private static string BuildConfirmationHtml(string confirmLink)
    {
        return $@"<!DOCTYPE html>
<html lang='pt'>
  <body style='font-family:Arial,sans-serif;background:#f6f8fb;padding:32px;color:#1f2937;'>
    <table width='100%' cellpadding='0' cellspacing='0' style='max-width:640px;margin:0 auto;background:#ffffff;border-radius:18px;padding:40px;'>
      <tr><td>
        <p style='font-size:13px;font-weight:700;letter-spacing:1.2px;color:#fb7b02;margin:0 0 16px;'>AULAEXTRA NEWSLETTER</p>
        <h1 style='font-size:28px;line-height:1.2;margin:0 0 16px;'>Confirma a tua subscrição</h1>
        <p style='font-size:16px;line-height:1.6;margin:0 0 24px;'>Recebemos um pedido para adicionarmos este email à newsletter da AulaExtra. Usa o botão abaixo para confirmar.</p>
        <p style='margin:0 0 24px;'><a href='{confirmLink}' style='display:inline-block;background:linear-gradient(90deg,#f15c64,#fabd2d);color:#ffffff;text-decoration:none;padding:14px 24px;border-radius:14px;font-weight:700;'>Confirmar subscrição</a></p>
        <p style='font-size:14px;line-height:1.6;color:#6b7280;margin:0;'>Se não fizeste este pedido, podes ignorar esta mensagem.</p>
      </td></tr>
    </table>
  </body>
</html>";
    }

    private static string BuildNewsletterHtml(string subject, string? preheader, string bodyHtml, string unsubscribeLink)
    {
        var safeBody = string.IsNullOrWhiteSpace(bodyHtml)
            ? "<p>Newsletter sem conteúdo.</p>"
            : bodyHtml.Replace("{{UNSUBSCRIBE_LINK}}", unsubscribeLink, StringComparison.Ordinal);

        return $@"<!DOCTYPE html>
<html lang='pt'>
  <body style='margin:0;background:#f6f8fb;font-family:Arial,sans-serif;color:#111827;'>
    <div style='display:none;max-height:0;overflow:hidden;'>{preheader ?? subject}</div>
    <table width='100%' cellpadding='0' cellspacing='0' style='padding:32px 16px;'>
      <tr>
        <td align='center'>
          <table width='100%' cellpadding='0' cellspacing='0' style='max-width:720px;background:#ffffff;border-radius:24px;overflow:hidden;'>
            <tr>
              <td style='padding:36px 40px;background:linear-gradient(90deg,#f15c64,#fabd2d);color:#ffffff;'>
                <p style='margin:0 0 8px;font-size:13px;font-weight:700;letter-spacing:1.2px;'>AULAEXTRA</p>
                <h1 style='margin:0;font-size:32px;line-height:1.15;'>{subject}</h1>
              </td>
            </tr>
            <tr>
              <td style='padding:40px;'>
                {safeBody}
              </td>
            </tr>
            <tr>
              <td style='padding:24px 40px;background:#f9fafb;border-top:1px solid #e5e7eb;'>
                <p style='margin:0;font-size:13px;line-height:1.6;color:#6b7280;'>Estás a receber esta newsletter porque subscreveste comunicações da AulaExtra. <a href='{unsubscribeLink}' style='color:#f15c64;'>Cancelar subscrição</a></p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>";
    }

    private static string StripHtml(string value)
    {
        return value.Replace("<br>", "\n", StringComparison.OrdinalIgnoreCase)
            .Replace("<br/>", "\n", StringComparison.OrdinalIgnoreCase)
            .Replace("<br />", "\n", StringComparison.OrdinalIgnoreCase)
            .Replace("</p>", "\n\n", StringComparison.OrdinalIgnoreCase)
            .Replace("</div>", "\n", StringComparison.OrdinalIgnoreCase)
            .Replace("<li>", "- ", StringComparison.OrdinalIgnoreCase)
            .Replace("</li>", "\n", StringComparison.OrdinalIgnoreCase);
    }

    private static string GenerateToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(32);
        return Convert.ToBase64String(bytes)
            .Replace("+", "-")
            .Replace("/", "_")
            .TrimEnd('=');
    }
}