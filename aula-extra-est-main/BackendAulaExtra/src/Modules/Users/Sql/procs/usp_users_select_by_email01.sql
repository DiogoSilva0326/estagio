DROP FUNCTION IF EXISTS public.usp_users_select_by_email01(text);

CREATE FUNCTION public.usp_users_select_by_email01(
    p_email text
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
    WHERE lower(u.email) = lower(p_email)
    ORDER BY u.id_user
    LIMIT 1;
$$;
