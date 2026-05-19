using System;

namespace ConfidantPostgreSQL.Modules.Newsletter.Models;

public class NewsletterSubscriber
{
    public Guid Id { get; set; }
    public string Email { get; set; } = default!;
    public string Status { get; set; } = "pending";
    public string Locale { get; set; } = "pt-PT";
    public string? Source { get; set; }
    public string? ConfirmToken { get; set; }
    public DateTime? ConfirmTokenExpiresAt { get; set; }
    public string? UnsubscribeToken { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ConfirmedAt { get; set; }
    public DateTime? UnsubscribedAt { get; set; }
    public DateTime? BouncedAt { get; set; }
    public DateTime LastUpdate { get; set; }
    public bool Inactive { get; set; }
}

public class NewsletterSubscriberSummary
{
    public Guid Id { get; set; }
    public string Email { get; set; } = default!;
    public string Status { get; set; } = default!;
    public string Locale { get; set; } = default!;
    public string? Source { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ConfirmedAt { get; set; }
    public DateTime LastUpdate { get; set; }
}

public class NewsletterCampaign
{
    public Guid Id { get; set; }
    public string Title { get; set; } = default!;
    public string Subject { get; set; } = default!;
    public string? Preheader { get; set; }
    public string? HtmlBody { get; set; }
    public string? PlainBody { get; set; }
    public string Status { get; set; } = "draft";
    public string Segment { get; set; } = "all_subscribed";
    public DateTime? ScheduledAt { get; set; }
    public DateTime? SentAt { get; set; }
    public int TotalRecipients { get; set; }
    public int TotalSent { get; set; }
    public int TotalFailed { get; set; }
    public int TimesSent { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime LastUpdate { get; set; }
    public bool Inactive { get; set; }
}

public class NewsletterSend
{
    public Guid Id { get; set; }
    public Guid CampaignId { get; set; }
    public Guid SubscriberId { get; set; }
    public string Email { get; set; } = default!;
    public string Status { get; set; } = "queued";
    public string? PostmarkMessageId { get; set; }
    public DateTime? SentAt { get; set; }
    public string? ErrorMessage { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class SubscribeRequest
{
    public string Email { get; set; } = default!;
    public string? Locale { get; set; }
    public string? Source { get; set; }
}

public class NewsletterEmailRequest
{
    public string Email { get; set; } = default!;
}

public class UnsubscribeRequest
{
    public string Token { get; set; } = default!;
}

public class CreateCampaignRequest
{
    public string Title { get; set; } = default!;
    public string Subject { get; set; } = default!;
    public string? Preheader { get; set; }
    public string? HtmlBody { get; set; }
    public string? PlainBody { get; set; }
    public string Segment { get; set; } = "all_subscribed";
}

public class UpdateCampaignRequest
{
    public string Title { get; set; } = default!;
    public string Subject { get; set; } = default!;
    public string? Preheader { get; set; }
    public string? HtmlBody { get; set; }
    public string? PlainBody { get; set; }
    public string Segment { get; set; } = "all_subscribed";
}