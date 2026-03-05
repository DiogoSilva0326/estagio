DROP FUNCTION IF EXISTS public.usp_users_update(int,text,text,text,text,text,text,text,text,boolean,int);
DROP FUNCTION IF EXISTS public.usp_users_update(uuid,text,text,text,text,text,text,text,text,boolean,uuid);

CREATE FUNCTION public.usp_users_update(
    p_id uuid,
    p_email text DEFAULT NULL,
    p_password text DEFAULT NULL,
    p_first_name text DEFAULT NULL,
    p_last_name text DEFAULT NULL,
    p_username text DEFAULT NULL,
    p_display_name text DEFAULT NULL,
    p_mobile_number text DEFAULT NULL,
    p_nif text DEFAULT NULL,
    p_inactive boolean DEFAULT NULL,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.users
    SET
        email = COALESCE(p_email, email),
        password = COALESCE(p_password, password),
        first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        username = COALESCE(p_username, username),
        display_name = COALESCE(p_display_name, display_name),
        mobile_number = COALESCE(p_mobile_number, mobile_number),
        nif = COALESCE(p_nif, nif),
        inactive = COALESCE(p_inactive, inactive),
        last_update = now(),
        last_user_id = COALESCE(p_last_user_id, last_user_id)
    WHERE id_user = p_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
