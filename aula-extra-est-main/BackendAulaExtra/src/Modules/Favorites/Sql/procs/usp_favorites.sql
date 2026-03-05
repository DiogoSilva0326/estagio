DROP FUNCTION IF EXISTS public.usp_favorites_select_all01();
DROP FUNCTION IF EXISTS public.usp_favorites_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_favorites_insert(integer, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_favorites_insert(uuid, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_favorites_update(uuid, integer);
DROP FUNCTION IF EXISTS public.usp_favorites_update(uuid, uuid);
DROP FUNCTION IF EXISTS public.usp_favorites_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_favorites_select_all01()
RETURNS SETOF public.favorites
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.favorites
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorites_select_details01(
  p_id_favorite uuid
)
RETURNS SETOF public.favorites
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.favorites
  WHERE id_favorite = p_id_favorite;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorites_insert(
  p_id_user uuid,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.favorites (id_user, created_at, updated_at)
  VALUES (p_id_user, COALESCE(p_created_at, now()), COALESCE(p_updated_at, now()))
  RETURNING id_favorite INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorites_update(
  p_id_favorite uuid,
  p_id_user uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.favorites
  SET id_user = p_id_user,
      updated_at = now()
  WHERE id_favorite = p_id_favorite;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorites_delete(
  p_id_favorite uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.favorites
  WHERE id_favorite = p_id_favorite;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
