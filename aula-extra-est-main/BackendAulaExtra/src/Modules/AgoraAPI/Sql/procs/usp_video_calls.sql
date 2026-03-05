CREATE OR REPLACE FUNCTION public.usp_video_calls_select_all01()
RETURNS SETOF public.video_calls
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.video_calls
  ORDER BY started_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_calls_select_details01(
  p_id uuid
)
RETURNS SETOF public.video_calls
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.video_calls
  WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_calls_insert(
  p_channel_name text,
  p_call_name text,
  p_call_type text,
  p_group_room_id uuid,
  p_initiated_by_user_id uuid,
  p_status text,
  p_started_at timestamptz,
  p_ended_at timestamptz,
  p_duration_seconds integer,
  p_max_participants integer,
  p_recording_url text,
  p_is_recorded boolean,
  p_metadata jsonb
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.video_calls (
    channel_name,
    call_name,
    call_type,
    group_room_id,
    initiated_by_user_id,
    status,
    started_at,
    ended_at,
    duration_seconds,
    max_participants,
    recording_url,
    is_recorded,
    metadata
  )
  VALUES (
    p_channel_name,
    p_call_name,
    COALESCE(p_call_type, 'video'),
    p_group_room_id,
    p_initiated_by_user_id,
    COALESCE(p_status, 'active'),
    COALESCE(p_started_at, now()),
    p_ended_at,
    p_duration_seconds,
    COALESCE(p_max_participants, 0),
    p_recording_url,
    COALESCE(p_is_recorded, false),
    p_metadata
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_calls_update(
  p_id uuid,
  p_channel_name text,
  p_call_name text,
  p_call_type text,
  p_group_room_id uuid,
  p_initiated_by_user_id uuid,
  p_status text,
  p_started_at timestamptz,
  p_ended_at timestamptz,
  p_duration_seconds integer,
  p_max_participants integer,
  p_recording_url text,
  p_is_recorded boolean,
  p_metadata jsonb
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.video_calls
  SET channel_name = p_channel_name,
      call_name = p_call_name,
      call_type = COALESCE(p_call_type, call_type),
      group_room_id = p_group_room_id,
      initiated_by_user_id = p_initiated_by_user_id,
      status = COALESCE(p_status, status),
      started_at = p_started_at,
      ended_at = p_ended_at,
      duration_seconds = p_duration_seconds,
      max_participants = COALESCE(p_max_participants, max_participants),
      recording_url = p_recording_url,
      is_recorded = COALESCE(p_is_recorded, is_recorded),
      metadata = p_metadata
  WHERE id = p_id;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_calls_delete(
  p_id uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.video_calls
  WHERE id = p_id;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
