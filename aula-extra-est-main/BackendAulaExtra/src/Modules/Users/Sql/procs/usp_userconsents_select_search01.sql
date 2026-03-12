CREATE OR REPLACE FUNCTION public.usp_userconsents_select_search01(
    p_search text,
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AUC-ID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS SETOF public.user_consents
LANGUAGE sql
AS $$
    SELECT c.*
    FROM public.user_consents c
    WHERE (p_inactive IS NULL OR c.inactive = p_inactive)
      AND (
          p_search IS NULL
          OR p_search = ''
          OR c.consent_type ILIKE '%' || p_search || '%'
          OR COALESCE(c.ip_address, '') ILIKE '%' || p_search || '%'
      )
    ORDER BY c.creation_date DESC, c.id ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
