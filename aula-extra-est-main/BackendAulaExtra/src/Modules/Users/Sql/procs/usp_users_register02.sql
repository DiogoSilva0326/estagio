DROP FUNCTION IF EXISTS public.usp_users_register02(text,text,text,text,text,text);
DROP FUNCTION IF EXISTS public.usp_users_register02(text,text,text,text,text);

CREATE FUNCTION public.usp_users_register02(
    p_firstname text,
    p_email text,
    p_password text,
    p_lastname text,
    p_birthdate text,
    p_username text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id uuid;
    v_admin_id uuid;
    v_default_role_id int;
BEGIN
    IF p_firstname IS NULL THEN RAISE EXCEPTION 'parameter firstName can not be null'; END IF;
    IF p_lastname IS NULL THEN RAISE EXCEPTION 'parameter lastName can not be null'; END IF;
    IF p_email IS NULL THEN RAISE EXCEPTION 'parameter email can not be null'; END IF;
    IF p_password IS NULL THEN RAISE EXCEPTION 'parameter password can not be null'; END IF;
    IF p_birthdate IS NULL THEN RAISE EXCEPTION 'parameter birthDate can not be null'; END IF;

    IF EXISTS (
        SELECT 1 FROM public.users u
        WHERE lower(u.email) = lower(p_email)
    ) THEN
        RAISE EXCEPTION 'email already registered';
    END IF;

    SELECT id_user
    INTO v_admin_id
    FROM public.users
    WHERE first_name = 'Administrador'
    ORDER BY creation_date NULLS LAST, last_update NULLS LAST
    LIMIT 1;

    INSERT INTO public.users (
        first_name, last_name, email, password, birth_date, username, inactive, creation_date, last_update, last_user_id
    )
    VALUES (
        p_firstname, p_lastname, p_email, p_password, p_birthdate, COALESCE(p_username, p_email), false, now(), now(), v_admin_id
    )
    RETURNING id_user INTO v_new_id;

    -- Default: new users are 'aluno'. Fallback to 'Standard' if role rows were not created.
    SELECT id INTO v_default_role_id FROM public.role WHERE description = 'aluno' ORDER BY id LIMIT 1;
    IF v_default_role_id IS NULL THEN
        SELECT id INTO v_default_role_id FROM public.role WHERE description = 'Standard' ORDER BY id LIMIT 1;
    END IF;

    IF v_default_role_id IS NOT NULL THEN
        INSERT INTO public.user_role (user_id, role_id)
        VALUES (v_new_id, v_default_role_id)
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN v_new_id;
END;
$$;
