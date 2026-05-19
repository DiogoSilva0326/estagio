using System;
using System.Collections.Generic;
using System.Net;
using System.Security.Cryptography;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Integrations.Email;
using ConfidantPostgreSQL.Modules.Newsletter.Models;
using ConfidantPostgreSQL.Modules.Newsletter.Repository;
using ConfidantPostgreSQL.Modules.SystemSettings.Service;
using Microsoft.AspNetCore.Http;

namespace ConfidantPostgreSQL.Modules.Newsletter.Service;

public class NewsletterService : INewsletterService
{
    private const string SeoSiteUrlKey = "Seo:SiteUrl";
    private const string SeoEmailLinksBaseUrlKey = "Seo:EmailLinksBaseUrl";
    private const string NewsletterEmailLinksModeKey = "Newsletter:EmailLinksBaseUrlMode";
    private const string NewsletterEmailLinksLocalKey = "Newsletter:EmailLinksBaseUrlLocal";
    private const string NewsletterEmailLinksTestKey = "Newsletter:EmailLinksBaseUrlTest";
    private const string PostmarkNewsletterEmailFromKey = "PostMarkClient.NewsletterEmailFrom";
    private readonly INewsletterRepository _repo;
    private readonly IPostmarkService _postmark;
    private readonly ISystemSettingsService _systemSettings;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly string _fallbackSiteUrl;
    private readonly string _fallbackNewsletterLinksMode;
    private readonly string _fallbackNewsletterLocalUrl;
    private readonly string _fallbackNewsletterTestUrl;
    private readonly string _fallbackNewsletterFrom;

    public NewsletterService(
        INewsletterRepository repo,
        IPostmarkService postmark,
        ISystemSettingsService systemSettings,
        IHttpContextAccessor httpContextAccessor)
    {
        _repo = repo;
        _postmark = postmark;
        _systemSettings = systemSettings;
        _httpContextAccessor = httpContextAccessor;
        _fallbackSiteUrl = (Environment.GetEnvironmentVariable("FRONTEND_URL")
            ?? Environment.GetEnvironmentVariable("SITE_URL")
            ?? "https://Apoioextra.pt").Trim().TrimEnd('/');
        _fallbackNewsletterLinksMode = (Environment.GetEnvironmentVariable("NEWSLETTER_EMAIL_LINKS_MODE")
            ?? "auto").Trim().ToLowerInvariant();
        _fallbackNewsletterLocalUrl = (Environment.GetEnvironmentVariable("NEWSLETTER_EMAIL_LINKS_BASE_URL_LOCAL")
            ?? "http://localhost:3000").Trim().TrimEnd('/');
        _fallbackNewsletterTestUrl = (Environment.GetEnvironmentVariable("NEWSLETTER_EMAIL_LINKS_BASE_URL_TEST")
            ?? Environment.GetEnvironmentVariable("FRONTEND_URL")
            ?? Environment.GetEnvironmentVariable("SITE_URL")
            ?? "https://Apoioextra.synget.ovh").Trim().TrimEnd('/');
        _fallbackNewsletterFrom = (Environment.GetEnvironmentVariable("POSTMARK_NEWSLETTER_FROM_EMAIL")
            ?? Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL_NEWSLETTER")
            ?? Environment.GetEnvironmentVariable("POSTMARK_FROM_EMAIL")
            ?? Environment.GetEnvironmentVariable("SYSTEM_EMAIL")
            ?? "newsletter@Apoioextra.pt").Trim();
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

    public async Task<(bool ok, string message)> RequestUnsubscribeByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var normalizedEmail = email?.Trim().ToLowerInvariant() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(normalizedEmail) || !normalizedEmail.Contains('@'))
        {
            return (false, "Email inválido.");
        }

        var subscriber = await _repo.GetSubscriberByEmailAsync(normalizedEmail, cancellationToken);
        if (subscriber == null)
        {
            return (true, "Se o email existir, receberás um email para cancelar a subscrição.");
        }

