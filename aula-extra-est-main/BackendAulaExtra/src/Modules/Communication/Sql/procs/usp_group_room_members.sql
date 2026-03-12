CREATE OR REPLACE FUNCTION public.usp_group_room_members_select_all01()
RETURNS SETOF public.group_room_members
LANGUAGE sql
AS $$
  SELECT *
  FROM public.group_room_members
  ORDER BY joined_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_room_members_select_details01(
  p_id uuid
)
RETURNS SETOF public.group_room_members
LANGUAGE sql
AS $$
  SELECT *
  FROM public.group_room_members
  WHERE id = p_id;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_room_members_insert(
  p_room_id uuid,
  p_user_id uuid,
  p_role text,
  p_nickname text,
  p_status text,
  p_notifications_enabled boolean,
  p_joined_at timestamptz,
  p_left_at timestamptz,
  p_last_read_at timestamptz
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.group_room_members (
    room_id,
    user_id,
    role,
    nickname,
    status,
    notifications_enabled,
    joined_at,
    left_at,
    last_read_at
  )
  VALUES (
    p_room_id,
    p_user_id,
    COALESCE(p_role, 'member'),
    p_nickname,
    COALESCE(p_status, 'active'),
    COALESCE(p_notifications_enabled, true),
    COALESCE(p_joined_at, now()),
    p_left_at,
    p_last_read_at
  )
  RETURNING id;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_room_members_update(
  p_id uuid,
  p_room_id uuid,
  p_user_id uuid,
  p_role text,
  p_nickname text,
  p_status text,
  p_notifications_enabled boolean,
  p_joined_at timestamptz,
  p_left_at timestamptz,
  p_last_read_at timestamptz
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.group_room_members
    SET room_id = p_room_id,
        user_id = p_user_id,
        role = COALESCE(p_role, role),
        nickname = p_nickname,
        status = COALESCE(p_status, status),
        notifications_enabled = COALESCE(p_notifications_enabled, notifications_enabled),
        joined_at = COALESCE(p_joined_at, joined_at),
        left_at = p_left_at,
        last_read_at = p_last_read_at
    WHERE id = p_id
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_room_members_delete(
  p_id uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.group_room_members
    WHERE id = p_id
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
