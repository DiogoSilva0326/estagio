DROP FUNCTION IF EXISTS public.usp_lesson_packs_select_all01();
DROP FUNCTION IF EXISTS public.usp_lesson_packs_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_lesson_packs_select_by_course01(uuid);
DROP FUNCTION IF EXISTS public.usp_lesson_packs_insert(uuid, character varying, integer, integer, numeric, boolean, timestamp);
DROP FUNCTION IF EXISTS public.usp_lesson_packs_update(uuid, uuid, character varying, integer, integer, numeric, boolean);
DROP FUNCTION IF EXISTS public.usp_lesson_packs_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_lesson_packs_select_all01()
RETURNS SETOF public.lesson_packs
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.lesson_packs
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_packs_select_details01(
  p_id_lesson_pack uuid
)
RETURNS SETOF public.lesson_packs
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.lesson_packs
  WHERE id_lesson_pack = p_id_lesson_pack;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_packs_select_by_course01(
  p_id_course uuid
)
RETURNS SETOF public.lesson_packs
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.lesson_packs
  WHERE id_course = p_id_course
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_packs_insert(
  p_id_course uuid,
  p_name varchar(200),
  p_number_of_lessons integer,
  p_session_duration_minutes integer,
  p_total_price numeric,
  p_is_active boolean,
  p_created_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.lesson_packs (
    id_course,
    name,
    number_of_lessons,
    session_duration_minutes,
    total_price,
    is_active,
    created_at
  )
  VALUES (
    p_id_course,
    p_name,
    p_number_of_lessons,
    p_session_duration_minutes,
    p_total_price,
    COALESCE(p_is_active, true),
    COALESCE(p_created_at, now())
  )
  RETURNING id_lesson_pack INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_packs_update(
  p_id_lesson_pack uuid,
  p_id_course uuid,
  p_name varchar(200),
  p_number_of_lessons integer,
  p_session_duration_minutes integer,
  p_total_price numeric,
  p_is_active boolean
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.lesson_packs
  SET id_course = p_id_course,
      name = p_name,
      number_of_lessons = p_number_of_lessons,
      session_duration_minutes = p_session_duration_minutes,
      total_price = p_total_price,
      is_active = p_is_active
  WHERE id_lesson_pack = p_id_lesson_pack;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_packs_delete(
  p_id_lesson_pack uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.lesson_packs
  WHERE id_lesson_pack = p_id_lesson_pack;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
