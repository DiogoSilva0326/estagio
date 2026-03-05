DROP FUNCTION IF EXISTS public.usp_user_get_by_reset_token_and_store(text);

CREATE FUNCTION public.usp_user_get_by_reset_token_and_store(
    p_token text
)
RETURNS TABLE(
    id_user uuid,
    email text
)
LANGUAGE sql
AS $$
    SELECT u.id_user, u.email
    FROM public.user_profile p
    INNER JOIN public.users u ON p.user_id = u.id_user
    WHERE p.reset_password_token = p_token
      AND (p.reset_password_token_expiry IS NULL OR p.reset_password_token_expiry > now())
    ORDER BY u.id_user
    LIMIT 1;
$$;
