DROP FUNCTION IF EXISTS public.usp_wishlist_items_select_all01();
DROP FUNCTION IF EXISTS public.usp_wishlist_items_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_wishlist_items_insert(uuid, uuid, timestamp);
DROP FUNCTION IF EXISTS public.usp_wishlist_items_update(uuid, uuid, uuid, timestamp);
DROP FUNCTION IF EXISTS public.usp_wishlist_items_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_wishlist_items_select_all01()
RETURNS SETOF public.wishlist_items
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.wishlist_items
  ORDER BY added_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlist_items_select_details01(
  p_id_wishlist_item uuid
)
RETURNS SETOF public.wishlist_items
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.wishlist_items
  WHERE id_wishlist_item = p_id_wishlist_item;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlist_items_insert(
  p_id_wishlist uuid,
  p_course_id uuid,
  p_added_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.wishlist_items (id_wishlist, course_id, added_at)
  VALUES (p_id_wishlist, p_course_id, COALESCE(p_added_at, now()))
  RETURNING id_wishlist_item INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlist_items_update(
  p_id_wishlist_item uuid,
  p_id_wishlist uuid,
  p_course_id uuid,
  p_added_at timestamp
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.wishlist_items
  SET id_wishlist = p_id_wishlist,
      course_id = p_course_id,
      added_at = p_added_at
  WHERE id_wishlist_item = p_id_wishlist_item;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_wishlist_items_delete(
  p_id_wishlist_item uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.wishlist_items
  WHERE id_wishlist_item = p_id_wishlist_item;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
