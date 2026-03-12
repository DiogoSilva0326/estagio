DROP FUNCTION IF EXISTS public.usp_favorite_items_select_all01();
DROP FUNCTION IF EXISTS public.usp_favorite_items_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_favorite_items_insert(uuid, uuid, timestamp);
DROP FUNCTION IF EXISTS public.usp_favorite_items_update(uuid, uuid, uuid, timestamp);
DROP FUNCTION IF EXISTS public.usp_favorite_items_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_favorite_items_select_all01()
RETURNS SETOF public.favorite_items
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.favorite_items
  ORDER BY added_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorite_items_select_details01(
  p_id_favorite_item uuid
)
RETURNS SETOF public.favorite_items
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.favorite_items
  WHERE id_favorite_item = p_id_favorite_item;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorite_items_insert(
  p_id_favorite uuid,
  p_id_professor uuid,
  p_added_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.favorite_items (id_favorite, id_professor, added_at)
  VALUES (p_id_favorite, p_id_professor, COALESCE(p_added_at, now()))
  RETURNING id_favorite_item INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorite_items_update(
  p_id_favorite_item uuid,
  p_id_favorite uuid,
  p_id_professor uuid,
  p_added_at timestamp
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.favorite_items
  SET id_favorite = p_id_favorite,
      id_professor = p_id_professor,
      added_at = p_added_at
  WHERE id_favorite_item = p_id_favorite_item;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_favorite_items_delete(
  p_id_favorite_item uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.favorite_items
  WHERE id_favorite_item = p_id_favorite_item;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
