CREATE OR REPLACE FUNCTION public.usp_userprofile_select_search01(
    p_search text,
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AP-USERID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS SETOF public.user_profile
LANGUAGE sql
AS $$
    SELECT up.*
    FROM public.user_profile up
    WHERE (p_inactive IS NULL OR up.inactive = p_inactive)
      AND (
          p_search IS NULL
          OR p_search = ''
          OR up.user_id::text ILIKE '%' || p_search || '%'
          OR COALESCE(up.phone, '') ILIKE '%' || p_search || '%'
          OR COALESCE(up.status, '') ILIKE '%' || p_search || '%'
      )
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AP-USERID%' THEN up.user_id END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DP-USERID%' THEN up.user_id END DESC,
        up.user_id ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
