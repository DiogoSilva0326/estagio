DROP FUNCTION IF EXISTS public.usp_userprofile_set_reset_token(int, text, timestamptz);

CREATE OR REPLACE FUNCTION public.usp_userprofile_set_reset_token(
    p_user_id uuid,
    p_token text,
    p_expiry timestamptz
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.user_profile
    SET reset_password_token = p_token,
        reset_password_token_expiry = p_expiry,
        last_update = now()
    WHERE user_id = p_user_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
