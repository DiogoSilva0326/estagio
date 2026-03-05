CREATE OR REPLACE FUNCTION public.usp_complaints_select_all01()
RETURNS SETOF public.complaints
LANGUAGE sql
AS $$
  SELECT *
  FROM public.complaints
  ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaints_select_details01(
  p_id_complaint uuid
)
RETURNS SETOF public.complaints
LANGUAGE sql
AS $$
  SELECT *
  FROM public.complaints
  WHERE id_complaint = p_id_complaint;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaints_insert(
  p_sender_user_id uuid,
  p_receiver_user_id uuid,
  p_complaint_type varchar(100),
  p_complaint_message varchar(1000),
  p_status varchar(30),
  p_is_read boolean,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.complaints (
    sender_user_id,
    receiver_user_id,
    complaint_type,
    complaint_message,
    status,
    is_read,
    created_at,
    updated_at
  )
  VALUES (
    p_sender_user_id,
    p_receiver_user_id,
    p_complaint_type,
    p_complaint_message,
    p_status,
    COALESCE(p_is_read, false),
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id_complaint;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaints_update(
  p_id_complaint uuid,
  p_sender_user_id uuid,
  p_receiver_user_id uuid,
  p_complaint_type varchar(100),
  p_complaint_message varchar(1000),
  p_status varchar(30),
  p_is_read boolean
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.complaints
    SET sender_user_id = p_sender_user_id,
        receiver_user_id = p_receiver_user_id,
        complaint_type = p_complaint_type,
        complaint_message = p_complaint_message,
        status = p_status,
        is_read = COALESCE(p_is_read, is_read),
        updated_at = now()
    WHERE id_complaint = p_id_complaint
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaints_delete(
  p_id_complaint uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.complaints
    WHERE id_complaint = p_id_complaint
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
