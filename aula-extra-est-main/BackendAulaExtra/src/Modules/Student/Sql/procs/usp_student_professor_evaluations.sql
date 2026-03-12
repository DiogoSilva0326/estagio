-- Student Professor Evaluations (Aluno -> Avaliações -> Professores)

CREATE OR REPLACE FUNCTION public.usp_student_professor_evaluations_submitted_select01(
  p_student_user_id uuid
)
RETURNS TABLE (
  id_professor_feedback uuid,
  id_professor uuid,
  professor_name text,
  rating integer,
  comments text,
  created_at timestamp
)
LANGUAGE sql
AS $$
  SELECT
    pf.id_professor_feedback,
    pf.id_professor,
    COALESCE(
      NULLIF(u.display_name, ''),
      NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''),
      NULLIF(u.username, ''),
      u.email
    ) AS professor_name,
    pf.rating,
    pf.comments,
    pf.created_at
  FROM public.professor_feedback pf
  JOIN public.professors p ON p.id_professor = pf.id_professor
  JOIN public.users u ON u.id_user = p.id_user
  WHERE pf.id_user = p_student_user_id
    AND pf.is_valid = true
  ORDER BY pf.created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_student_professor_evaluations_pending_select01(
  p_student_user_id uuid
)
RETURNS TABLE (
  id_professor uuid,
  professor_name text,
  last_lesson_start timestamp,
  last_lesson_end timestamp
)
LANGUAGE sql
AS $$
  WITH taught AS (
    SELECT
      l.id_professor,
      MAX(l.scheduled_start) AS last_lesson_start,
      MAX(l.scheduled_end) AS last_lesson_end
    FROM public.enrollments e
    JOIN public.lessons l ON l.id_lesson = e.id_lesson
    WHERE e.id_user = p_student_user_id
      AND l.id_professor IS NOT NULL
      AND l.scheduled_end IS NOT NULL
      AND l.scheduled_end <= now()
    GROUP BY l.id_professor
  )
  SELECT
    t.id_professor,
    COALESCE(
      NULLIF(u.display_name, ''),
      NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''),
      NULLIF(u.username, ''),
      u.email
    ) AS professor_name,
    t.last_lesson_start,
    t.last_lesson_end
  FROM taught t
  JOIN public.professors p ON p.id_professor = t.id_professor
  JOIN public.users u ON u.id_user = p.id_user
  LEFT JOIN public.professor_feedback pf
    ON pf.id_professor = t.id_professor
    AND pf.id_user = p_student_user_id
    AND pf.is_valid = true
  WHERE pf.id_professor_feedback IS NULL
  ORDER BY t.last_lesson_end DESC NULLS LAST;
$$;

CREATE OR REPLACE FUNCTION public.usp_student_professor_evaluations_pending_by_professor_select01(
  p_student_user_id uuid,
  p_professor_id uuid
)
RETURNS TABLE (
  id_professor uuid,
  professor_name text,
  last_lesson_start timestamp,
  last_lesson_end timestamp
)
LANGUAGE sql
AS $$
  WITH taught AS (
    SELECT
      l.id_professor,
      MAX(l.scheduled_start) AS last_lesson_start,
      MAX(l.scheduled_end) AS last_lesson_end
    FROM public.enrollments e
    JOIN public.lessons l ON l.id_lesson = e.id_lesson
    WHERE e.id_user = p_student_user_id
      AND l.id_professor = p_professor_id
      AND l.scheduled_end IS NOT NULL
      AND l.scheduled_end <= now()
    GROUP BY l.id_professor
  )
  SELECT
    t.id_professor,
    COALESCE(
      NULLIF(u.display_name, ''),
      NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''),
      NULLIF(u.username, ''),
      u.email
    ) AS professor_name,
    t.last_lesson_start,
    t.last_lesson_end
  FROM taught t
  JOIN public.professors p ON p.id_professor = t.id_professor
  JOIN public.users u ON u.id_user = p.id_user
  LEFT JOIN public.professor_feedback pf
    ON pf.id_professor = t.id_professor
    AND pf.id_user = p_student_user_id
    AND pf.is_valid = true
  WHERE pf.id_professor_feedback IS NULL
  LIMIT 1;
$$;
