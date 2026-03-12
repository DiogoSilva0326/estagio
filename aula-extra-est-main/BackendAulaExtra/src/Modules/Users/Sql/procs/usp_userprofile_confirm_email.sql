DROP FUNCTION IF EXISTS public.usp_userprofile_confirm_email(int);

CREATE OR REPLACE FUNCTION public.usp_userprofile_confirm_email(
    p_user_id uuid
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.user_profile
    SET email_verified_at = now(),
        email_verification_token = NULL,
        last_update = now()
    WHERE user_id = p_user_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