        subscriber.UnsubscribeToken ??= GenerateToken();
        await _repo.UpdateSubscriberAsync(subscriber, cancellationToken);
        await SendUnsubscribeRequestEmailAsync(subscriber, cancellationToken);

        return (true, "Se o email existir, receberás um email para cancelar a subscrição.");
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
        var publicSiteUrl = await ResolvePublicSiteUrlAsync(cancellationToken);
        var logoUrl = BuildLogoUrl(publicSiteUrl);
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
                    HtmlBody = BuildNewsletterHtml(campaign.Subject, campaign.Preheader, campaign.HtmlBody ?? string.Empty, unsubscribeLink, publicSiteUrl, logoUrl),
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

    public async Task<List<NewsletterSubscriberSummary>> GetSubscribersAsync(int pageNumber = 1, int pageSize = 100, CancellationToken cancellationToken = default)
    {
        var subscribers = await _repo.GetSubscribersAsync(pageNumber, pageSize, activeOnly: true, cancellationToken);
        return subscribers.Select(subscriber => new NewsletterSubscriberSummary
        {
            Id = subscriber.Id,
            Email = subscriber.Email,
            Status = subscriber.Status,
            Locale = subscriber.Locale,
            Source = subscriber.Source,
            CreatedAt = subscriber.CreatedAt,
            ConfirmedAt = subscriber.ConfirmedAt,
            LastUpdate = subscriber.LastUpdate,
        }).ToList();
    }

    public Task<int> GetSubscriberCountAsync(CancellationToken cancellationToken = default)
        => _repo.GetActiveSubscriberCountAsync(cancellationToken);

    private async Task<string> ResolveEmailLinksBaseUrlAsync(CancellationToken cancellationToken)
    {
        var modeSetting = await _systemSettings.GetByKeyAsync(NewsletterEmailLinksModeKey, cancellationToken);
        var localSetting = await _systemSettings.GetByKeyAsync(NewsletterEmailLinksLocalKey, cancellationToken);
        var testSetting = await _systemSettings.GetByKeyAsync(NewsletterEmailLinksTestKey, cancellationToken);
        var customSetting = await _systemSettings.GetByKeyAsync(SeoEmailLinksBaseUrlKey, cancellationToken)
            ?? await _systemSettings.GetByKeyAsync(SeoSiteUrlKey, cancellationToken);

        var mode = modeSetting?.SettingsValue?.Trim().ToLowerInvariant() ?? _fallbackNewsletterLinksMode;
        var localValue = localSetting?.SettingsValue?.Trim().TrimEnd('/');
        var testValue = testSetting?.SettingsValue?.Trim().TrimEnd('/');
        var customValue = customSetting?.SettingsValue?.Trim().TrimEnd('/');

        if (mode == "auto")
        {
            return ResolveAutomaticEmailLinksBaseUrl(localValue, testValue, customValue);
        }

        return mode switch
        {
            "local" => FirstNonEmpty(localValue, _fallbackNewsletterLocalUrl, customValue, _fallbackSiteUrl),
            "test" => FirstNonEmpty(testValue, _fallbackNewsletterTestUrl, customValue, _fallbackSiteUrl),
            "custom" => FirstNonEmpty(customValue, _fallbackSiteUrl, _fallbackNewsletterTestUrl, _fallbackNewsletterLocalUrl),
            _ => ResolveAutomaticEmailLinksBaseUrl(localValue, testValue, customValue),
        };
    }

