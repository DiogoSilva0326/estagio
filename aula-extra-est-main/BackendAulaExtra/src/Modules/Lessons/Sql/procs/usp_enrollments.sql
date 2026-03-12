DROP FUNCTION IF EXISTS public.usp_enrollments_insert(uuid, integer, varchar, numeric, timestamp);
DROP FUNCTION IF EXISTS public.usp_enrollments_update(uuid, uuid, integer, varchar, numeric, timestamp);

CREATE OR REPLACE FUNCTION public.usp_enrollments_select_all01()
RETURNS SETOF public.enrollments
LANGUAGE sql
AS $$
  SELECT *
  FROM public.enrollments
  ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_enrollments_select_details01(
  p_id_enrollment uuid
)
RETURNS SETOF public.enrollments
LANGUAGE sql
AS $$
  SELECT *
  FROM public.enrollments
  WHERE id_enrollment = p_id_enrollment;
$$;

CREATE OR REPLACE FUNCTION public.usp_enrollments_insert(
  p_id_lesson uuid,
  p_id_user uuid,
  p_status varchar(20),
  p_price_paid numeric(10,2),
  p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.enrollments (
    id_lesson,
    id_user,
    status,
    price_paid,
    created_at
  )
  VALUES (
    p_id_lesson,
    p_id_user,
    p_status,
    p_price_paid,
    COALESCE(p_created_at, now())
  )
  RETURNING id_enrollment;
$$;

CREATE OR REPLACE FUNCTION public.usp_enrollments_update(
  p_id_enrollment uuid,
  p_id_lesson uuid,
  p_id_user uuid,
  p_status varchar(20),
  p_price_paid numeric(10,2),
  p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.enrollments
    SET id_lesson = p_id_lesson,
        id_user = p_id_user,
        status = p_status,
        price_paid = p_price_paid,
        created_at = COALESCE(p_created_at, created_at)
    WHERE id_enrollment = p_id_enrollment
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_enrollments_delete(
  p_id_enrollment uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.enrollments
    WHERE id_enrollment = p_id_enrollment
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
