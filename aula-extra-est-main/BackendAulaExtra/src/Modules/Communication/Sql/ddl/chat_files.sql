ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS metadata TEXT;

DO $$
DECLARE
    id_type TEXT;
    uploaded_type TEXT;
    message_type TEXT;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'chat_files'
    ) THEN
        SELECT data_type
          INTO id_type
          FROM information_schema.columns
         WHERE table_schema = 'public'
           AND table_name = 'chat_files'
           AND column_name = 'id';

        SELECT data_type
          INTO uploaded_type
          FROM information_schema.columns
         WHERE table_schema = 'public'
           AND table_name = 'chat_files'
           AND column_name = 'uploaded_by_user_id';

        SELECT data_type
          INTO message_type
          FROM information_schema.columns
         WHERE table_schema = 'public'
           AND table_name = 'chat_files'
           AND column_name = 'message_id';

        IF id_type IS DISTINCT FROM 'uuid'
           OR uploaded_type IS DISTINCT FROM 'uuid'
           OR message_type IS DISTINCT FROM 'uuid' THEN
            EXECUTE 'ALTER TABLE public.chat_files RENAME TO chat_files_legacy_' || to_char(now(), 'YYYYMMDDHH24MISS');
        END IF;
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.chat_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id VARCHAR(255) NOT NULL UNIQUE,
    file_name VARCHAR(500) NOT NULL,
    storage_path VARCHAR(1000) NOT NULL,
    content_type VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    uploaded_by_user_id UUID NULL,
    room_id VARCHAR(255) NULL,
    message_id UUID NULL,
    thumbnail_url VARCHAR(500) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    CONSTRAINT chat_files_uploaded_by_user_id_fkey FOREIGN KEY (uploaded_by_user_id)
        REFERENCES public.users (id_user) ON DELETE SET NULL,
    CONSTRAINT chat_files_message_id_fkey FOREIGN KEY (message_id)
        REFERENCES public.messages (id_message) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_chat_files_file_id ON public.chat_files (file_id);
CREATE INDEX IF NOT EXISTS idx_chat_files_uploaded_by_user_id ON public.chat_files (uploaded_by_user_id);
CREATE INDEX IF NOT EXISTS idx_chat_files_room_id ON public.chat_files (room_id);
CREATE INDEX IF NOT EXISTS idx_chat_files_message_id ON public.chat_files (message_id);
CREATE INDEX IF NOT EXISTS idx_chat_files_is_active ON public.chat_files (is_active);