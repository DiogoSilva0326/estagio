CREATE OR REPLACE FUNCTION public.usp_lesson_prices_select_all01()
RETURNS SETOF public.lesson_prices
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lesson_prices
  ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_prices_select_details01(
  p_id_lesson_price uuid
)
RETURNS SETOF public.lesson_prices
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lesson_prices
  WHERE id_lesson_price = p_id_lesson_price;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_prices_insert(
  p_id_lesson uuid,
  p_session_price numeric(10,2),
  p_price_per_student numeric(10,2),
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.lesson_prices (
    id_lesson,
    session_price,
    price_per_student,
    created_at,
    updated_at
  )
  VALUES (
    p_id_lesson,
    p_session_price,
    p_price_per_student,
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id_lesson_price;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_prices_update(
  p_id_lesson_price uuid,
  p_id_lesson uuid,
  p_session_price numeric(10,2),
  p_price_per_student numeric(10,2)
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.lesson_prices
    SET id_lesson = p_id_lesson,
        session_price = p_session_price,
        price_per_student = p_price_per_student,
        updated_at = now()
    WHERE id_lesson_price = p_id_lesson_price
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_prices_delete(
  p_id_lesson_price uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.lesson_prices
    WHERE id_lesson_price = p_id_lesson_price
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
