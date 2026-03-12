CREATE OR REPLACE FUNCTION public.usp_days_select_all01()
RETURNS SETOF public.days
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.days
  ORDER BY day_index NULLS LAST, name;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_days_select_details01(
  p_id_day uuid
)
RETURNS SETOF public.days
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.days
  WHERE id_day = p_id_day;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_days_insert(
  p_name varchar(20),
  p_day_index integer
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.days (name, day_index)
  VALUES (p_name, p_day_index)
  RETURNING id_day INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_days_update(
  p_id_day uuid,
  p_name varchar(20),
  p_day_index integer
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.days
  SET name = p_name,
      day_index = p_day_index
  WHERE id_day = p_id_day;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_days_delete(
  p_id_day uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.days
  WHERE id_day = p_id_day;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
