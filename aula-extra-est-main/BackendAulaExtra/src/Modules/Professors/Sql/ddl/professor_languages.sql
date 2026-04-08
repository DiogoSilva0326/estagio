CREATE TABLE IF NOT EXISTS public.languages (
  id_language UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(120) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.professor_languages (
  id_professor UUID NOT NULL REFERENCES public.professors(id_professor) ON DELETE CASCADE,
  id_language UUID NOT NULL REFERENCES public.languages(id_language) ON DELETE CASCADE,
  proficiency_level VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (id_professor, id_language)
);

CREATE INDEX IF NOT EXISTS idx_professor_languages_professor_id
  ON public.professor_languages(id_professor);

CREATE INDEX IF NOT EXISTS idx_professor_languages_language_id
  ON public.professor_languages(id_language);