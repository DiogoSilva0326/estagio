DROP FUNCTION IF EXISTS public.usp_user_lesson_packs_select_all01();
DROP FUNCTION IF EXISTS public.usp_user_lesson_packs_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_user_lesson_packs_select_by_user01(uuid);
DROP FUNCTION IF EXISTS public.usp_user_lesson_packs_insert(uuid, uuid, integer, character varying, timestamp, timestamptz);
DROP FUNCTION IF EXISTS public.usp_user_lesson_packs_update(uuid, integer, character varying, timestamptz);
DROP FUNCTION IF EXISTS public.usp_user_lesson_packs_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_user_lesson_packs_select_all01()
RETURNS SETOF public.user_lesson_packs
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.user_lesson_packs
  ORDER BY purchased_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_user_lesson_packs_select_details01(
  p_id_user_lesson_pack uuid
)
RETURNS SETOF public.user_lesson_packs
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.user_lesson_packs
  WHERE id_user_lesson_pack = p_id_user_lesson_pack;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_user_lesson_packs_select_by_user01(
  p_id_user uuid
)
RETURNS SETOF public.user_lesson_packs
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.user_lesson_packs
  WHERE id_user = p_id_user
  ORDER BY purchased_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_user_lesson_packs_insert(
  p_id_user uuid,
  p_id_lesson_pack uuid,
  p_remaining_count integer,
  p_status varchar(30),
  p_purchased_at timestamp,
  p_expires_at timestamptz
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.user_lesson_packs (
    id_user,
    id_lesson_pack,
    remaining_count,
    status,
    purchased_at,
    expires_at
  )
  VALUES (
    p_id_user,
    p_id_lesson_pack,
    p_remaining_count,
    p_status,
    COALESCE(p_purchased_at, now()),
    p_expires_at
  )
  RETURNING id_user_lesson_pack INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_user_lesson_packs_update(
  p_id_user_lesson_pack uuid,
  p_remaining_count integer,
  p_status varchar(30),
  p_expires_at timestamptz
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.user_lesson_packs
  SET remaining_count = p_remaining_count,
      status = p_status,
      expires_at = p_expires_at
  WHERE id_user_lesson_pack = p_id_user_lesson_pack;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_user_lesson_packs_delete(
  p_id_user_lesson_pack uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.user_lesson_packs
  WHERE id_user_lesson_pack = p_id_user_lesson_pack;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