    private string ResolveAutomaticEmailLinksBaseUrl(string? localValue, string? testValue, string? customValue)
    {
        var requestHost = _httpContextAccessor.HttpContext?.Request.Host.Host?.Trim();
        if (!string.IsNullOrWhiteSpace(requestHost))
        {
            return IsLocalHost(requestHost)
                ? FirstNonEmpty(localValue, _fallbackNewsletterLocalUrl, customValue, _fallbackSiteUrl)
                : FirstNonEmpty(testValue, _fallbackNewsletterTestUrl, customValue, _fallbackSiteUrl);
        }

        var fallbackHost = TryGetHost(_fallbackSiteUrl);
        if (!string.IsNullOrWhiteSpace(fallbackHost))
        {
            return IsLocalHost(fallbackHost)
                ? FirstNonEmpty(localValue, _fallbackNewsletterLocalUrl, customValue, _fallbackSiteUrl)
                : FirstNonEmpty(testValue, _fallbackNewsletterTestUrl, customValue, _fallbackSiteUrl);
        }

        return FirstNonEmpty(testValue, _fallbackNewsletterTestUrl, customValue, _fallbackSiteUrl, localValue, _fallbackNewsletterLocalUrl);
    }

    private static string? TryGetHost(string? url)
    {
        if (string.IsNullOrWhiteSpace(url))
        {
            return null;
        }

        return Uri.TryCreate(url, UriKind.Absolute, out var uri)
            ? uri.Host
            : null;
    }

    private static bool IsLocalHost(string host)
    {
        if (string.IsNullOrWhiteSpace(host))
        {
            return false;
        }

        return host.Equals("localhost", StringComparison.OrdinalIgnoreCase)
            || host.Equals("127.0.0.1", StringComparison.OrdinalIgnoreCase)
            || host.Equals("::1", StringComparison.OrdinalIgnoreCase)
            || host.Equals("[::1]", StringComparison.OrdinalIgnoreCase);
    }

    private async Task<string> ResolveNewsletterFromAsync(CancellationToken cancellationToken)
    {
        var setting = await _systemSettings.GetByKeyAsync(PostmarkNewsletterEmailFromKey, cancellationToken);
        var value = setting?.SettingsValue?.Trim();
        return string.IsNullOrWhiteSpace(value) ? _fallbackNewsletterFrom : value;
    }

    private async Task<string> ResolvePublicSiteUrlAsync(CancellationToken cancellationToken)
    {
        var setting = await _systemSettings.GetByKeyAsync(SeoSiteUrlKey, cancellationToken)
            ?? await _systemSettings.GetByKeyAsync(SeoEmailLinksBaseUrlKey, cancellationToken);
        var value = setting?.SettingsValue?.Trim().TrimEnd('/');
        return string.IsNullOrWhiteSpace(value) ? _fallbackSiteUrl : value;
    }

    private async Task SendConfirmationEmailAsync(NewsletterSubscriber subscriber, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(subscriber.ConfirmToken))
        {
            return;
        }

        var baseUrl = await ResolveEmailLinksBaseUrlAsync(cancellationToken);
        var publicSiteUrl = await ResolvePublicSiteUrlAsync(cancellationToken);
        var confirmLink = $"{baseUrl}/newsletter/confirmar?token={Uri.EscapeDataString(subscriber.ConfirmToken)}";
        var dto = new EmailSenderDto
        {
            To = subscriber.Email,
            From = await ResolveNewsletterFromAsync(cancellationToken),
            Subject = "Confirma a tua subscrição na ApoioExtra",
            HtmlBody = BuildConfirmationHtml(confirmLink, subscriber.Email, publicSiteUrl, BuildLogoUrl(publicSiteUrl)),
            TextBody = $"Obrigado por te subscreveres à newsletter da ApoioExtra.\n\nConfirma a tua subscrição em: {confirmLink}\n\nSe não fizeste este pedido, ignora este email.",
            Tag = "newsletter-confirm",
            MessageStream = "outbound",
        };

