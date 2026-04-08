DROP FUNCTION IF EXISTS public.usp_professor_disciplinas_select_by_professor01(uuid);
DROP FUNCTION IF EXISTS public.usp_professor_disciplinas_set_for_professor01(uuid, uuid[]);
DROP FUNCTION IF EXISTS public.usp_professor_disciplinas_delete_for_professor01(uuid, uuid);

CREATE OR REPLACE FUNCTION public.usp_professor_disciplinas_select_by_professor01(
  p_id_professor uuid
)
RETURNS SETOF public.disciplinas
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT d.*
  FROM public.professor_disciplina pd
  JOIN public.disciplinas d ON d.id_disciplina = pd.id_disciplina
  WHERE pd.id_professor = p_id_professor
    AND COALESCE(pd.is_active, TRUE) = TRUE
  ORDER BY d.nome ASC;
END;
$$;

-- Replaces the set of disciplines taught by a professor.
-- Returns the number of selected disciplines after the operation.
CREATE OR REPLACE FUNCTION public.usp_professor_disciplinas_set_for_professor01(
  p_id_professor uuid,
  p_ids uuid[]
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer;
BEGIN
  UPDATE public.professor_disciplina
  SET is_active = FALSE,
      updated_at = now()
  WHERE id_professor = p_id_professor;

  IF p_ids IS NOT NULL AND array_length(p_ids, 1) IS NOT NULL THEN
    INSERT INTO public.professor_disciplina (
      id_professor,
      id_disciplina,
      id_area,
      id_ciclo_estudo,
      is_active,
      created_at,
      updated_at
    )
    SELECT
      p_id_professor,
      x,
      d.id_area,
      NULL,
      TRUE,
      now(),
      now()
    FROM unnest(p_ids) AS x
    JOIN public.disciplinas d ON d.id_disciplina = x
    WHERE x IS NOT NULL
    ON CONFLICT (id_professor, id_disciplina) DO UPDATE
    SET id_area = EXCLUDED.id_area,
        is_active = TRUE,
        updated_at = now();
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM public.professor_disciplina
  WHERE id_professor = p_id_professor
    AND COALESCE(is_active, TRUE) = TRUE;

  RETURN v_count;
END;
$$;

-- Removes a single discipline from a professor.
-- Returns the number of selected disciplines after the operation.
CREATE OR REPLACE FUNCTION public.usp_professor_disciplinas_delete_for_professor01(
  p_id_professor uuid,
  p_id_disciplina uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer;
BEGIN
  UPDATE public.professor_disciplina
  SET is_active = FALSE,
      updated_at = now()
  WHERE id_professor = p_id_professor
    AND id_disciplina = p_id_disciplina;

  SELECT COUNT(*) INTO v_count
  FROM public.professor_disciplina
  WHERE id_professor = p_id_professor
    AND COALESCE(is_active, TRUE) = TRUE;

  RETURN v_count;
END;
$$;
