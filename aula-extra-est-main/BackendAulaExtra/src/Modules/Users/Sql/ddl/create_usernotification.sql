CREATE TABLE IF NOT EXISTS public.user_notification (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(80) NOT NULL,
    message VARCHAR(500) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    inactive BOOLEAN,
    creation_date TIMESTAMPTZ,
    last_update TIMESTAMPTZ,
    last_user_id UUID,

    -- FOREIGN KEYS
    CONSTRAINT fk_user_notification_last_user
        FOREIGN KEY (last_user_id)
        REFERENCES public.users (id_user),

    CONSTRAINT fk_user_notification_user
        FOREIGN KEY (user_id)
        REFERENCES public.users (id_user)
);

CREATE INDEX IF NOT EXISTS idx_user_notification_user_id ON public.user_notification(user_id);
