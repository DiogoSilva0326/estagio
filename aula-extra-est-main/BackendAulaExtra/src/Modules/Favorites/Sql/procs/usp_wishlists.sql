DROP FUNCTION IF EXISTS public.usp_wishlists_select_all01();
DROP FUNCTION IF EXISTS public.usp_wishlists_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_wishlists_insert(integer, timestamp);
DROP FUNCTION IF EXISTS public.usp_wishlists_insert(uuid, timestamp);
DROP FUNCTION IF EXISTS public.usp_wishlists_update(uuid, integer);
DROP FUNCTION IF EXISTS public.usp_wishlists_update(uuid, uuid);
DROP FUNCTION IF EXISTS public.usp_wishlists_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_wishlists_select_all01()
RETURNS SETOF public.wishlists
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.wishlists
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlists_select_details01(
  p_id_wishlist uuid
)
RETURNS SETOF public.wishlists
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.wishlists
  WHERE id_wishlist = p_id_wishlist;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlists_insert(
  p_id_user uuid,
  p_created_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.wishlists (id_user, created_at)
  VALUES (p_id_user, COALESCE(p_created_at, now()))
  RETURNING id_wishlist INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlists_update(
  p_id_wishlist uuid,
  p_id_user uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.wishlists
  SET id_user = p_id_user
  WHERE id_wishlist = p_id_wishlist;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlists_delete(
  p_id_wishlist uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.wishlists
  WHERE id_wishlist = p_id_wishlist;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
