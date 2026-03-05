DROP FUNCTION IF EXISTS public.usp_courses_select_all01();
DROP FUNCTION IF EXISTS public.usp_courses_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_courses_insert(uuid, uuid, uuid, uuid, uuid, uuid, character varying, text, character varying, integer, integer, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_courses_update(uuid, uuid, uuid, uuid, uuid, uuid, uuid, character varying, text, character varying, integer, integer);
DROP FUNCTION IF EXISTS public.usp_courses_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_courses_select_all01()
RETURNS SETOF public.courses
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.courses
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_courses_select_details01(
  p_id_course uuid
)
RETURNS SETOF public.courses
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.courses
  WHERE id_course = p_id_course;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_courses_insert(
  p_id_professor uuid,
  p_id_pricing_model uuid,
  p_id_tutoring_type uuid,
  p_id_disciplina uuid,
  p_id_ano_escolaridade uuid,
  p_id_ciclo_estudo uuid,
  p_name varchar(200),
  p_description text,
  p_level_of_education varchar(100),
  p_num_max_students integer,
  p_num_min_students integer,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.courses (
    id_professor,
    id_pricing_model,
    id_tutoring_type,
    id_disciplina,
    id_ano_escolaridade,
    id_ciclo_estudo,
    name,
    description,
    level_of_education,
    num_max_students,
    num_min_students,
    created_at,
    updated_at
  )
  VALUES (
    p_id_professor,
    p_id_pricing_model,
    p_id_tutoring_type,
    p_id_disciplina,
    p_id_ano_escolaridade,
    p_id_ciclo_estudo,
    p_name,
    p_description,
    p_level_of_education,
    p_num_max_students,
    p_num_min_students,
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id_course INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_courses_update(
  p_id_course uuid,
  p_id_professor uuid,
  p_id_pricing_model uuid,
  p_id_tutoring_type uuid,
  p_id_disciplina uuid,
  p_id_ano_escolaridade uuid,
  p_id_ciclo_estudo uuid,
  p_name varchar(200),
  p_description text,
  p_level_of_education varchar(100),
  p_num_max_students integer,
  p_num_min_students integer
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.courses
  SET id_professor = p_id_professor,
      id_pricing_model = p_id_pricing_model,
      id_tutoring_type = p_id_tutoring_type,
      id_disciplina = p_id_disciplina,
      id_ano_escolaridade = p_id_ano_escolaridade,
      id_ciclo_estudo = p_id_ciclo_estudo,
      name = p_name,
      description = p_description,
      level_of_education = p_level_of_education,
      num_max_students = p_num_max_students,
      num_min_students = p_num_min_students,
      updated_at = now()
  WHERE id_course = p_id_course;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_courses_delete(
  p_id_course uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.courses
  WHERE id_course = p_id_course;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
