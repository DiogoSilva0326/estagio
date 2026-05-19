-- PostgreSQL DDL for Users table
-- NOTE: This schema uses UUIDs as the primary key.
-- The DB bootstrap already enables `pgcrypto`, so `gen_random_uuid()` is available.

CREATE TABLE IF NOT EXISTS public.users (
    id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),
    first_name VARCHAR(200),
    last_name VARCHAR(200),
    education_level TEXT NULL,
    biography TEXT NULL,
    birth_date VARCHAR(50),
    auth_message TEXT,
    username TEXT NOT NULL UNIQUE,
    display_name TEXT NULL,
    mobile_number VARCHAR(64),
    phone_number VARCHAR(64),
    company_name TEXT NULL,
    website TEXT NULL,
    google_subject VARCHAR(255) NULL,
    nif VARCHAR(64),
    inactive BOOLEAN NOT NULL DEFAULT false,
    creation_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_update TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_user_id UUID NULL
);

DO $$
BEGIN
    -- Optional education level (added later)
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'users'
          AND column_name = 'education_level'
    ) THEN
        ALTER TABLE public.users ADD COLUMN education_level TEXT NULL;
    END IF;

    -- Optional biography
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'users'
          AND column_name = 'biography'
    ) THEN
        ALTER TABLE public.users ADD COLUMN biography TEXT NULL;
    END IF;

    -- Ensure username is not null (backfill safety for older imports)
    UPDATE public.users
    SET username = COALESCE(username, email)
    WHERE username IS NULL;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'users'
          AND column_name = 'username'
          AND is_nullable = 'YES'
    ) THEN
        ALTER TABLE public.users ALTER COLUMN username SET NOT NULL;
    END IF;

    -- Optional self-reference (audit)
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_users_last_user'
    ) THEN
        ALTER TABLE public.users
            ADD CONSTRAINT fk_users_last_user
            FOREIGN KEY (last_user_id)
            REFERENCES public.users (id_user)
            ON DELETE SET NULL;
    END IF;

    -- Optional Google OAuth subject for federated login
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'users'
          AND column_name = 'google_subject'
    ) THEN
        ALTER TABLE public.users ADD COLUMN google_subject VARCHAR(255) NULL;
    END IF;
END
$$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_username ON public.users (username);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users (lower(email));
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_google_subject_uq ON public.users (google_subject) WHERE google_subject IS NOT NULL;
