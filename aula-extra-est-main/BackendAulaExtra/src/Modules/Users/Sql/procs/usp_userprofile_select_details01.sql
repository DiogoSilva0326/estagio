DROP FUNCTION IF EXISTS public.usp_userprofile_select_details01(int, boolean);

CREATE OR REPLACE FUNCTION public.usp_userprofile_select_details01(
    p_user_id uuid,
    p_inactive boolean DEFAULT NULL
)
RETURNS TABLE(
    user_id uuid,
    total_spent numeric,
    reset_password_token_expiry timestamptz,
    reset_password_token text,
    email_verification_token text,
    prefered_language text,
    status text,
    phone text,
    email_verified_at timestamptz,
    inactive boolean,
    creation_date timestamptz,
    last_update timestamptz,
    last_user_id uuid
)
LANGUAGE sql
AS $$
    SELECT
        up.user_id,
        up.total_spent,
        up.reset_password_token_expiry,
        up.reset_password_token,
        up.email_verification_token,
        up.prefered_language,
        up.status,
        up.phone,
        up.email_verified_at,
        up.inactive,
        up.creation_date,
        up.last_update,
        up.last_user_id
    FROM public.user_profile up
    WHERE up.user_id = p_user_id
      AND (p_inactive IS NULL OR up.inactive = p_inactive);
$$;
