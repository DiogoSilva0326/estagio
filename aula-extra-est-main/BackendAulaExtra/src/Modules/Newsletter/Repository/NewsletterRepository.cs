using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Newsletter.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Newsletter.Repository;

public class NewsletterRepository : INewsletterRepository
{
    private const string EnsureSchemaSql = @"
CREATE TABLE IF NOT EXISTS public.newsletter_subscribers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    locale TEXT NOT NULL DEFAULT 'pt-PT',
    source TEXT,
    confirm_token TEXT,
    confirm_token_expires_at TIMESTAMPTZ,
    unsubscribe_token TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
    confirmed_at TIMESTAMPTZ,
    unsubscribed_at TIMESTAMPTZ,
    bounced_at TIMESTAMPTZ,
    lastupdate TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
    inactive BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_newsletter_subscribers_email
    ON public.newsletter_subscribers (LOWER(email));

CREATE INDEX IF NOT EXISTS idx_newsletter_subscribers_confirm_token
    ON public.newsletter_subscribers (confirm_token)
    WHERE confirm_token IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.newsletter_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subject TEXT NOT NULL,
    preheader TEXT,
    html_body TEXT,
    plain_body TEXT,
    status TEXT NOT NULL DEFAULT 'draft',
    segment TEXT NOT NULL DEFAULT 'all_subscribed',
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    total_recipients INT NOT NULL DEFAULT 0,
    total_sent INT NOT NULL DEFAULT 0,
    total_failed INT NOT NULL DEFAULT 0,
    times_sent INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
    lastupdate TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
    inactive BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS public.newsletter_sends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES public.newsletter_campaigns(id) ON DELETE CASCADE,
    subscriber_id UUID NOT NULL REFERENCES public.newsletter_subscribers(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'queued',
    postmark_message_id TEXT,
    sent_at TIMESTAMPTZ,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (now() AT TIME ZONE 'utc')
);

CREATE INDEX IF NOT EXISTS idx_newsletter_sends_campaign
    ON public.newsletter_sends (campaign_id);

CREATE INDEX IF NOT EXISTS idx_newsletter_sends_subscriber
    ON public.newsletter_sends (subscriber_id);
";

    private readonly string _connectionString;

