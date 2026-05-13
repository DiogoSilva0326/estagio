CREATE OR REPLACE FUNCTION public.usp_admin_dashboard_overview()
RETURNS jsonb
LANGUAGE sql
STABLE
AS $$
WITH kpis AS (
    SELECT
        (
            SELECT COUNT(*)::int
            FROM public.professors p
            WHERE COALESCE(p.is_active, false) = true
              AND COALESCE(p.is_verified, false) = true
              AND COALESCE(p.is_verified_iban, false) = true
        ) AS "activeProfessionals",
        (
            SELECT COUNT(*)::int
            FROM public.user_role ur
            JOIN public.role r ON r.id = ur.role_id
            WHERE lower(r.description) = 'aluno'
        ) AS "totalStudents",
        (
            SELECT COUNT(*)::int
            FROM public.reservations r
            WHERE date_trunc('month', COALESCE(r.start_time, r.created_at)) = date_trunc('month', now())
        ) AS "monthlySessions",
        (
            SELECT COALESCE(SUM(rp.amount), 0)
            FROM public.reservation_payments rp
            WHERE lower(COALESCE(rp.status, '')) = 'paid'
              AND date_trunc('month', COALESCE(rp.created_at, now())) = date_trunc('month', now())
        ) AS "monthlyRevenue",
        (
            SELECT COUNT(*)::int
            FROM public.professors p
            WHERE COALESCE(p.is_active, false) = false
               OR COALESCE(p.is_verified, false) = false
               OR COALESCE(p.is_verified_iban, false) = false
        ) AS "pendingApplications",
        (
            SELECT COUNT(*)::int
            FROM public.reservation_payments rp
            WHERE lower(COALESCE(rp.status, '')) = 'pending'
        ) AS "pendingPayments"
),
recent_sessions AS (
    SELECT
        COALESCE(student.display_name, CONCAT_WS(' ', student.first_name, student.last_name), student.username, student.email) AS "studentName",
        COALESCE(tutor.display_name, CONCAT_WS(' ', tutor.first_name, tutor.last_name), tutor.username, tutor.email) AS "tutorName",
        COALESCE(d.nome, c.name, 'Sessão') AS "subjectName",
        COALESCE(r.start_time, l.scheduled_start) AS "startsAt",
        COALESCE(r.end_time, l.scheduled_end) AS "endsAt",
        COALESCE(
            l.duration_minutes,
            EXTRACT(EPOCH FROM (COALESCE(r.end_time, l.scheduled_end) - COALESCE(r.start_time, l.scheduled_start))) / 60,
            0
        )::int AS "durationMinutes",
        COALESCE(r.status, 'scheduled') AS "status"
    FROM public.reservations r
    JOIN public.lessons l ON l.id_lesson = r.id_lesson
    JOIN public.users student ON student.id_user = r.id_user
    LEFT JOIN public.professors p ON p.id_professor = l.id_professor
    LEFT JOIN public.users tutor ON tutor.id_user = p.id_user
    LEFT JOIN public.courses c ON c.id_course = l.id_course
    LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
    ORDER BY ABS(EXTRACT(EPOCH FROM (COALESCE(r.start_time, l.scheduled_start) - now()))) ASC,
             COALESCE(r.start_time, l.scheduled_start) DESC
    LIMIT 6
),
popular_subjects AS (
    SELECT
        COALESCE(d.nome, c.name, 'Outro') AS "label",
        COUNT(DISTINCT c.id_professor)::int AS "professionalCount"
    FROM public.courses c
    LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
    GROUP BY COALESCE(d.nome, c.name, 'Outro')
    ORDER BY "professionalCount" DESC, "label" ASC
    LIMIT 3
),
services AS (
    SELECT 'API Backend'::text AS "label", 'online'::text AS "kind", true AS "online", 0::int AS "count"
    UNION ALL
    SELECT 'Videochamadas', 'online', true, 0
    UNION ALL
    SELECT 'Candidaturas Pendentes', 'count', false, k."pendingApplications" FROM kpis k
    UNION ALL
    SELECT 'Pagamentos Pendentes', 'count', false, k."pendingPayments" FROM kpis k
)
SELECT jsonb_build_object(
    'kpis', COALESCE((SELECT to_jsonb(k) FROM kpis k), '{}'::jsonb),
    'recentSessions', COALESCE((SELECT jsonb_agg(to_jsonb(rs)) FROM recent_sessions rs), '[]'::jsonb),
    'services', COALESCE((SELECT jsonb_agg(to_jsonb(s)) FROM services s), '[]'::jsonb),
    'popularSubjects', COALESCE((SELECT jsonb_agg(to_jsonb(ps)) FROM popular_subjects ps), '[]'::jsonb)
);
$$;