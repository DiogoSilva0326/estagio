DROP FUNCTION IF EXISTS public.usp_pack_transactions_select_all01();
DROP FUNCTION IF EXISTS public.usp_pack_transactions_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_pack_transactions_select_by_user_lesson_pack01(uuid);
DROP FUNCTION IF EXISTS public.usp_pack_transactions_insert(uuid, uuid, character varying, integer, timestamptz);
DROP FUNCTION IF EXISTS public.usp_pack_transactions_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_pack_transactions_select_all01()
RETURNS SETOF public.pack_transactions
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.pack_transactions
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pack_transactions_select_details01(
  p_id_pack_transaction uuid
)
RETURNS SETOF public.pack_transactions
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.pack_transactions
  WHERE id_pack_transaction = p_id_pack_transaction;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pack_transactions_select_by_user_lesson_pack01(
  p_id_user_lesson_pack uuid
)
RETURNS SETOF public.pack_transactions
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.pack_transactions
  WHERE id_user_lesson_pack = p_id_user_lesson_pack
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pack_transactions_insert(
  p_id_user_lesson_pack uuid,
  p_id_reservation uuid,
  p_transaction_type varchar(50),
  p_value_change integer,
  p_created_at timestamptz
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.pack_transactions (
    id_user_lesson_pack,
    id_reservation,
    transaction_type,
    value_change,
    created_at
  )
  VALUES (
    p_id_user_lesson_pack,
    p_id_reservation,
    p_transaction_type,
    p_value_change,
    COALESCE(p_created_at, now())
  )
  RETURNING id_pack_transaction INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pack_transactions_delete(
  p_id_pack_transaction uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.pack_transactions
  WHERE id_pack_transaction = p_id_pack_transaction;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
