-- API data tables (Agora Calls / Whiteboard / Chat)
-- Matches the updated class diagram entities:
-- calls_api_data, whiteboard_api_data, chat_api_data, management_statuses, api_data

CREATE TABLE IF NOT EXISTS public.calls_api_data (
  id_calls_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_name VARCHAR(255),
  project_name VARCHAR(255),
  app_id VARCHAR(255),
  primary_certificate VARCHAR(255),
  channel_token TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_calls_api_data_channel_name ON public.calls_api_data (channel_name);

CREATE TABLE IF NOT EXISTS public.whiteboard_api_data (
  id_whiteboard_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_name VARCHAR(255),
  project_name VARCHAR(255),
  app_identifier VARCHAR(255),
  sdk_token TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_whiteboard_api_data_channel_name ON public.whiteboard_api_data (channel_name);

CREATE TABLE IF NOT EXISTS public.chat_api_data (
  id_chat_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NULL,
  chat_user_temp_token VARCHAR(255),
  chat_app_temp_token VARCHAR(255),
  appkey VARCHAR(255),
  orgname VARCHAR(255),
  appname VARCHAR(255),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT fk_chat_api_data_user FOREIGN KEY (id_user)
    REFERENCES public.users (id_user) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_chat_api_data_user ON public.chat_api_data (id_user);

CREATE TABLE IF NOT EXISTS public.management_statuses (
  id_management_status UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  status_name VARCHAR(255),
  description TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_management_statuses_status_name ON public.management_statuses (status_name);

CREATE TABLE IF NOT EXISTS public.api_data (
  id_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  managed_by_user_id UUID NULL,
  id_professor UUID NOT NULL,
  id_calls_api_data UUID NULL,
  id_whiteboard_api_data UUID NULL,
  id_chat_api_data UUID NULL,
  id_management_status UUID NULL,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),

  CONSTRAINT fk_api_data_managed_by_user FOREIGN KEY (managed_by_user_id)
    REFERENCES public.users (id_user) ON DELETE SET NULL,
  CONSTRAINT fk_api_data_professor FOREIGN KEY (id_professor)
    REFERENCES public.professors (id_professor) ON DELETE CASCADE,
  CONSTRAINT fk_api_data_calls FOREIGN KEY (id_calls_api_data)
    REFERENCES public.calls_api_data (id_calls_api_data) ON DELETE SET NULL,
  CONSTRAINT fk_api_data_whiteboard FOREIGN KEY (id_whiteboard_api_data)
    REFERENCES public.whiteboard_api_data (id_whiteboard_api_data) ON DELETE SET NULL,
  CONSTRAINT fk_api_data_chat FOREIGN KEY (id_chat_api_data)
    REFERENCES public.chat_api_data (id_chat_api_data) ON DELETE SET NULL,
  CONSTRAINT fk_api_data_management_status FOREIGN KEY (id_management_status)
    REFERENCES public.management_statuses (id_management_status) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_api_data_professor ON public.api_data (id_professor);
CREATE INDEX IF NOT EXISTS idx_api_data_managed_by_user ON public.api_data (managed_by_user_id);
CREATE INDEX IF NOT EXISTS idx_api_data_management_status ON public.api_data (id_management_status);
