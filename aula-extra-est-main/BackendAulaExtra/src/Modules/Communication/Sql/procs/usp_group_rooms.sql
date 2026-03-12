CREATE OR REPLACE FUNCTION public.usp_group_rooms_select_all01()
RETURNS SETOF public.group_rooms
LANGUAGE sql
AS $$
  SELECT *
  FROM public.group_rooms
  ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_rooms_select_details01(
  p_id uuid
)
RETURNS SETOF public.group_rooms
LANGUAGE sql
AS $$
  SELECT *
  FROM public.group_rooms
  WHERE id = p_id;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_rooms_insert(
  p_room_code text,
  p_name text,
  p_description text,
  p_room_type text,
  p_created_by_user_id uuid,
  p_is_active boolean,
  p_avatar_url text,
  p_metadata jsonb,
  p_created_at timestamptz,
  p_updated_at timestamptz
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.group_rooms (
    room_code,
    name,
    description,
    room_type,
    created_by_user_id,
    is_active,
    avatar_url,
    metadata,
    created_at,
    updated_at
  )
  VALUES (
    p_room_code,
    p_name,
    p_description,
    COALESCE(p_room_type, 'group'),
    p_created_by_user_id,
    COALESCE(p_is_active, true),
    p_avatar_url,
    p_metadata,
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_rooms_update(
  p_id uuid,
  p_room_code text,
  p_name text,
  p_description text,
  p_room_type text,
  p_created_by_user_id uuid,
  p_is_active boolean,
  p_avatar_url text,
  p_metadata jsonb
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.group_rooms
    SET room_code = p_room_code,
        name = p_name,
        description = p_description,
        room_type = COALESCE(p_room_type, room_type),
        created_by_user_id = p_created_by_user_id,
        is_active = COALESCE(p_is_active, is_active),
        avatar_url = p_avatar_url,
        metadata = p_metadata,
        updated_at = now()
    WHERE id = p_id
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_group_rooms_delete(
  p_id uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.group_rooms
    WHERE id = p_id
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
