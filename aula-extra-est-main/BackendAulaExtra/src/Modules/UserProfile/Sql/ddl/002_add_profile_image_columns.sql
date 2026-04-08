ALTER TABLE public.userprofiles
    ADD COLUMN IF NOT EXISTS profile_image_url TEXT,
    ADD COLUMN IF NOT EXISTS profile_image_thumbnail_url TEXT,
    ADD COLUMN IF NOT EXISTS profile_image_cloudflare_id TEXT,
    ADD COLUMN IF NOT EXISTS profile_image_provider VARCHAR(50),
    ADD COLUMN IF NOT EXISTS profile_image_source VARCHAR(50);