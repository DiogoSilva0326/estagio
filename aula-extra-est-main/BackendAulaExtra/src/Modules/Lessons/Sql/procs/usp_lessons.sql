CREATE OR REPLACE FUNCTION public.usp_lessons_select_all01()
RETURNS SETOF public.lessons
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lessons
  ORDER BY scheduled_start DESC NULLS LAST;
$$;

CREATE OR REPLACE FUNCTION public.usp_lessons_select_details01(
  p_id_lesson uuid
)
RETURNS SETOF public.lessons
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lessons
  WHERE id_lesson = p_id_lesson;
$$;

CREATE OR REPLACE FUNCTION public.usp_lessons_insert(
  p_id_course uuid,
  p_id_professor uuid,
  p_title varchar(200),
  p_students integer,
  p_duration_minutes integer,
  p_scheduled_start timestamp,
  p_scheduled_end timestamp,
  p_uses_custom_blocks boolean,
  p_max_students integer,
  p_base_price numeric(10,2)
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.lessons (
    id_course,
    id_professor,
    title,
    students,
    duration_minutes,
    scheduled_start,
    scheduled_end,
    uses_custom_blocks,
    max_students,
    base_price
  )
  VALUES (
    p_id_course,
    p_id_professor,
    p_title,
    p_students,
    p_duration_minutes,
    p_scheduled_start,
    p_scheduled_end,
    p_uses_custom_blocks,
    p_max_students,
    p_base_price
  )
  RETURNING id_lesson;
$$;

CREATE OR REPLACE FUNCTION public.usp_lessons_update(
  p_id_lesson uuid,
  p_id_course uuid,
  p_id_professor uuid,
  p_title varchar(200),
  p_students integer,
  p_duration_minutes integer,
  p_scheduled_start timestamp,
  p_scheduled_end timestamp,
  p_uses_custom_blocks boolean,
  p_max_students integer,
  p_base_price numeric(10,2)
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.lessons
    SET id_course = p_id_course,
        id_professor = p_id_professor,
        title = p_title,
        students = p_students,
        duration_minutes = p_duration_minutes,
        scheduled_start = p_scheduled_start,
        scheduled_end = p_scheduled_end,
        uses_custom_blocks = COALESCE(p_uses_custom_blocks, uses_custom_blocks),
        max_students = p_max_students,
        base_price = p_base_price
    WHERE id_lesson = p_id_lesson
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_lessons_delete(
  p_id_lesson uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.lessons
    WHERE id_lesson = p_id_lesson
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
