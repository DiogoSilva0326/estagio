CREATE TABLE IF NOT EXISTS public.user_consents (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    consent_type VARCHAR(200) NOT NULL,
    granted BOOLEAN NOT NULL,
    granted_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    ip_address VARCHAR(100),
    inactive BOOLEAN,
    creation_date TIMESTAMPTZ,
    last_update TIMESTAMPTZ,
    last_user_id UUID,

    -- FOREIGN KEYS
    CONSTRAINT fk_user_consents_user
        FOREIGN KEY (user_id)
        REFERENCES public.users (id_user),

    CONSTRAINT fk_user_consents_last_user
        FOREIGN KEY (last_user_id)
        REFERENCES public.users (id_user)
);

CREATE INDEX IF NOT EXISTS idx_user_consents_user_id ON public.user_consents(user_id);
