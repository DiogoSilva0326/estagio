DROP FUNCTION IF EXISTS public.usp_user_get_id_by_email_and_store(text);

CREATE FUNCTION public.usp_user_get_id_by_email_and_store(
  p_email text
)
RETURNS uuid
LANGUAGE sql
AS $$
    SELECT u.id_user
    FROM public.users u
  WHERE lower(u.email) = lower(p_email)
      AND (u.inactive = false OR u.inactive IS NULL)
    ORDER BY u.id_user
    LIMIT 1;
$$;
