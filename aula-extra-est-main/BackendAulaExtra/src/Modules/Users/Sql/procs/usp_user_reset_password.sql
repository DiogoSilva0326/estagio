CREATE OR REPLACE FUNCTION public.usp_user_reset_password(
    p_userid uuid,
    p_encryptedpassword text
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.users
    SET password = p_encryptedpassword
    WHERE id_user = p_userid;

    UPDATE public.user_profile
    SET reset_password_token = NULL,
        reset_password_token_expiry = NULL,
        last_update = now()
    WHERE user_id = p_userid;

    RETURN 1;
EXCEPTION WHEN OTHERS THEN
    RAISE;
END;
$$;
