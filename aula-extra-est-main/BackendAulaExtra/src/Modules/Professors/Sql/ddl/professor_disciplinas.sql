-- Relation: professor -> disciplinas (disciplines taught)

CREATE TABLE IF NOT EXISTS public.professor_disciplina (
  id_professor UUID NOT NULL REFERENCES public.professors(id_professor) ON DELETE CASCADE,
  id_disciplina UUID NOT NULL REFERENCES public.disciplinas(id_disciplina) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT now(),
  PRIMARY KEY (id_professor, id_disciplina)
);

ALTER TABLE public.professor_disciplina
  ADD COLUMN IF NOT EXISTS id_area UUID,
  ADD COLUMN IF NOT EXISTS id_ciclo_estudo UUID,
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT now();

ALTER TABLE public.professor_disciplina
  DROP CONSTRAINT IF EXISTS fk_professor_disciplina_area;

ALTER TABLE public.professor_disciplina
  ADD CONSTRAINT fk_professor_disciplina_area
  FOREIGN KEY (id_area) REFERENCES public.areas(id_area)
  ON DELETE SET NULL;

ALTER TABLE public.professor_disciplina
  DROP CONSTRAINT IF EXISTS fk_professor_disciplina_ciclo_estudo;

ALTER TABLE public.professor_disciplina
  ADD CONSTRAINT fk_professor_disciplina_ciclo_estudo
  FOREIGN KEY (id_ciclo_estudo) REFERENCES public.ciclos_estudo(id_ciclo_estudo)
  ON DELETE SET NULL;

UPDATE public.professor_disciplina pd
SET id_area = d.id_area,
    updated_at = COALESCE(pd.updated_at, now())
FROM public.disciplinas d
WHERE pd.id_disciplina = d.id_disciplina
  AND pd.id_area IS NULL;

CREATE INDEX IF NOT EXISTS idx_professor_disciplina_professor_id ON public.professor_disciplina(id_professor);
CREATE INDEX IF NOT EXISTS idx_professor_disciplina_disciplina_id ON public.professor_disciplina(id_disciplina);
CREATE INDEX IF NOT EXISTS idx_professor_disciplina_is_active ON public.professor_disciplina(is_active);
CREATE INDEX IF NOT EXISTS idx_professor_disciplina_id_area ON public.professor_disciplina(id_area);
CREATE INDEX IF NOT EXISTS idx_professor_disciplina_id_ciclo_estudo ON public.professor_disciplina(id_ciclo_estudo);

DROP TRIGGER IF EXISTS trg_professor_disciplina_auto_create_course ON public.professor_disciplina;
DROP FUNCTION IF EXISTS public.trg_professor_disciplina_auto_create_course();

CREATE OR REPLACE FUNCTION public.trg_professor_disciplina_auto_create_course()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_disciplina_nome VARCHAR(200);
  v_default_pricing_model UUID;
  v_default_tutoring_type UUID;
BEGIN
  IF COALESCE(NEW.is_active, TRUE) = FALSE THEN
    RETURN NEW;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.courses c
    WHERE c.id_professor = NEW.id_professor
      AND c.id_disciplina = NEW.id_disciplina
  ) THEN
    UPDATE public.courses
    SET id_ciclo_estudo = COALESCE(NEW.id_ciclo_estudo, id_ciclo_estudo),
        updated_at = now()
    WHERE id_professor = NEW.id_professor
      AND id_disciplina = NEW.id_disciplina;

    RETURN NEW;
  END IF;

  SELECT NULLIF(BTRIM(d.nome), '')
    INTO v_disciplina_nome
  FROM public.disciplinas d
  WHERE d.id_disciplina = NEW.id_disciplina;

  SELECT pm.id_pricing_model
    INTO v_default_pricing_model
  FROM public.pricing_models pm
  ORDER BY
    CASE
      WHEN LOWER(BTRIM(pm.name)) IN ('preço por sessão', 'preco por sessao', 'preço sessão', 'preco sessao') THEN 0
      ELSE 1
    END,
    pm.created_at NULLS LAST,
    pm.id_pricing_model
  LIMIT 1;

  SELECT tt.id_tutoring_type
    INTO v_default_tutoring_type
  FROM public.tutoring_types tt
  ORDER BY
    CASE
      WHEN LOWER(BTRIM(tt.name)) IN ('individual', '1:1') THEN 0
      ELSE 1
    END,
    tt.created_at NULLS LAST,
    tt.id_tutoring_type
  LIMIT 1;

  INSERT INTO public.courses (
    id_professor,
    id_pricing_model,
    id_tutoring_type,
    id_disciplina,
    id_ciclo_estudo,
    name,
    description,
    num_max_students,
    num_min_students,
    created_at,
    updated_at
  )
  SELECT
    NEW.id_professor,
    v_default_pricing_model,
    v_default_tutoring_type,
    NEW.id_disciplina,
    NEW.id_ciclo_estudo,
    COALESCE(v_disciplina_nome, 'Disciplina'),
    'Curso criado automaticamente ao adicionar a disciplina ao perfil do professor.',
    1,
    1,
    now(),
    now()
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.courses c
    WHERE c.id_professor = NEW.id_professor
      AND c.id_disciplina = NEW.id_disciplina
  );

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_professor_disciplina_auto_create_course
AFTER INSERT OR UPDATE ON public.professor_disciplina
FOR EACH ROW
EXECUTE FUNCTION public.trg_professor_disciplina_auto_create_course();
