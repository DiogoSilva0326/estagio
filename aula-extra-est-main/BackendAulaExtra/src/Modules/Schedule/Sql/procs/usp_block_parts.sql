CREATE OR REPLACE FUNCTION public.usp_block_parts_select_all01()
RETURNS SETOF public.block_parts
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.block_parts
  ORDER BY id_schedule_block;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_block_parts_select_details01(
  p_id_block_part uuid
)
RETURNS SETOF public.block_parts
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.block_parts
  WHERE id_block_part = p_id_block_part;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_block_parts_insert(
  p_id_schedule_block uuid,
  p_start_offset_minutes integer,
  p_end_offset_minutes integer,
  p_is_available boolean
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.block_parts (
    id_schedule_block,
    start_offset_minutes,
    end_offset_minutes,
    is_available
  )
  VALUES (
    p_id_schedule_block,
    p_start_offset_minutes,
    p_end_offset_minutes,
    p_is_available
  )
  RETURNING id_block_part INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_block_parts_update(
  p_id_block_part uuid,
  p_id_schedule_block uuid,
  p_start_offset_minutes integer,
  p_end_offset_minutes integer,
  p_is_available boolean
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.block_parts
  SET id_schedule_block = p_id_schedule_block,
      start_offset_minutes = p_start_offset_minutes,
      end_offset_minutes = p_end_offset_minutes,
      is_available = p_is_available
  WHERE id_block_part = p_id_block_part;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_block_parts_delete(
  p_id_block_part uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.block_parts
  WHERE id_block_part = p_id_block_part;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
