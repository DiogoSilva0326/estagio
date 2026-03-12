CREATE OR REPLACE FUNCTION public.usp_video_call_participants_select_all01()
RETURNS SETOF public.video_call_participants
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.video_call_participants
  ORDER BY joined_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_call_participants_select_details01(
  p_id uuid
)
RETURNS SETOF public.video_call_participants
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.video_call_participants
  WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_call_participants_insert(
  p_call_id uuid,
  p_user_id uuid,
  p_role text,
  p_joined_at timestamptz,
  p_left_at timestamptz,
  p_duration_seconds integer,
  p_avg_video_quality text,
  p_avg_audio_quality text,
  p_had_video boolean,
  p_had_audio boolean,
  p_had_screen_share boolean,
  p_device_type text,
  p_metadata jsonb
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.video_call_participants (
    call_id,
    user_id,
    role,
    joined_at,
    left_at,
    duration_seconds,
    avg_video_quality,
    avg_audio_quality,
    had_video,
    had_audio,
    had_screen_share,
    device_type,
    metadata
  )
  VALUES (
    p_call_id,
    p_user_id,
    COALESCE(p_role, 'participant'),
    COALESCE(p_joined_at, now()),
    p_left_at,
    p_duration_seconds,
    p_avg_video_quality,
    p_avg_audio_quality,
    COALESCE(p_had_video, true),
    COALESCE(p_had_audio, true),
    COALESCE(p_had_screen_share, false),
    p_device_type,
    p_metadata
  )
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_call_participants_update(
  p_id uuid,
  p_call_id uuid,
  p_user_id uuid,
  p_role text,
  p_joined_at timestamptz,
  p_left_at timestamptz,
  p_duration_seconds integer,
  p_avg_video_quality text,
  p_avg_audio_quality text,
  p_had_video boolean,
  p_had_audio boolean,
  p_had_screen_share boolean,
  p_device_type text,
  p_metadata jsonb
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.video_call_participants
  SET call_id = p_call_id,
      user_id = p_user_id,
      role = COALESCE(p_role, role),
      joined_at = p_joined_at,
      left_at = p_left_at,
      duration_seconds = p_duration_seconds,
      avg_video_quality = p_avg_video_quality,
      avg_audio_quality = p_avg_audio_quality,
      had_video = COALESCE(p_had_video, had_video),
      had_audio = COALESCE(p_had_audio, had_audio),
      had_screen_share = COALESCE(p_had_screen_share, had_screen_share),
      device_type = p_device_type,
      metadata = p_metadata
  WHERE id = p_id;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_video_call_participants_delete(
  p_id uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.video_call_participants
  WHERE id = p_id;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
