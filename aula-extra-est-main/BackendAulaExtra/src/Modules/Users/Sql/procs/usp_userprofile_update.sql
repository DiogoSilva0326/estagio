DROP FUNCTION IF EXISTS public.usp_userprofile_update(int, numeric, text, text, text, timestamptz, boolean, int);

CREATE OR REPLACE FUNCTION public.usp_userprofile_update(
    p_user_id uuid,
    p_total_spent numeric DEFAULT NULL,
    p_prefered_language text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_phone text DEFAULT NULL,
    p_email_verified_at timestamptz DEFAULT NULL,
    p_inactive boolean DEFAULT NULL,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.user_profile
    SET
        total_spent = COALESCE(p_total_spent, total_spent),
        prefered_language = COALESCE(p_prefered_language, prefered_language),
        status = COALESCE(p_status, status),
        phone = COALESCE(p_phone, phone),
        email_verified_at = COALESCE(p_email_verified_at, email_verified_at),
        inactive = COALESCE(p_inactive, inactive),
        last_update = now(),
        last_user_id = COALESCE(p_last_user_id, last_user_id)
    WHERE user_id = p_user_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
