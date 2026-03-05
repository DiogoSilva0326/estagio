CREATE OR REPLACE FUNCTION public.usp_exception_requests_select_all01()
RETURNS SETOF public.exception_requests
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.exception_requests
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_requests_select_details01(
  p_id_exception_request uuid
)
RETURNS SETOF public.exception_requests
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.exception_requests
  WHERE id_exception_request = p_id_exception_request;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_requests_insert(
  p_id_user uuid,
  p_id_reservation uuid,
  p_id_professor uuid,
  p_request_type varchar(50),
  p_id_exception_rule uuid,
  p_requested_duration_minutes integer,
  p_requested_start timestamp,
  p_requested_end timestamp,
  p_status varchar(20),
  p_reason text
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.exception_requests (
    id_user,
    id_reservation,
    id_professor,
    request_type,
    id_exception_rule,
    requested_duration_minutes,
    requested_start,
    requested_end,
    status,
    reason
  )
  VALUES (
    p_id_user,
    p_id_reservation,
    p_id_professor,
    p_request_type,
    p_id_exception_rule,
    p_requested_duration_minutes,
    p_requested_start,
    p_requested_end,
    p_status,
    p_reason
  )
  RETURNING id_exception_request INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_requests_update(
  p_id_exception_request uuid,
  p_id_user uuid,
  p_id_reservation uuid,
  p_id_professor uuid,
  p_request_type varchar(50),
  p_id_exception_rule uuid,
  p_requested_duration_minutes integer,
  p_requested_start timestamp,
  p_requested_end timestamp,
  p_status varchar(20),
  p_reason text
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.exception_requests
  SET id_user = p_id_user,
      id_reservation = p_id_reservation,
      id_professor = p_id_professor,
      request_type = p_request_type,
      id_exception_rule = p_id_exception_rule,
      requested_duration_minutes = p_requested_duration_minutes,
      requested_start = p_requested_start,
      requested_end = p_requested_end,
      status = p_status,
      reason = p_reason
  WHERE id_exception_request = p_id_exception_request;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_exception_requests_delete(
  p_id_exception_request uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.exception_requests
  WHERE id_exception_request = p_id_exception_request;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
