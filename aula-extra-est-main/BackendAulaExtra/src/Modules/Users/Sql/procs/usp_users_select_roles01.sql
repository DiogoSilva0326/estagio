DROP FUNCTION IF EXISTS public.usp_users_select_roles01(int);

CREATE OR REPLACE FUNCTION public.usp_users_select_roles01(
    p_userid uuid
)
RETURNS TABLE(
    role_id int,
    description text
)
LANGUAGE sql
AS $$
    SELECT r.id AS role_id, r.description
    FROM public.user_role ur
    INNER JOIN public.role r ON r.id = ur.role_id
    WHERE ur.user_id = p_userid
    ORDER BY r.id;
$$;
