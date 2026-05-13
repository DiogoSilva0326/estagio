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