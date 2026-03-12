DROP FUNCTION IF EXISTS public.usp_tutoring_types_select_all01();
DROP FUNCTION IF EXISTS public.usp_tutoring_types_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_tutoring_types_insert(character varying, character varying, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_tutoring_types_update(uuid, character varying, character varying);
DROP FUNCTION IF EXISTS public.usp_tutoring_types_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_tutoring_types_select_all01()
RETURNS SETOF public.tutoring_types
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.tutoring_types
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_tutoring_types_select_details01(
  p_id_tutoring_type uuid
)
RETURNS SETOF public.tutoring_types
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.tutoring_types
  WHERE id_tutoring_type = p_id_tutoring_type;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_tutoring_types_insert(
  p_name varchar(100),
  p_description varchar(255),
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.tutoring_types (name, description, created_at, updated_at)
  VALUES (p_name, p_description, COALESCE(p_created_at, now()), COALESCE(p_updated_at, now()))
  RETURNING id_tutoring_type INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_tutoring_types_update(
  p_id_tutoring_type uuid,
  p_name varchar(100),
  p_description varchar(255)
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.tutoring_types
  SET name = p_name,
      description = p_description,
      updated_at = now()
  WHERE id_tutoring_type = p_id_tutoring_type;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_tutoring_types_delete(
  p_id_tutoring_type uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.tutoring_types
  WHERE id_tutoring_type = p_id_tutoring_type;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
