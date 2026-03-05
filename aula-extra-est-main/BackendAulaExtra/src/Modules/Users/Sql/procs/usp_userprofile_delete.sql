DROP FUNCTION IF EXISTS public.usp_userprofile_delete(int);

CREATE OR REPLACE FUNCTION public.usp_userprofile_delete(
    p_user_id uuid
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.user_profile WHERE user_id = p_user_id;
    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
