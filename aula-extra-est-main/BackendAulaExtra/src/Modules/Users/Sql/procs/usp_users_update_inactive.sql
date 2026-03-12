CREATE OR REPLACE FUNCTION public.usp_users_update_inactive(
    p_id uuid,
    p_inactive boolean,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.users
    SET inactive = p_inactive,
        last_update = now(),
        last_user_id = COALESCE(p_last_user_id, last_user_id)
    WHERE id_user = p_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
