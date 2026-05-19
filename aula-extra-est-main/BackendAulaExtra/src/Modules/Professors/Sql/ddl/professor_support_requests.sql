CREATE TABLE IF NOT EXISTS public.professor_support_requests (
  id_professor_support_request UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID NOT NULL REFERENCES public.professors(id_professor) ON DELETE CASCADE,
  support_type VARCHAR(32) NOT NULL,
  is_approved BOOLEAN NOT NULL DEFAULT FALSE,
  approved_by_user_id UUID REFERENCES public.users(id_user),
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT ck_professor_support_requests_type
    CHECK (support_type IN ('professor', 'tutor', 'psicologo')),
  CONSTRAINT ux_professor_support_requests_unique
    UNIQUE (id_professor, support_type)
);

CREATE INDEX IF NOT EXISTS ix_professor_support_requests_professor
  ON public.professor_support_requests (id_professor);

CREATE INDEX IF NOT EXISTS ix_professor_support_requests_type_status
  ON public.professor_support_requests (support_type, is_approved);
