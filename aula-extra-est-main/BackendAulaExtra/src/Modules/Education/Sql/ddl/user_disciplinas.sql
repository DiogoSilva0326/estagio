-- Relation: user -> disciplinas (student areas/preferences)

CREATE TABLE IF NOT EXISTS public.user_disciplina (
  user_id UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
  id_disciplina UUID NOT NULL REFERENCES public.disciplinas(id_disciplina) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT now(),
  PRIMARY KEY (user_id, id_disciplina)
);

CREATE INDEX IF NOT EXISTS idx_user_disciplina_user_id ON public.user_disciplina(user_id);
CREATE INDEX IF NOT EXISTS idx_user_disciplina_disciplina_id ON public.user_disciplina(id_disciplina);
