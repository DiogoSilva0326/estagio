DROP FUNCTION IF EXISTS public.usp_lesson_feedback_insert(uuid, uuid, boolean, integer, text, timestamp);
DROP FUNCTION IF EXISTS public.usp_lesson_feedback_insert(uuid, uuid, boolean, integer, text, timestamp with time zone);
DROP FUNCTION IF EXISTS public.usp_lesson_feedback_update(uuid, uuid, uuid, boolean, integer, text, timestamp);
DROP FUNCTION IF EXISTS public.usp_lesson_feedback_update(uuid, uuid, uuid, boolean, integer, text, timestamp with time zone);
-- legacy/wrong signature cleanup (kept for safety)
DROP FUNCTION IF EXISTS public.usp_lesson_feedback_update(uuid, uuid, integer, boolean, integer, text, timestamp);

CREATE OR REPLACE FUNCTION public.usp_lesson_feedback_select_all01()
RETURNS SETOF public.lesson_feedback
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lesson_feedback
  ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_feedback_select_details01(
  p_id_lesson_feedback uuid
)
RETURNS SETOF public.lesson_feedback
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lesson_feedback
  WHERE id_lesson_feedback = p_id_lesson_feedback;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_feedback_insert(
  p_id_lesson uuid,
  p_id_user uuid,
  p_is_valid boolean,
  p_rating integer,
  p_comments text,
  p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.lesson_feedback (
    id_lesson,
    id_user,
    is_valid,
    rating,
    comments,
    created_at
  )
  VALUES (
    p_id_lesson,
    p_id_user,
    COALESCE(p_is_valid, true),
    p_rating,
    p_comments,
    COALESCE(p_created_at, now())
  )
  RETURNING id_lesson_feedback;
$$;

-- Overload: accept timestamptz too (Npgsql maps DateTime UTC to timestamptz)
CREATE OR REPLACE FUNCTION public.usp_lesson_feedback_insert(
  p_id_lesson uuid,
  p_id_user uuid,
  p_is_valid boolean,
  p_rating integer,
  p_comments text,
  p_created_at timestamp with time zone
)
RETURNS uuid
LANGUAGE sql
AS $$
  SELECT public.usp_lesson_feedback_insert(
    p_id_lesson,
    p_id_user,
    p_is_valid,
    p_rating,
    p_comments,
    p_created_at::timestamp
  );
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_feedback_update(
  p_id_lesson_feedback uuid,
  p_id_lesson uuid,
  p_id_user uuid,
  p_is_valid boolean,
  p_rating integer,
  p_comments text,
  p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.lesson_feedback
    SET id_lesson = p_id_lesson,
        id_user = p_id_user,
        is_valid = COALESCE(p_is_valid, is_valid),
        rating = p_rating,
        comments = p_comments,
        created_at = COALESCE(p_created_at, created_at)
    WHERE id_lesson_feedback = p_id_lesson_feedback
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

-- Overload: accept timestamptz too
CREATE OR REPLACE FUNCTION public.usp_lesson_feedback_update(
  p_id_lesson_feedback uuid,
  p_id_lesson uuid,
  p_id_user uuid,
  p_is_valid boolean,
  p_rating integer,
  p_comments text,
  p_created_at timestamp with time zone
)
RETURNS integer
LANGUAGE sql
AS $$
  SELECT public.usp_lesson_feedback_update(
    p_id_lesson_feedback,
    p_id_lesson,
    p_id_user,
    p_is_valid,
    p_rating,
    p_comments,
    p_created_at::timestamp
  );
$$;


CREATE OR REPLACE FUNCTION public.usp_lesson_feedback_delete(
  p_id_lesson_feedback uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.lesson_feedback
    WHERE id_lesson_feedback = p_id_lesson_feedback
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
