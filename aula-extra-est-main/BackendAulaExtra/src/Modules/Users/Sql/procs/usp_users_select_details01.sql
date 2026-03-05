DROP FUNCTION IF EXISTS public.usp_users_select_details01(int,boolean,text,int,int);
DROP FUNCTION IF EXISTS public.usp_users_select_details01(uuid,boolean,text,int,int);

CREATE FUNCTION public.usp_users_select_details01(
    p_id uuid DEFAULT NULL,
    p_inactive boolean DEFAULT NULL,
    p_ordercolumns text DEFAULT '.AU-ID',
    p_pagenumber int DEFAULT 1,
    p_pagesize int DEFAULT 50
)
RETURNS TABLE(
    id_user uuid,
    email text,
    password text,
    first_name text,
    last_name text,
    education_level text,
    birth_date text,
    auth_message text,
    username text,
    display_name text,
    mobile_number text,
    nif text,
    inactive boolean,
    creation_date timestamptz,
    last_update timestamptz,
    last_user_id uuid
)
LANGUAGE sql
AS $$
    SELECT
        u.id_user,
        u.email,
        u.password,
        u.first_name,
        u.last_name,
        u.education_level,
        u.birth_date,
        u.auth_message,
        u.username,
        u.display_name,
        u.mobile_number,
        u.nif,
        u.inactive,
        u.creation_date,
        u.last_update,
        u.last_user_id
    FROM public.users u
    WHERE (p_id IS NULL OR u.id_user = p_id)
      AND (p_inactive IS NULL OR u.inactive = p_inactive)
    ORDER BY
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-FIRSTNAME%' THEN u.first_name END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-FIRSTNAME%' THEN u.first_name END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-LASTNAME%'  THEN u.last_name  END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-LASTNAME%'  THEN u.last_name  END DESC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.AU-ID%'        THEN u.id_user    END ASC,
        CASE WHEN upper(p_ordercolumns) LIKE '%.DU-ID%'        THEN u.id_user    END DESC,
        u.id_user ASC
    OFFSET GREATEST((p_pagenumber - 1), 0) * GREATEST(p_pagesize, 0)
    LIMIT GREATEST(p_pagesize, 0);
$$;
