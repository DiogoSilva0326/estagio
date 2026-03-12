CREATE OR REPLACE FUNCTION public.usp_messages_select_all01()
RETURNS SETOF public.messages
LANGUAGE sql
AS $$
  SELECT *
  FROM public.messages
  ORDER BY sent_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_messages_select_details01(
  p_id_message uuid
)
RETURNS SETOF public.messages
LANGUAGE sql
AS $$
  SELECT *
  FROM public.messages
  WHERE id_message = p_id_message;
$$;

CREATE OR REPLACE FUNCTION public.usp_messages_insert(
  p_sender_user_id uuid,
  p_receiver_user_id uuid,
  p_message_content text,
  p_is_read boolean,
  p_sent_at timestamp,
  p_read_at timestamp,
  p_group_room_id uuid
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.messages (
    sender_user_id,
    receiver_user_id,
    message_content,
    is_read,
    sent_at,
    read_at,
    group_room_id
  )
  VALUES (
    p_sender_user_id,
    p_receiver_user_id,
    p_message_content,
    COALESCE(p_is_read, false),
    COALESCE(p_sent_at, now()),
    p_read_at,
    p_group_room_id
  )
  RETURNING id_message;
$$;

CREATE OR REPLACE FUNCTION public.usp_messages_update(
  p_id_message uuid,
  p_sender_user_id uuid,
  p_receiver_user_id uuid,
  p_message_content text,
  p_is_read boolean,
  p_sent_at timestamp,
  p_read_at timestamp,
  p_group_room_id uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.messages
    SET sender_user_id = p_sender_user_id,
        receiver_user_id = p_receiver_user_id,
        message_content = p_message_content,
        is_read = COALESCE(p_is_read, is_read),
        sent_at = COALESCE(p_sent_at, sent_at),
        read_at = p_read_at,
        group_room_id = p_group_room_id
    WHERE id_message = p_id_message
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_messages_delete(
  p_id_message uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.messages
    WHERE id_message = p_id_message
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
