CREATE OR REPLACE FUNCTION public.usp_usernotifications_select_search01(
    p_search text,
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AUN-ID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS SETOF public.user_notification
LANGUAGE sql
AS $$
    SELECT un.*
    FROM public.user_notification un
    WHERE (p_inactive IS NULL OR un.inactive = p_inactive)
      AND (
          p_search IS NULL
          OR p_search = ''
          OR un.title ILIKE '%' || p_search || '%'
          OR un.message ILIKE '%' || p_search || '%'
      )
    ORDER BY un.last_update DESC, un.id ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
