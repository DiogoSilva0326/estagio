DROP FUNCTION IF EXISTS public.usp_userprofile_set_email_verification_token(int, text);

CREATE OR REPLACE FUNCTION public.usp_userprofile_set_email_verification_token(
    p_user_id uuid,
    p_token text
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.user_profile
    SET email_verification_token = p_token,
        last_update = now()
    WHERE user_id = p_user_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
