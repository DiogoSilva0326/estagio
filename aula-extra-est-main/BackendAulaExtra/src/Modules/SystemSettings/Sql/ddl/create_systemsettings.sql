CREATE TABLE IF NOT EXISTS public.system_settings
(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    settings_key VARCHAR(100) NOT NULL UNIQUE,
    settings_value TEXT,
    data_type VARCHAR(50),
    description VARCHAR(500),
    PRIMARY KEY (id)
);