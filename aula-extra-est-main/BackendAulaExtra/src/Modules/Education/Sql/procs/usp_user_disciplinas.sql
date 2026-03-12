DROP FUNCTION IF EXISTS public.usp_user_disciplinas_select_by_user01(uuid);
DROP FUNCTION IF EXISTS public.usp_user_disciplinas_set_for_user01(uuid, uuid[]);
DROP FUNCTION IF EXISTS public.usp_user_disciplinas_delete_for_user01(uuid, uuid);
DROP FUNCTION IF EXISTS public.usp_user_disciplinas_delete_for_user_by_area01(uuid, uuid);

CREATE OR REPLACE FUNCTION public.usp_user_disciplinas_select_by_user01(
  p_id_user uuid
)
RETURNS SETOF public.disciplinas
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT d.*
  FROM public.user_disciplina ud
  JOIN public.disciplinas d ON d.id_disciplina = ud.id_disciplina
  WHERE ud.user_id = p_id_user
  ORDER BY d.nome ASC;
END;
$$;

-- Replaces the set of disciplines for a user.
-- Returns the number of selected disciplines after the operation.
CREATE OR REPLACE FUNCTION public.usp_user_disciplinas_set_for_user01(
  p_id_user uuid,
  p_ids uuid[]
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer;
BEGIN
  DELETE FROM public.user_disciplina
  WHERE user_id = p_id_user;

  IF p_ids IS NOT NULL AND array_length(p_ids, 1) IS NOT NULL THEN
    INSERT INTO public.user_disciplina (user_id, id_disciplina)
    SELECT p_id_user, x
    FROM unnest(p_ids) AS x
    WHERE x IS NOT NULL
    ON CONFLICT (user_id, id_disciplina) DO NOTHING;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM public.user_disciplina
  WHERE user_id = p_id_user;

  RETURN v_count;
END;
$$;

-- Removes a single discipline from a user's selection.
-- Returns the number of selected disciplines after the operation.
CREATE OR REPLACE FUNCTION public.usp_user_disciplinas_delete_for_user01(
  p_id_user uuid,
  p_id_disciplina uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer;
BEGIN
  DELETE FROM public.user_disciplina
  WHERE user_id = p_id_user
    AND id_disciplina = p_id_disciplina;

  SELECT COUNT(*) INTO v_count
  FROM public.user_disciplina
  WHERE user_id = p_id_user;

  RETURN v_count;
END;
$$;

-- Removes all disciplines of a given area from a user's selection.
-- Returns the number of selected disciplines after the operation.
CREATE OR REPLACE FUNCTION public.usp_user_disciplinas_delete_for_user_by_area01(
  p_id_user uuid,
  p_id_area uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer;
BEGIN
  DELETE FROM public.user_disciplina ud
  USING public.disciplinas d
  WHERE ud.user_id = p_id_user
    AND d.id_disciplina = ud.id_disciplina
    AND d.id_area = p_id_area;

  SELECT COUNT(*) INTO v_count
  FROM public.user_disciplina
  WHERE user_id = p_id_user;

  RETURN v_count;
END;
$$;
