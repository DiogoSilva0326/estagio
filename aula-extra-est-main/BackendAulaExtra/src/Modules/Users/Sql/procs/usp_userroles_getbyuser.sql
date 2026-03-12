DROP FUNCTION IF EXISTS public.usp_userroles_getbyuser(int);

CREATE OR REPLACE FUNCTION public.usp_userroles_getbyuser(
    p_userid uuid
)
RETURNS TABLE(
    role_id int,
    user_id uuid
)
LANGUAGE sql
AS $$
    SELECT ur.role_id, ur.user_id
    FROM public.user_role ur
    WHERE ur.user_id = p_userid
    ORDER BY ur.role_id;
$$;
