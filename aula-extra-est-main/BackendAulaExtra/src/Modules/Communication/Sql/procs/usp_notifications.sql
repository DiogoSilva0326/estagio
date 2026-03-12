CREATE OR REPLACE FUNCTION public.usp_notifications_select_all01()
RETURNS SETOF public.notifications
LANGUAGE sql
AS $$
  SELECT *
  FROM public.notifications
  ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_notifications_select_details01(
  p_id_notification uuid
)
RETURNS SETOF public.notifications
LANGUAGE sql
AS $$
  SELECT *
  FROM public.notifications
  WHERE id_notification = p_id_notification;
$$;

CREATE OR REPLACE FUNCTION public.usp_notifications_insert(
  p_id_user uuid,
  p_type varchar(50),
  p_message varchar(500),
  p_was_read boolean,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.notifications (
    id_user,
    type,
    message,
    was_read,
    created_at,
    updated_at
  )
  VALUES (
    p_id_user,
    p_type,
    p_message,
    COALESCE(p_was_read, false),
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id_notification;
$$;

CREATE OR REPLACE FUNCTION public.usp_notifications_update(
  p_id_notification uuid,
  p_id_user uuid,
  p_type varchar(50),
  p_message varchar(500),
  p_was_read boolean
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.notifications
    SET id_user = p_id_user,
        type = p_type,
        message = p_message,
        was_read = COALESCE(p_was_read, was_read),
        updated_at = now()
    WHERE id_notification = p_id_notification
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_notifications_delete(
  p_id_notification uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.notifications
    WHERE id_notification = p_id_notification
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
