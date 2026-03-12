DROP FUNCTION IF EXISTS public.usp_userprofile_select_summary01(boolean, text, int, int);

CREATE OR REPLACE FUNCTION public.usp_userprofile_select_summary01(
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AP-USERID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS TABLE(
    user_id uuid,
    total_spent numeric,
    prefered_language text,
    status text,
    phone text,
    email_verified_at timestamptz,
    inactive boolean,
    creation_date timestamptz,
    last_update timestamptz,
    last_user_id uuid
)
LANGUAGE sql
AS $$
    SELECT
        up.user_id,
        up.total_spent,
        up.prefered_language,
        up.status,
        up.phone,
        up.email_verified_at,
        up.inactive,
        up.creation_date,
        up.last_update,
        up.last_user_id
    FROM public.user_profile up
    WHERE (p_inactive IS NULL OR up.inactive = p_inactive)
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AP-USERID%' THEN up.user_id END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DP-USERID%' THEN up.user_id END DESC,
        up.user_id ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
