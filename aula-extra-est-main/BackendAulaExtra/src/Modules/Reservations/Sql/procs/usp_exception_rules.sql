CREATE OR REPLACE FUNCTION public.usp_exception_rules_select_all01()
RETURNS SETOF public.exception_rules
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.exception_rules
  ORDER BY effective_from DESC NULLS LAST, id_exception_rule;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_rules_select_details01(
  p_id_exception_rule uuid
)
RETURNS SETOF public.exception_rules
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.exception_rules
  WHERE id_exception_rule = p_id_exception_rule;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_rules_insert(
  p_id_professor uuid,
  p_id_schedule_block uuid,
  p_rule_type varchar(50),
  p_custom_duration_minutes integer,
  p_part_start_offset_minutes integer,
  p_part_end_offset_minutes integer,
  p_originating_request_id integer,
  p_effective_from timestamp,
  p_effective_to timestamp,
  p_note text
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.exception_rules (
    id_professor,
    id_schedule_block,
    rule_type,
    custom_duration_minutes,
    part_start_offset_minutes,
    part_end_offset_minutes,
    originating_request_id,
    effective_from,
    effective_to,
    note
  )
  VALUES (
    p_id_professor,
    p_id_schedule_block,
    p_rule_type,
    p_custom_duration_minutes,
    p_part_start_offset_minutes,
    p_part_end_offset_minutes,
    p_originating_request_id,
    p_effective_from,
    p_effective_to,
    p_note
  )
  RETURNING id_exception_rule INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_rules_update(
  p_id_exception_rule uuid,
  p_id_professor uuid,
  p_id_schedule_block uuid,
  p_rule_type varchar(50),
  p_custom_duration_minutes integer,
  p_part_start_offset_minutes integer,
  p_part_end_offset_minutes integer,
  p_originating_request_id integer,
  p_effective_from timestamp,
  p_effective_to timestamp,
  p_note text
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.exception_rules
  SET id_professor = p_id_professor,
      id_schedule_block = p_id_schedule_block,
      rule_type = p_rule_type,
      custom_duration_minutes = p_custom_duration_minutes,
      part_start_offset_minutes = p_part_start_offset_minutes,
      part_end_offset_minutes = p_part_end_offset_minutes,
      originating_request_id = p_originating_request_id,
      effective_from = p_effective_from,
      effective_to = p_effective_to,
      note = p_note
  WHERE id_exception_rule = p_id_exception_rule;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_rules_delete(
  p_id_exception_rule uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.exception_rules
  WHERE id_exception_rule = p_id_exception_rule;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
