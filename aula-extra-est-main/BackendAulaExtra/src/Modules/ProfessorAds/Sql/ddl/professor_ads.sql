CREATE TABLE IF NOT EXISTS public.professor_ads (
  id_professor_ad UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID NOT NULL REFERENCES public.professors(id_professor) ON DELETE CASCADE,
  id_course UUID NOT NULL REFERENCES public.courses(id_course) ON DELETE CASCADE,
  photo_url VARCHAR(500),
  status VARCHAR(30) NOT NULL DEFAULT 'published',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT uq_professor_ads_course UNIQUE (id_course)
);

CREATE INDEX IF NOT EXISTS idx_professor_ads_professor_id ON public.professor_ads(id_professor);
CREATE INDEX IF NOT EXISTS idx_professor_ads_status ON public.professor_ads(status);
