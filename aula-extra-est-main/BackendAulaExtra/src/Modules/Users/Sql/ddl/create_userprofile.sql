CREATE TABLE IF NOT EXISTS public.user_profile (
    user_id UUID NOT NULL PRIMARY KEY,
    total_spent DECIMAL(18,2),
    reset_password_token_expiry TIMESTAMPTZ,
    reset_password_token VARCHAR(256),
    email_verification_token VARCHAR(256),
    prefered_language VARCHAR(16),
    status VARCHAR(20),
    phone VARCHAR(64),
    email_verified_at TIMESTAMPTZ,
    inactive BOOLEAN,
    creation_date TIMESTAMPTZ,
    last_update TIMESTAMPTZ,
    last_user_id UUID,

    -- FOREIGN KEYS
    CONSTRAINT fk_user_profile_user
        FOREIGN KEY (user_id)
        REFERENCES public.users (id_user),

    CONSTRAINT fk_user_profile_last_user
        FOREIGN KEY (last_user_id)
        REFERENCES public.users (id_user)
);
