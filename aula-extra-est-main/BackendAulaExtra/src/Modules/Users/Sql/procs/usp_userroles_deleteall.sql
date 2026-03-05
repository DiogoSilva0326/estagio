DROP FUNCTION IF EXISTS public.usp_userroles_deleteall(int);

CREATE OR REPLACE FUNCTION public.usp_userroles_deleteall(
    p_userid uuid
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.user_role WHERE user_id = p_userid;
    RETURN 1;
END;
$$;
