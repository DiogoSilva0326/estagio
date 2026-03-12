CREATE OR REPLACE FUNCTION public.usp_schedule_blocks_select_all01()
RETURNS SETOF public.schedule_blocks
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.schedule_blocks
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_schedule_blocks_select_details01(
  p_id_schedule_block uuid
)
RETURNS SETOF public.schedule_blocks
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.schedule_blocks
  WHERE id_schedule_block = p_id_schedule_block;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_schedule_blocks_insert(
  p_id_professor uuid,
  p_id_day uuid,
  p_start_time timestamp,
  p_end_time timestamp,
  p_default_duration_minutes integer,
  p_is_available boolean,
  p_recurrence_rule text
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.schedule_blocks (
    id_professor,
    id_day,
    start_time,
    end_time,
    default_duration_minutes,
    is_available,
    recurrence_rule
  )
  VALUES (
    p_id_professor,
    p_id_day,
    p_start_time,
    p_end_time,
    p_default_duration_minutes,
    p_is_available,
    p_recurrence_rule
  )
  RETURNING id_schedule_block INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_schedule_blocks_update(
  p_id_schedule_block uuid,
  p_id_professor uuid,
  p_id_day uuid,
  p_start_time timestamp,
  p_end_time timestamp,
  p_default_duration_minutes integer,
  p_is_available boolean,
  p_recurrence_rule text
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.schedule_blocks
  SET id_professor = p_id_professor,
      id_day = p_id_day,
      start_time = p_start_time,
      end_time = p_end_time,
      default_duration_minutes = p_default_duration_minutes,
      is_available = p_is_available,
      recurrence_rule = p_recurrence_rule,
      updated_at = now()
  WHERE id_schedule_block = p_id_schedule_block;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_schedule_blocks_delete(
  p_id_schedule_block uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.schedule_blocks
  WHERE id_schedule_block = p_id_schedule_block;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
