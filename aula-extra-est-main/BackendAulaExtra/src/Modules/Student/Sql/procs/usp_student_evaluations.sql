-- Student Evaluations (Aluno -> Avaliações)

CREATE OR REPLACE FUNCTION public.usp_student_evaluations_submitted_select01(
  p_student_user_id uuid
)
RETURNS TABLE (
  id_lesson_feedback uuid,
  id_lesson uuid,
  id_professor uuid,
  professor_name text,
  subject text,
  scheduled_start timestamp,
  scheduled_end timestamp,
  rating integer,
  comments text,
  created_at timestamp
)
LANGUAGE sql
AS $$
  SELECT
    lf.id_lesson_feedback,
    lf.id_lesson,
    l.id_professor,
    COALESCE(
      NULLIF(u.display_name, ''),
      NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''),
      NULLIF(u.username, ''),
      u.email
    ) AS professor_name,
    d.nome AS subject,
    l.scheduled_start,
    l.scheduled_end,
    lf.rating,
    lf.comments,
    lf.created_at
  FROM public.lesson_feedback lf
  JOIN public.lessons l ON l.id_lesson = lf.id_lesson
  LEFT JOIN public.professors p ON p.id_professor = l.id_professor
  LEFT JOIN public.users u ON u.id_user = p.id_user
  LEFT JOIN public.courses c ON c.id_course = l.id_course
  LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
  WHERE lf.id_user = p_student_user_id
    AND lf.is_valid = true
  ORDER BY lf.created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_student_evaluations_pending_latest_select01(
  p_student_user_id uuid
)
RETURNS TABLE (
  id_lesson uuid,
  id_professor uuid,
  professor_name text,
  subject text,
  scheduled_start timestamp,
  scheduled_end timestamp
)
LANGUAGE sql
AS $$
  SELECT
    l.id_lesson,
    l.id_professor,
    COALESCE(
      NULLIF(u.display_name, ''),
      NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''),
      NULLIF(u.username, ''),
      u.email
    ) AS professor_name,
    d.nome AS subject,
    l.scheduled_start,
    l.scheduled_end
  FROM public.enrollments e
  JOIN public.lessons l ON l.id_lesson = e.id_lesson
  JOIN public.professors p ON p.id_professor = l.id_professor
  JOIN public.users u ON u.id_user = p.id_user
  LEFT JOIN public.courses c ON c.id_course = l.id_course
  LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
  LEFT JOIN public.lesson_feedback lf
    ON lf.id_lesson = l.id_lesson
    AND lf.id_user = p_student_user_id
    AND lf.is_valid = true
  WHERE e.id_user = p_student_user_id
    AND l.id_professor IS NOT NULL
    AND l.scheduled_end IS NOT NULL
    AND l.scheduled_end <= now()
    AND lf.id_lesson_feedback IS NULL
  ORDER BY l.scheduled_start DESC NULLS LAST;
$$;

CREATE OR REPLACE FUNCTION public.usp_student_evaluations_pending_by_lesson_select01(
  p_student_user_id uuid,
  p_lesson_id uuid
)
RETURNS TABLE (
  id_lesson uuid,
  id_professor uuid,
  professor_name text,
  subject text,
  scheduled_start timestamp,
  scheduled_end timestamp
)
LANGUAGE sql
AS $$
  SELECT
    l.id_lesson,
    l.id_professor,
    COALESCE(
      NULLIF(u.display_name, ''),
      NULLIF(BTRIM(CONCAT(u.first_name, ' ', u.last_name)), ''),
      NULLIF(u.username, ''),
      u.email
    ) AS professor_name,
    d.nome AS subject,
    l.scheduled_start,
    l.scheduled_end
  FROM public.enrollments e
  JOIN public.lessons l ON l.id_lesson = e.id_lesson
  JOIN public.professors p ON p.id_professor = l.id_professor
  JOIN public.users u ON u.id_user = p.id_user
  LEFT JOIN public.courses c ON c.id_course = l.id_course
  LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
  LEFT JOIN public.lesson_feedback lf
    ON lf.id_lesson = l.id_lesson
    AND lf.id_user = p_student_user_id
    AND lf.is_valid = true
  WHERE e.id_user = p_student_user_id
    AND l.id_lesson = p_lesson_id
    AND l.id_professor IS NOT NULL
    AND l.scheduled_end IS NOT NULL
    AND l.scheduled_end <= now()
    AND lf.id_lesson_feedback IS NULL
  LIMIT 1;
$$;
