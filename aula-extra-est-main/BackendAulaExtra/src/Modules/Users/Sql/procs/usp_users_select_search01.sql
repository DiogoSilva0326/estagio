CREATE OR REPLACE FUNCTION public.usp_users_select_search01(
    p_search text,
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AU-ID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS TABLE(
    id_user uuid,
    first_name text,
    last_name text,
    email text,
    birth_date text,
    inactive boolean,
    last_update timestamptz
)
LANGUAGE sql
AS $$
    SELECT
        u.id_user,
        u.first_name,
        u.last_name,
        u.email,
        u.birth_date,
        u.inactive,
        u.last_update
    FROM public.users u
    WHERE (p_inactive IS NULL OR u.inactive = p_inactive)
      AND (
          p_search IS NULL
          OR p_search = ''
          OR u.email ILIKE '%' || p_search || '%'
          OR u.first_name ILIKE '%' || p_search || '%'
          OR u.last_name ILIKE '%' || p_search || '%'
      )
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-FIRSTNAME%' THEN u.first_name END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-FIRSTNAME%' THEN u.first_name END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-LASTNAME%'  THEN u.last_name  END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-LASTNAME%'  THEN u.last_name  END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-EMAIL%'     THEN u.email      END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-EMAIL%'     THEN u.email      END DESC,
        u.id_user ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
