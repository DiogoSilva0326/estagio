DROP FUNCTION IF EXISTS public.usp_student_my_tutors_select01(uuid);

CREATE OR REPLACE FUNCTION public.usp_student_my_tutors_select01(
  p_student_user_id uuid
)
RETURNS TABLE (
  id_professor uuid,
  tutor_user_id uuid,
  tutor_name text,
  last_lesson_subject text,
  last_lesson_start timestamp,
  last_lesson_rating double precision,
  progress double precision
)
LANGUAGE sql
AS $$
WITH my_lessons AS (
  SELECT
    l.id_professor,
    l.id_lesson,
    l.scheduled_start,
    l.scheduled_end,
    l.id_course,
    e.created_at AS enrollment_created_at,
    ROW_NUMBER() OVER (
      PARTITION BY l.id_professor
      ORDER BY l.scheduled_start DESC NULLS LAST, e.created_at DESC
    ) AS rn
  FROM public.enrollments e
  JOIN public.lessons l ON l.id_lesson = e.id_lesson
  WHERE e.id_user = p_student_user_id
),
latest AS (
  SELECT *
  FROM my_lessons
  WHERE rn = 1
),
agg AS (
  SELECT
    id_professor,
    COUNT(*) AS total_lessons,
    COUNT(*) FILTER (WHERE scheduled_end IS NOT NULL AND scheduled_end <= now()) AS completed_lessons
  FROM my_lessons
  GROUP BY id_professor
)
SELECT
  p.id_professor,
  u.id_user AS tutor_user_id,
  COALESCE(NULLIF(u.display_name, ''), NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''), NULLIF(u.username, ''), u.email) AS tutor_name,
  d.nome AS last_lesson_subject,
  latest.scheduled_start AS last_lesson_start,
  lf.rating::double precision AS last_lesson_rating,
  CASE
    WHEN agg.total_lessons > 0 THEN LEAST(1.0, GREATEST(0.0, agg.completed_lessons::double precision / agg.total_lessons::double precision))
    ELSE 0.0
  END AS progress
FROM latest
JOIN public.professors p ON p.id_professor = latest.id_professor
JOIN public.users u ON u.id_user = p.id_user
LEFT JOIN public.courses c ON c.id_course = latest.id_course
LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
LEFT JOIN public.lesson_feedback lf
  ON lf.id_lesson = latest.id_lesson
  AND lf.id_user = p_student_user_id
  AND lf.is_valid = true
JOIN agg ON agg.id_professor = latest.id_professor
ORDER BY latest.scheduled_start DESC NULLS LAST;
$$;