        await _postmark.SendEmailAsync(dto, cancellationToken);
    }

    private async Task SendUnsubscribeRequestEmailAsync(NewsletterSubscriber subscriber, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(subscriber.UnsubscribeToken))
        {
            return;
        }

        var baseUrl = await ResolveEmailLinksBaseUrlAsync(cancellationToken);
        var publicSiteUrl = await ResolvePublicSiteUrlAsync(cancellationToken);
        var unsubscribeLink = $"{baseUrl}/newsletter/cancelar?token={Uri.EscapeDataString(subscriber.UnsubscribeToken)}";
        var dto = new EmailSenderDto
        {
            To = subscriber.Email,
            From = await ResolveNewsletterFromAsync(cancellationToken),
            Subject = "Gerir subscrição da newsletter da ApoioExtra",
            HtmlBody = BuildUnsubscribeRequestHtml(unsubscribeLink, subscriber.Email, publicSiteUrl, BuildLogoUrl(publicSiteUrl)),
            TextBody = $"Recebemos um pedido para cancelar a subscrição deste email na newsletter da ApoioExtra.\n\nConfirma o cancelamento em: {unsubscribeLink}\n\nSe não foste tu, ignora este email.",
            Tag = "newsletter-unsubscribe-request",
            MessageStream = "outbound",
        };

        await _postmark.SendEmailAsync(dto, cancellationToken);
    }

    private static string FirstNonEmpty(params string?[] values)
    {
        foreach (var value in values)
        {
            var normalized = value?.Trim().TrimEnd('/');
            if (!string.IsNullOrWhiteSpace(normalized))
            {
                return normalized;
            }
        }

        return string.Empty;
    }

    private static string BuildPlainText(NewsletterCampaign campaign, string unsubscribeLink)
    {
        var baseText = string.IsNullOrWhiteSpace(campaign.PlainBody)
            ? StripHtml(campaign.HtmlBody ?? campaign.Subject)
            : campaign.PlainBody!;
        return $"{baseText}\n\n---\nPara cancelar a subscrição: {unsubscribeLink}";
    }

        private static string BuildConfirmationHtml(string confirmLink, string email, string siteUrl, string logoUrl)
    {
                var content = $@"
                    <tr>
                        <td style='padding:40px 36px 8px;'>
                            <div style='display:inline-block;padding:8px 14px;border-radius:999px;background:#FFF1E3;color:#FC9039;font-size:12px;font-weight:700;letter-spacing:0.8px;'>NEWSLETTER Apoio EXTRA</div>
                            <h1 style='margin:22px 0 14px;color:#6A3B10;font-size:36px;line-height:1.05;font-weight:800;'>Confirma a tua subscrição</h1>
                            <p style='margin:0;color:#7B6758;font-size:16px;line-height:26px;'>Recebemos um pedido para juntar o email <strong style='color:#6A3B10;'>{EscapeHtml(email)}</strong> à newsletter da Apoio Extra. Confirma abaixo para começares a receber novidades, novos explicadores e atualizações da plataforma.</p>
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:0 36px 24px;'>
                            {BuildHighlightPanel("Confirmação segura", "Este passo ativa a subscrição e valida que foste tu quem pediu receber comunicações da Apoio Extra.")}
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:0 36px 18px;'>
                            {BuildPrimaryButton(confirmLink, "Confirmar subscrição")}
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:0 36px 38px;'>
                            <p style='margin:0 0 10px;color:#7B6758;font-size:14px;line-height:22px;'>Se o botão não funcionar, usa este link:</p>
                            <p style='margin:0;word-break:break-all;'><a href='{EscapeHtml(confirmLink)}' style='color:#FC9039;text-decoration:none;font-size:14px;line-height:22px;'>{EscapeHtml(confirmLink)}</a></p>
                            <p style='margin:18px 0 0;color:#9A8572;font-size:13px;line-height:21px;'>Se não fizeste este pedido, podes ignorar este email.</p>
                        </td>
                    </tr>";

                return BuildEmailShell(
                        title: "Confirma a tua subscrição na ApoioExtra",
                        preheader: "Confirma o teu email para começares a receber as novidades da Apoio Extra.",
                        bodyHtml: content,
                        siteUrl: siteUrl,
                        logoUrl: logoUrl,
                        footerNote: "Recebeste este email porque foi iniciado um pedido de subscrição da newsletter da Apoio Extra.");
    }

        private static string BuildUnsubscribeRequestHtml(string unsubscribeLink, string email, string siteUrl, string logoUrl)
        {
                var content = $@"
                    <tr>
                        <td style='padding:40px 36px 8px;'>
                            <div style='display:inline-block;padding:8px 14px;border-radius:999px;background:#FFF1E3;color:#FC9039;font-size:12px;font-weight:700;letter-spacing:0.8px;'>GESTÃO DE SUBSCRIÇÃO</div>
                            <h1 style='margin:22px 0 14px;color:#6A3B10;font-size:36px;line-height:1.05;font-weight:800;'>Cancelar newsletter</h1>
                            <p style='margin:0;color:#7B6758;font-size:16px;line-height:26px;'>Recebemos um pedido para remover o email <strong style='color:#6A3B10;'>{EscapeHtml(email)}</strong> da newsletter da Apoio Extra. Se foste tu, confirma abaixo.</p>
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:0 36px 24px;'>
                            {BuildHighlightPanel("Sem passos extra", "Ao confirmar, este email deixa de receber newsletters e comunicações promocionais da Apoio Extra.")}
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:0 36px 18px;'>
                            {BuildPrimaryButton(unsubscribeLink, "Cancelar subscrição")}
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:0 36px 38px;'>
                            <p style='margin:0 0 10px;color:#7B6758;font-size:14px;line-height:22px;'>Se o botão não funcionar, usa este link:</p>
                            <p style='margin:0;word-break:break-all;'><a href='{EscapeHtml(unsubscribeLink)}' style='color:#FC9039;text-decoration:none;font-size:14px;line-height:22px;'>{EscapeHtml(unsubscribeLink)}</a></p>
                            <p style='margin:18px 0 0;color:#9A8572;font-size:13px;line-height:21px;'>Se não foste tu que pediste este cancelamento, ignora esta mensagem e manteremos a subscrição ativa.</p>
                        </td>
                    </tr>";

                return BuildEmailShell(
                        title: "Gerir subscrição da newsletter da ApoioExtra",
                        preheader: "Confirma se queres cancelar a subscrição da newsletter da Apoio Extra.",
                        bodyHtml: content,
                        siteUrl: siteUrl,
                        logoUrl: logoUrl,
                        footerNote: "Recebeste este email porque foi iniciado um pedido de cancelamento da newsletter da Apoio Extra.");
        }

        private static string BuildNewsletterHtml(string subject, string? preheader, string bodyHtml, string unsubscribeLink, string siteUrl, string logoUrl)
    {
        var safeBody = string.IsNullOrWhiteSpace(bodyHtml)
                        ? "<p style='margin:0;color:#7B6758;font-size:16px;line-height:26px;'>Newsletter sem conteúdo.</p>"
            : bodyHtml.Replace("{{UNSUBSCRIBE_LINK}}", unsubscribeLink, StringComparison.Ordinal);

                var content = $@"
                    <tr>
                        <td style='padding:18px 36px 0;'>
                            <div style='display:inline-block;padding:8px 14px;border-radius:999px;background:#FFF1E3;color:#FC9039;font-size:12px;font-weight:700;letter-spacing:0.8px;'>Apoio EXTRA NEWSLETTER</div>
                            <h1 style='margin:20px 0 12px;color:#6A3B10;font-size:40px;line-height:1.02;font-weight:800;'>{EscapeHtml(subject)}</h1>
                            <p style='margin:0;color:#7B6758;font-size:16px;line-height:26px;'>{EscapeHtml(string.IsNullOrWhiteSpace(preheader) ? "Novidades e oportunidades para a tua jornada académica." : preheader!)}</p>
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:28px 36px 16px;'>
                            <div style='background:#FFFFFF;border:1px solid #F1E4D7;border-radius:28px;padding:28px;'>
                                {safeBody}
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td style='padding:0 36px 38px;'>
                            <div style='padding:20px 22px;border-radius:22px;background:#F8EFE5;'>
                                <p style='margin:0;color:#7B6758;font-size:13px;line-height:22px;'>Estás a receber esta newsletter porque subscreveste comunicações do Apoio Extra. Se já não fizer sentido para ti, podes <a href='{EscapeHtml(unsubscribeLink)}' style='color:#FC9039;text-decoration:none;font-weight:700;'>cancelar a subscrição aqui</a>.</p>
                            </div>
                        </td>
                    </tr>";

                return BuildEmailShell(
                        title: subject,
                        preheader: preheader ?? subject,
                        bodyHtml: content,
                        siteUrl: siteUrl,
                        logoUrl: logoUrl,
                        footerNote: "Apoio Extra. Explicadores, tutores e apoio académico para quem quer evoluir com acompanhamento certo.");
    }

        private static string BuildEmailShell(string title, string preheader, string bodyHtml, string siteUrl, string logoUrl, string footerNote)
        {
                var safeTitle = EscapeHtml(title);
                var safePreheader = EscapeHtml(preheader);
                var safeSiteUrl = EscapeHtml(siteUrl);
                var safeLogoUrl = EscapeHtml(logoUrl);
                var safeFooterNote = EscapeHtml(footerNote);

                return $@"<!DOCTYPE html>
<html lang='pt'>
    <head>
        <meta charset='utf-8' />
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <title>{safeTitle}</title>
    </head>
    <body style='margin:0;padding:0;background:#F7F1E9;font-family:Arial,sans-serif;color:#6A3B10;'>
        <div style='display:none;max-height:0;overflow:hidden;'>{safePreheader}</div>
        <table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='border-collapse:collapse;background:#F7F1E9;'>
            <tr>
                <td align='center' style='padding:32px 16px;'>
                    <table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='width:100%;max-width:680px;border-collapse:collapse;'>
                        <tr>
                            <td style='padding:0 0 16px 0;text-align:center;'>
                                <a href='{safeSiteUrl}' style='text-decoration:none;'>
                                    <img src='{safeLogoUrl}' alt='Apoio Extra' style='display:block;margin:0 auto;width:220px;max-width:220px;height:auto;' />
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td style='background:linear-gradient(180deg,#FFF8F1 0%,#FFFDF9 100%);border:1px solid #F1E4D7;border-radius:34px;overflow:hidden;box-shadow:0 18px 40px rgba(106,59,16,0.08);'>
                                <table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='border-collapse:collapse;'>
                                    <tr>
                                        <td style='padding:26px 36px 0;'>
                                            <div style='height:8px;width:132px;border-radius:999px;background:linear-gradient(90deg,#FC9039 0%,#F8C76A 100%);'></div>
                                        </td>
                                    </tr>
                                    {bodyHtml}
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td style='padding:18px 18px 0;text-align:center;'>
                                <p style='margin:0;color:#9A8572;font-size:12px;line-height:20px;'>{safeFooterNote}</p>
                                <p style='margin:10px 0 0;color:#B29C89;font-size:12px;line-height:20px;'>© {DateTime.UtcNow.Year} Apoio Extra. Todos os direitos reservados.</p>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
</html>";
        }

        private static string BuildHighlightPanel(string title, string text)
                => $@"<div style='padding:18px 20px;border-radius:22px;background:#F8EFE5;'><p style='margin:0 0 8px;color:#6A3B10;font-size:15px;font-weight:700;line-height:22px;'>{EscapeHtml(title)}</p><p style='margin:0;color:#7B6758;font-size:14px;line-height:22px;'>{EscapeHtml(text)}</p></div>";

        private static string BuildPrimaryButton(string url, string label)
                => $@"<a href='{EscapeHtml(url)}' style='display:inline-block;padding:15px 26px;border-radius:16px;background:#FC9039;color:#6A3B10;text-decoration:none;font-size:15px;font-weight:800;line-height:20px;'>{{label}}</a>".Replace("{label}", EscapeHtml(label), StringComparison.Ordinal);

        private static string BuildLogoUrl(string siteUrl)
                => $"{siteUrl.TrimEnd('/')}/assets/lib/core/components/header/images/logo_header.svg";

        private static string EscapeHtml(string value)
                => WebUtility.HtmlEncode(value ?? string.Empty);

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