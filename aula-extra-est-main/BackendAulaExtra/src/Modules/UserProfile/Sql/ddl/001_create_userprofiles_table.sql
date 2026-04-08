-- UserProfile Table DDL
-- Creates the userprofiles table with all necessary fields

CREATE TABLE IF NOT EXISTS public.userprofiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    total_spent NUMERIC(18,2) DEFAULT 0,
    reset_password_token TEXT,
    reset_password_token_expiry TIMESTAMP,
    email_verification_token TEXT,
    email_verified_at TIMESTAMP,
    prefered_language VARCHAR(10) DEFAULT 'pt-PT',
    status VARCHAR(50) DEFAULT 'active',
    phone VARCHAR(20),
    profile_image_url TEXT,
    profile_image_thumbnail_url TEXT,
    profile_image_cloudflare_id TEXT,
    profile_image_provider VARCHAR(50),
    profile_image_source VARCHAR(50),
    creation_date TIMESTAMP DEFAULT NOW(),
    last_update TIMESTAMP DEFAULT NOW(),
    inactive BOOLEAN DEFAULT FALSE
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_userprofiles_user'
    ) THEN
        ALTER TABLE public.userprofiles
            ADD CONSTRAINT fk_userprofiles_user
            FOREIGN KEY (user_id)
            REFERENCES public.users (id_user)
            ON DELETE CASCADE;
    END IF;
END$$;

-- Create index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_userprofiles_user_id ON public.userprofiles(user_id);
