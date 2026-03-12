CREATE OR REPLACE FUNCTION public.usp_userconsents_select_summary01(
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
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AUC-ID%'          THEN c.id END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DUC-ID%'          THEN c.id END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AUC-GRANTEDAT%'   THEN c.granted_at END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DUC-GRANTEDAT%'   THEN c.granted_at END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AUC-CONSENTTYPE%' THEN c.consent_type END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DUC-CONSENTTYPE%' THEN c.consent_type END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AUC-GRANTED%'     THEN c.granted END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DUC-GRANTED%'     THEN c.granted END DESC,
        c.creation_date DESC,
        c.id ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
