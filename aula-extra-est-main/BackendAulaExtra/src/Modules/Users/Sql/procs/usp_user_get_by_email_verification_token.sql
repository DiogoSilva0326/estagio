DROP FUNCTION IF EXISTS public.usp_user_get_by_email_verification_token(text,uuid);
DROP FUNCTION IF EXISTS public.usp_user_get_by_email_verification_token(text);

CREATE FUNCTION public.usp_user_get_by_email_verification_token(
    p_token text
)
RETURNS TABLE(
    id_user uuid,
    email text,
    email_verified_at timestamptz
)
LANGUAGE sql
AS $$
    SELECT u.id_user, u.email, p.email_verified_at
    FROM public.user_profile p
    INNER JOIN public.users u ON p.user_id = u.id_user
    WHERE p.email_verification_token = p_token
    ORDER BY u.id_user
    LIMIT 1;
$$;