    public NewsletterRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    private static async Task EnsureSchemaAsync(NpgsqlConnection conn, CancellationToken cancellationToken)
    {
        await using var cmd = new NpgsqlCommand(EnsureSchemaSql, conn);
        await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task<NewsletterSubscriber?> GetSubscriberByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand("SELECT * FROM public.newsletter_subscribers WHERE LOWER(email) = LOWER(@email) LIMIT 1", conn);
        cmd.Parameters.AddWithValue("email", email);
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken) ? MapSubscriber(reader) : null;
    }

    public async Task<NewsletterSubscriber?> GetSubscriberByConfirmTokenAsync(string token, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand("SELECT * FROM public.newsletter_subscribers WHERE confirm_token = @token LIMIT 1", conn);
        cmd.Parameters.AddWithValue("token", token);
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken) ? MapSubscriber(reader) : null;
    }

    public async Task<NewsletterSubscriber?> GetSubscriberByUnsubscribeTokenAsync(string token, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand("SELECT * FROM public.newsletter_subscribers WHERE unsubscribe_token = @token LIMIT 1", conn);
        cmd.Parameters.AddWithValue("token", token);
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken) ? MapSubscriber(reader) : null;
    }

    public async Task<Guid> InsertSubscriberAsync(NewsletterSubscriber subscriber, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        var id = subscriber.Id == Guid.Empty ? Guid.NewGuid() : subscriber.Id;
        await using var cmd = new NpgsqlCommand(@"
            INSERT INTO public.newsletter_subscribers
                (id, email, status, locale, source, confirm_token, confirm_token_expires_at, unsubscribe_token, created_at, lastupdate)
            VALUES
                (@id, @email, @status, @locale, @source, @confirm_token, @confirm_token_expires_at, @unsubscribe_token, (now() AT TIME ZONE 'utc'), (now() AT TIME ZONE 'utc'))
        ", conn);
        cmd.Parameters.AddWithValue("id", id);
        cmd.Parameters.AddWithValue("email", subscriber.Email.Trim().ToLowerInvariant());
        cmd.Parameters.AddWithValue("status", subscriber.Status);
        cmd.Parameters.AddWithValue("locale", subscriber.Locale);
        cmd.Parameters.AddWithValue("source", (object?)subscriber.Source ?? DBNull.Value);
        cmd.Parameters.AddWithValue("confirm_token", (object?)subscriber.ConfirmToken ?? DBNull.Value);
        cmd.Parameters.AddWithValue("confirm_token_expires_at", (object?)subscriber.ConfirmTokenExpiresAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("unsubscribe_token", (object?)subscriber.UnsubscribeToken ?? DBNull.Value);
        await cmd.ExecuteNonQueryAsync(cancellationToken);
        return id;
    }

    public async Task<bool> UpdateSubscriberAsync(NewsletterSubscriber subscriber, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand(@"
            UPDATE public.newsletter_subscribers SET
                status = @status,
                locale = @locale,
                source = @source,
                confirm_token = @confirm_token,
                confirm_token_expires_at = @confirm_token_expires_at,
                unsubscribe_token = @unsubscribe_token,
                confirmed_at = @confirmed_at,
                unsubscribed_at = @unsubscribed_at,
                bounced_at = @bounced_at,
                inactive = @inactive,
                lastupdate = (now() AT TIME ZONE 'utc')
            WHERE id = @id
        ", conn);
        cmd.Parameters.AddWithValue("id", subscriber.Id);
        cmd.Parameters.AddWithValue("status", subscriber.Status);
        cmd.Parameters.AddWithValue("locale", subscriber.Locale);
        cmd.Parameters.AddWithValue("source", (object?)subscriber.Source ?? DBNull.Value);
        cmd.Parameters.AddWithValue("confirm_token", (object?)subscriber.ConfirmToken ?? DBNull.Value);
        cmd.Parameters.AddWithValue("confirm_token_expires_at", (object?)subscriber.ConfirmTokenExpiresAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("unsubscribe_token", (object?)subscriber.UnsubscribeToken ?? DBNull.Value);
        cmd.Parameters.AddWithValue("confirmed_at", (object?)subscriber.ConfirmedAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("unsubscribed_at", (object?)subscriber.UnsubscribedAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("bounced_at", (object?)subscriber.BouncedAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("inactive", subscriber.Inactive);
        return await cmd.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    public async Task<bool> MarkBouncedAsync(string email, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand(@"
            UPDATE public.newsletter_subscribers SET
                status = 'bounced',
                bounced_at = (now() AT TIME ZONE 'utc'),
                lastupdate = (now() AT TIME ZONE 'utc')
            WHERE LOWER(email) = LOWER(@email)
              AND status <> 'bounced'
        ", conn);
        cmd.Parameters.AddWithValue("email", email);
        return await cmd.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    public async Task<List<NewsletterSubscriber>> GetActiveSubscribersAsync(string? segment = null, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        var sql = "SELECT * FROM public.newsletter_subscribers WHERE status = 'subscribed' AND inactive = FALSE";
        sql += " ORDER BY email";
        await using var cmd = new NpgsqlCommand(sql, conn);
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        var list = new List<NewsletterSubscriber>();
        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(MapSubscriber(reader));
        }
        return list;
    }

    public async Task<int> GetActiveSubscriberCountAsync(CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand("SELECT COUNT(*) FROM public.newsletter_subscribers WHERE status = 'subscribed' AND inactive = FALSE", conn);
        var result = await cmd.ExecuteScalarAsync(cancellationToken);
        return Convert.ToInt32(result);
    }

    public async Task<Guid> InsertCampaignAsync(NewsletterCampaign campaign, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        var id = campaign.Id == Guid.Empty ? Guid.NewGuid() : campaign.Id;
        await using var cmd = new NpgsqlCommand(@"
            INSERT INTO public.newsletter_campaigns
                (id, title, subject, preheader, html_body, plain_body, status, segment, created_at, lastupdate)
            VALUES
                (@id, @title, @subject, @preheader, @html_body, @plain_body, @status, @segment, (now() AT TIME ZONE 'utc'), (now() AT TIME ZONE 'utc'))
        ", conn);
        cmd.Parameters.AddWithValue("id", id);
        cmd.Parameters.AddWithValue("title", campaign.Title);
        cmd.Parameters.AddWithValue("subject", campaign.Subject);
        cmd.Parameters.AddWithValue("preheader", (object?)campaign.Preheader ?? DBNull.Value);
        cmd.Parameters.AddWithValue("html_body", (object?)campaign.HtmlBody ?? DBNull.Value);
        cmd.Parameters.AddWithValue("plain_body", (object?)campaign.PlainBody ?? DBNull.Value);
        cmd.Parameters.AddWithValue("status", campaign.Status);
        cmd.Parameters.AddWithValue("segment", campaign.Segment);
        await cmd.ExecuteNonQueryAsync(cancellationToken);
        return id;
    }

    public async Task<NewsletterCampaign?> GetCampaignByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand("SELECT * FROM public.newsletter_campaigns WHERE id = @id", conn);
        cmd.Parameters.AddWithValue("id", id);
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken) ? MapCampaign(reader) : null;
    }

    public async Task<bool> UpdateCampaignAsync(NewsletterCampaign campaign, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand(@"
            UPDATE public.newsletter_campaigns SET
                title = @title,
                subject = @subject,
                preheader = @preheader,
                html_body = @html_body,
                plain_body = @plain_body,
                status = @status,
                segment = @segment,
                scheduled_at = @scheduled_at,
                sent_at = @sent_at,
                total_recipients = @total_recipients,
                total_sent = @total_sent,
                total_failed = @total_failed,
                times_sent = @times_sent,
                lastupdate = (now() AT TIME ZONE 'utc')
            WHERE id = @id
        ", conn);
        cmd.Parameters.AddWithValue("id", campaign.Id);
        cmd.Parameters.AddWithValue("title", campaign.Title);
        cmd.Parameters.AddWithValue("subject", campaign.Subject);
        cmd.Parameters.AddWithValue("preheader", (object?)campaign.Preheader ?? DBNull.Value);
        cmd.Parameters.AddWithValue("html_body", (object?)campaign.HtmlBody ?? DBNull.Value);
        cmd.Parameters.AddWithValue("plain_body", (object?)campaign.PlainBody ?? DBNull.Value);
        cmd.Parameters.AddWithValue("status", campaign.Status);
        cmd.Parameters.AddWithValue("segment", campaign.Segment);
        cmd.Parameters.AddWithValue("scheduled_at", (object?)campaign.ScheduledAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("sent_at", (object?)campaign.SentAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("total_recipients", campaign.TotalRecipients);
        cmd.Parameters.AddWithValue("total_sent", campaign.TotalSent);
        cmd.Parameters.AddWithValue("total_failed", campaign.TotalFailed);
        cmd.Parameters.AddWithValue("times_sent", campaign.TimesSent);
        return await cmd.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    public async Task<bool> UpdateCampaignContentAsync(Guid id, string title, string subject, string? preheader, string? htmlBody, string? plainBody, string segment, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand(@"
            UPDATE public.newsletter_campaigns SET
                title = @title,
                subject = @subject,
                preheader = @preheader,
                html_body = @html_body,
                plain_body = @plain_body,
                segment = @segment,
                lastupdate = (now() AT TIME ZONE 'utc')
            WHERE id = @id
        ", conn);
        cmd.Parameters.AddWithValue("id", id);
        cmd.Parameters.AddWithValue("title", title);
        cmd.Parameters.AddWithValue("subject", subject);
        cmd.Parameters.AddWithValue("preheader", (object?)preheader ?? DBNull.Value);
        cmd.Parameters.AddWithValue("html_body", (object?)htmlBody ?? DBNull.Value);
        cmd.Parameters.AddWithValue("plain_body", (object?)plainBody ?? DBNull.Value);
        cmd.Parameters.AddWithValue("segment", segment);
        return await cmd.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    public async Task<bool> DeleteCampaignAsync(Guid id, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand("DELETE FROM public.newsletter_campaigns WHERE id = @id", conn);
        cmd.Parameters.AddWithValue("id", id);
        return await cmd.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    public async Task<List<NewsletterCampaign>> GetCampaignsAsync(int pageNumber = 1, int pageSize = 20, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand(@"
            SELECT *
              FROM public.newsletter_campaigns
             WHERE inactive = FALSE
             ORDER BY created_at DESC
             LIMIT @page_size OFFSET (@page_number - 1) * @page_size
        ", conn);
        cmd.Parameters.AddWithValue("page_number", pageNumber);
        cmd.Parameters.AddWithValue("page_size", pageSize);
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        var list = new List<NewsletterCampaign>();
        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(MapCampaign(reader));
        }
        return list;
    }

    public async Task<Guid> InsertSendAsync(NewsletterSend send, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        var id = send.Id == Guid.Empty ? Guid.NewGuid() : send.Id;
        await using var cmd = new NpgsqlCommand(@"
            INSERT INTO public.newsletter_sends
                (id, campaign_id, subscriber_id, email, status, postmark_message_id, sent_at, error_message, created_at)
            VALUES
                (@id, @campaign_id, @subscriber_id, @email, @status, @postmark_message_id, @sent_at, @error_message, (now() AT TIME ZONE 'utc'))
        ", conn);
        cmd.Parameters.AddWithValue("id", id);
        cmd.Parameters.AddWithValue("campaign_id", send.CampaignId);
        cmd.Parameters.AddWithValue("subscriber_id", send.SubscriberId);
        cmd.Parameters.AddWithValue("email", send.Email);
        cmd.Parameters.AddWithValue("status", send.Status);
        cmd.Parameters.AddWithValue("postmark_message_id", (object?)send.PostmarkMessageId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("sent_at", (object?)send.SentAt ?? DBNull.Value);
        cmd.Parameters.AddWithValue("error_message", (object?)send.ErrorMessage ?? DBNull.Value);
        await cmd.ExecuteNonQueryAsync(cancellationToken);
        return id;
    }

    public async Task<bool> UpdateSendStatusAsync(Guid sendId, string status, string? postmarkMessageId = null, string? errorMessage = null, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);
        await using var cmd = new NpgsqlCommand(@"
            UPDATE public.newsletter_sends SET
                status = @status,
                postmark_message_id = @postmark_message_id,
                error_message = @error_message,
                sent_at = CASE WHEN @status = 'sent' THEN (now() AT TIME ZONE 'utc') ELSE sent_at END
             WHERE id = @id
        ", conn);
        cmd.Parameters.AddWithValue("id", sendId);
        cmd.Parameters.AddWithValue("status", status);
        cmd.Parameters.AddWithValue("postmark_message_id", (object?)postmarkMessageId ?? DBNull.Value);
        cmd.Parameters.AddWithValue("error_message", (object?)errorMessage ?? DBNull.Value);
        return await cmd.ExecuteNonQueryAsync(cancellationToken) > 0;
    }

    private static NewsletterSubscriber MapSubscriber(NpgsqlDataReader reader)
    {
        return new NewsletterSubscriber
        {
            Id = reader.GetFieldValue<Guid>(reader.GetOrdinal("id")),
            Email = reader.GetString(reader.GetOrdinal("email")),
            Status = reader.GetString(reader.GetOrdinal("status")),
            Locale = reader.GetString(reader.GetOrdinal("locale")),
            Source = reader.IsDBNull(reader.GetOrdinal("source")) ? null : reader.GetString(reader.GetOrdinal("source")),
            ConfirmToken = reader.IsDBNull(reader.GetOrdinal("confirm_token")) ? null : reader.GetString(reader.GetOrdinal("confirm_token")),
            ConfirmTokenExpiresAt = reader.IsDBNull(reader.GetOrdinal("confirm_token_expires_at")) ? null : reader.GetFieldValue<DateTime?>(reader.GetOrdinal("confirm_token_expires_at")),
            UnsubscribeToken = reader.IsDBNull(reader.GetOrdinal("unsubscribe_token")) ? null : reader.GetString(reader.GetOrdinal("unsubscribe_token")),
            CreatedAt = reader.GetFieldValue<DateTime>(reader.GetOrdinal("created_at")),
            ConfirmedAt = reader.IsDBNull(reader.GetOrdinal("confirmed_at")) ? null : reader.GetFieldValue<DateTime?>(reader.GetOrdinal("confirmed_at")),
            UnsubscribedAt = reader.IsDBNull(reader.GetOrdinal("unsubscribed_at")) ? null : reader.GetFieldValue<DateTime?>(reader.GetOrdinal("unsubscribed_at")),
            BouncedAt = reader.IsDBNull(reader.GetOrdinal("bounced_at")) ? null : reader.GetFieldValue<DateTime?>(reader.GetOrdinal("bounced_at")),
            LastUpdate = reader.GetFieldValue<DateTime>(reader.GetOrdinal("lastupdate")),
            Inactive = reader.GetBoolean(reader.GetOrdinal("inactive")),
        };
    }

    private static NewsletterCampaign MapCampaign(NpgsqlDataReader reader)
    {
        return new NewsletterCampaign
        {
            Id = reader.GetFieldValue<Guid>(reader.GetOrdinal("id")),
            Title = reader.GetString(reader.GetOrdinal("title")),
            Subject = reader.GetString(reader.GetOrdinal("subject")),
            Preheader = reader.IsDBNull(reader.GetOrdinal("preheader")) ? null : reader.GetString(reader.GetOrdinal("preheader")),
            HtmlBody = reader.IsDBNull(reader.GetOrdinal("html_body")) ? null : reader.GetString(reader.GetOrdinal("html_body")),
            PlainBody = reader.IsDBNull(reader.GetOrdinal("plain_body")) ? null : reader.GetString(reader.GetOrdinal("plain_body")),
            Status = reader.GetString(reader.GetOrdinal("status")),
            Segment = reader.GetString(reader.GetOrdinal("segment")),
            ScheduledAt = reader.IsDBNull(reader.GetOrdinal("scheduled_at")) ? null : reader.GetFieldValue<DateTime?>(reader.GetOrdinal("scheduled_at")),
            SentAt = reader.IsDBNull(reader.GetOrdinal("sent_at")) ? null : reader.GetFieldValue<DateTime?>(reader.GetOrdinal("sent_at")),
            TotalRecipients = reader.GetInt32(reader.GetOrdinal("total_recipients")),
            TotalSent = reader.GetInt32(reader.GetOrdinal("total_sent")),
            TotalFailed = reader.GetInt32(reader.GetOrdinal("total_failed")),
            TimesSent = reader.GetInt32(reader.GetOrdinal("times_sent")),
            CreatedAt = reader.GetFieldValue<DateTime>(reader.GetOrdinal("created_at")),
            LastUpdate = reader.GetFieldValue<DateTime>(reader.GetOrdinal("lastupdate")),
            Inactive = reader.GetBoolean(reader.GetOrdinal("inactive")),
        };
    }
}