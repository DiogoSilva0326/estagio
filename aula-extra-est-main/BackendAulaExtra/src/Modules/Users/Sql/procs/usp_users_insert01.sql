DROP FUNCTION IF EXISTS public.usp_users_insert01(text,text,text,text,text,text,text,text,text,text,boolean,int);
DROP FUNCTION IF EXISTS public.usp_users_insert01(text,text,text,text,text,text,text,text,text,text,boolean,uuid);

CREATE FUNCTION public.usp_users_insert01(
    p_email text,
    p_password text DEFAULT NULL,
    p_first_name text DEFAULT NULL,
    p_last_name text DEFAULT NULL,
    p_username text DEFAULT NULL,
    p_display_name text DEFAULT NULL,
    p_birth_date text DEFAULT NULL,
    p_auth_message text DEFAULT NULL,
    p_mobile_number text DEFAULT NULL,
    p_nif text DEFAULT NULL,
    p_inactive boolean DEFAULT false,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE v_new_id uuid;
BEGIN
    INSERT INTO public.users (
        email, password, first_name, last_name, username, display_name, birth_date,
        auth_message, mobile_number, nif, inactive, creation_date, last_update, last_user_id
    )
    VALUES (
        p_email, p_password, p_first_name, p_last_name, COALESCE(p_username, p_email), p_display_name, p_birth_date,
        p_auth_message, p_mobile_number, p_nif, p_inactive,
        now(), now(), p_last_user_id
    )
    RETURNING id_user INTO v_new_id;

    RETURN v_new_id;
END;
$$;
