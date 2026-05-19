-- Adds Google federated login support for existing databases.
-- Safe to run multiple times.

DO $$
BEGIN
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

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_google_subject_uq
    ON public.users (google_subject)
    WHERE google_subject IS NOT NULL;
