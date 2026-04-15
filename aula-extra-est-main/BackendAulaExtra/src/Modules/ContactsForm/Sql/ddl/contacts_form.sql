CREATE TABLE IF NOT EXISTS public.contact_form_categories (
  id_contact_form_category UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_contact_form_categories_name_ci
  ON public.contact_form_categories (LOWER(name));

CREATE TABLE IF NOT EXISTS public.contact_form_submissions (
  id_contact_form_submission UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_contact_form_category UUID NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'não lida',
  user_id UUID NULL,
  user_id_response UUID NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT fk_contact_form_submissions_category FOREIGN KEY (id_contact_form_category)
    REFERENCES public.contact_form_categories (id_contact_form_category) ON DELETE SET NULL,
  CONSTRAINT fk_contact_form_submissions_user FOREIGN KEY (user_id)
    REFERENCES public.users (id_user) ON DELETE SET NULL,
  CONSTRAINT fk_contact_form_submissions_response_user FOREIGN KEY (user_id_response)
    REFERENCES public.users (id_user) ON DELETE SET NULL,
  CONSTRAINT chk_contact_form_submissions_status CHECK (status IN ('não lida', 'lida', 'respondida', 'arquivada'))
);

CREATE INDEX IF NOT EXISTS idx_contact_form_submissions_status
  ON public.contact_form_submissions (status);

CREATE INDEX IF NOT EXISTS idx_contact_form_submissions_user_id
  ON public.contact_form_submissions (user_id);

CREATE INDEX IF NOT EXISTS idx_contact_form_submissions_category_id
  ON public.contact_form_submissions (id_contact_form_category);

INSERT INTO public.contact_form_categories (name, description)
VALUES
  ('Informações gerais', 'Dúvidas gerais sobre a plataforma Aula Extra.'),
  ('Pagamentos', 'Questões relacionadas com pagamentos, créditos e faturação.'),
  ('Suporte técnico', 'Problemas técnicos com o website ou a aplicação.'),
  ('Parcerias', 'Pedidos comerciais, institucionais ou de parceria.')
ON CONFLICT DO NOTHING;
