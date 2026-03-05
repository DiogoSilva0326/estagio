CREATE OR REPLACE FUNCTION public.usp_users_select_summary01(
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AU-ID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS TABLE(
    id_user uuid,
    first_name text,
    email text,
    birth_date text,
    last_name text,
    last_update timestamptz
)
LANGUAGE sql
AS $$
    SELECT
        u.id_user,
        u.first_name,
        u.email,
        u.birth_date,
        u.last_name,
        u.last_update
    FROM public.users u
    WHERE (p_inactive IS NULL OR u.inactive = p_inactive)
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-FIRSTNAME%' THEN u.first_name END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-FIRSTNAME%' THEN u.first_name END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-LASTNAME%'  THEN u.last_name  END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-LASTNAME%'  THEN u.last_name  END DESC,
        u.id_user ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
