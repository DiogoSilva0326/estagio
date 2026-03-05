CREATE OR REPLACE FUNCTION public.usp_usernotifications_select_summary01(
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AUN-ID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS TABLE(
    id uuid,
    title text,
    message text,
    is_read boolean,
    user_id uuid,
    last_update timestamptz
)
LANGUAGE sql
AS $$
    SELECT
        un.id,
        un.title,
        un.message,
        un.is_read,
        un.user_id,
        un.last_update
    FROM public.user_notification un
    WHERE (p_inactive IS NULL OR un.inactive = p_inactive)
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AUN-TITLE%'   THEN un.title END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DUN-TITLE%'   THEN un.title END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AUN-MESSAGE%' THEN un.message END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DUN-MESSAGE%' THEN un.message END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AUN-ID%'      THEN un.id END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DUN-ID%'      THEN un.id END DESC,
        un.id ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
