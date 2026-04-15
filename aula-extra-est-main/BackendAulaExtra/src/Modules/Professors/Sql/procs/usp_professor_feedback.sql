CREATE OR REPLACE FUNCTION public.usp_professor_feedback_select_all01()
RETURNS SETOF public.professor_feedback
LANGUAGE sql
AS $$
    SELECT *
    FROM public.professor_feedback
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_feedback_global_rating_summary01()
RETURNS TABLE(avg_rating numeric, review_count integer)
LANGUAGE sql
STABLE
AS $$
    SELECT
        ROUND(COALESCE(AVG(pf.rating::numeric), 0), 1) AS avg_rating,
        COUNT(*)::int AS review_count
    FROM public.professor_feedback pf
    WHERE pf.is_valid = TRUE
        AND pf.rating IS NOT NULL;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_feedback_select_details01(
    p_id_professor_feedback uuid
)
RETURNS SETOF public.professor_feedback
LANGUAGE sql
AS $$
    SELECT *
    FROM public.professor_feedback
    WHERE id_professor_feedback = p_id_professor_feedback;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_feedback_insert(
    p_id_professor uuid,
    p_id_user uuid,
    p_is_valid boolean,
    p_rating integer,
    p_comments text,
    p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.professor_feedback (id_professor, id_user, is_valid, rating, comments, created_at)
    VALUES (
        p_id_professor,
        p_id_user,
        COALESCE(p_is_valid, true),
        p_rating,
        p_comments,
        COALESCE(p_created_at, now())
    )
    RETURNING id_professor_feedback;
$$;

-- Overload: accept timestamptz too (Npgsql DateTime UTC -> timestamptz)
CREATE OR REPLACE FUNCTION public.usp_professor_feedback_insert(
    p_id_professor uuid,
    p_id_user uuid,
    p_is_valid boolean,
    p_rating integer,
    p_comments text,
    p_created_at timestamp with time zone
)
RETURNS uuid
LANGUAGE sql
AS $$
    SELECT public.usp_professor_feedback_insert(
        p_id_professor,
        p_id_user,
        p_is_valid,
        p_rating,
        p_comments,
        p_created_at::timestamp
    );
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_feedback_update(
    p_id_professor_feedback uuid,
    p_id_professor uuid,
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
        UPDATE public.professor_feedback
        SET id_professor = p_id_professor,
            id_user = p_id_user,
            is_valid = COALESCE(p_is_valid, is_valid),
            rating = p_rating,
            comments = p_comments,
            created_at = p_created_at
        WHERE id_professor_feedback = p_id_professor_feedback
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_feedback_delete(
    p_id_professor_feedback uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.professor_feedback
        WHERE id_professor_feedback = p_id_professor_feedback
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
