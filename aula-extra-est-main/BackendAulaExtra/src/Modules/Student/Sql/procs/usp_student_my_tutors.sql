DROP FUNCTION IF EXISTS public.usp_student_my_tutors_select01(uuid, uuid);

CREATE OR REPLACE FUNCTION public.usp_student_my_tutors_select01(
  p_student_user_id uuid,
  p_area_id uuid DEFAULT NULL
)
RETURNS TABLE (
  id_professor uuid,
  tutor_user_id uuid,
  tutor_username text,
  tutor_name text,
  avatar_url text,
  subjects text[],
  last_lesson_subject text,
  last_lesson_start timestamp,
  avg_rating double precision,
  review_count integer,
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
  LEFT JOIN public.courses c ON c.id_course = l.id_course
  LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
  WHERE e.id_user = p_student_user_id
    AND (p_area_id IS NULL OR d.id_area = p_area_id)
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
),
subject_agg AS (
  SELECT
    pd.id_professor,
    ARRAY_AGG(DISTINCT d.nome ORDER BY d.nome) AS subjects
  FROM public.professor_disciplina pd
  JOIN public.disciplinas d ON d.id_disciplina = pd.id_disciplina
  GROUP BY pd.id_professor
),
rating_agg AS (
  SELECT
    pf.id_professor,
    AVG(pf.rating::double precision) AS avg_rating,
    COUNT(*) FILTER (WHERE pf.rating IS NOT NULL) AS review_count
  FROM public.professor_feedback pf
  WHERE pf.is_valid = true
    AND pf.rating IS NOT NULL
  GROUP BY pf.id_professor
)
SELECT
  p.id_professor,
  u.id_user AS tutor_user_id,
  u.username AS tutor_username,
  COALESCE(NULLIF(u.display_name, ''), NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''), NULLIF(u.username, ''), u.email) AS tutor_name,
  COALESCE(NULLIF(p.photo, ''), NULLIF(up.profile_image_url, '')) AS avatar_url,
  COALESCE(sa.subjects, ARRAY[]::text[]) AS subjects,
  d.nome AS last_lesson_subject,
  latest.scheduled_start AS last_lesson_start,
  COALESCE(ra.avg_rating, 0)::double precision AS avg_rating,
  COALESCE(ra.review_count, 0)::integer AS review_count,
  CASE
    WHEN agg.total_lessons > 0 THEN LEAST(1.0, GREATEST(0.0, agg.completed_lessons::double precision / agg.total_lessons::double precision))
    ELSE 0.0
  END AS progress
FROM latest
JOIN public.professors p ON p.id_professor = latest.id_professor
JOIN public.users u ON u.id_user = p.id_user
LEFT JOIN public.userprofiles up ON up.user_id = u.id_user
LEFT JOIN public.courses c ON c.id_course = latest.id_course
LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
LEFT JOIN subject_agg sa ON sa.id_professor = latest.id_professor
LEFT JOIN rating_agg ra ON ra.id_professor = latest.id_professor
JOIN agg ON agg.id_professor = latest.id_professor
ORDER BY latest.scheduled_start DESC NULLS LAST;
$$;
