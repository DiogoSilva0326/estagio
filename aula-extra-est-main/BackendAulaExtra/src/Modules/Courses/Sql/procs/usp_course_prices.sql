DROP FUNCTION IF EXISTS public.usp_course_prices_select_all01();
DROP FUNCTION IF EXISTS public.usp_course_prices_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_course_prices_insert(uuid, numeric, numeric, integer, boolean, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_course_prices_update(uuid, uuid, numeric, numeric, integer, boolean);
DROP FUNCTION IF EXISTS public.usp_course_prices_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_course_prices_select_all01()
RETURNS SETOF public.course_prices
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.course_prices
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_course_prices_select_details01(
  p_id_course_price uuid
)
RETURNS SETOF public.course_prices
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.course_prices
  WHERE id_course_price = p_id_course_price;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_course_prices_insert(
  p_id_course uuid,
  p_session_price numeric(10,2),
  p_price_per_student numeric(10,2),
  p_number_students integer,
  p_active boolean,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.course_prices (
    id_course,
    session_price,
    price_per_student,
    number_students,
    active,
    created_at,
    updated_at
  )
  VALUES (
    p_id_course,
    p_session_price,
    p_price_per_student,
    p_number_students,
    p_active,
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id_course_price INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_course_prices_update(
  p_id_course_price uuid,
  p_id_course uuid,
  p_session_price numeric(10,2),
  p_price_per_student numeric(10,2),
  p_number_students integer,
  p_active boolean
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.course_prices
  SET id_course = p_id_course,
      session_price = p_session_price,
      price_per_student = p_price_per_student,
      number_students = p_number_students,
      active = p_active,
      updated_at = now()
  WHERE id_course_price = p_id_course_price;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_course_prices_delete(
  p_id_course_price uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.course_prices
  WHERE id_course_price = p_id_course_price;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
