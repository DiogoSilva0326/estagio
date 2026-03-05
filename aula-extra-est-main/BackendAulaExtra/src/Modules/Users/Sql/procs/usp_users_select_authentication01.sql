DROP FUNCTION IF EXISTS public.usp_users_select_authentication01(text,text,uuid,boolean,text,int,int);
DROP FUNCTION IF EXISTS public.usp_users_select_authentication01(text,text,boolean,text,int,int);

CREATE FUNCTION public.usp_users_select_authentication01(
    p_email text,
    p_password text,
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AU-ID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS TABLE(
    id_user uuid,
    email text,
    first_name text,
    last_name text,
    birth_date text,
    last_update timestamptz
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset int;
    v_limit int;
BEGIN
    v_limit := GREATEST(COALESCE(p_pagesize, 0), 0);
    v_offset := GREATEST(COALESCE(p_pagenumber, 1) - 1, 0) * v_limit;

    RETURN QUERY
    SELECT
        u.id_user,
        u.email,
        u.first_name,
        u.last_name,
        u.birth_date,
        u.last_update
    FROM public.users u
    WHERE lower(u.email) = lower(p_email)
      AND u.password = p_password
      AND (p_inactive IS NULL OR u.inactive = p_inactive)
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-FIRSTNAME%' THEN u.first_name END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-FIRSTNAME%' THEN u.first_name END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-LASTNAME%'  THEN u.last_name  END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-LASTNAME%'  THEN u.last_name  END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-EMAIL%'     THEN u.email      END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-EMAIL%'     THEN u.email      END DESC,
        u.id_user ASC
    OFFSET v_offset
    LIMIT v_limit;
END;
$$;
