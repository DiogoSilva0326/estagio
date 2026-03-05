DROP FUNCTION IF EXISTS public.usp_userroles_insert(int, int);

CREATE OR REPLACE FUNCTION public.usp_userroles_insert(
    p_userid uuid,
    p_roleid int
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_role (user_id, role_id)
    VALUES (p_userid, p_roleid)
    ON CONFLICT DO NOTHING;
    RETURN 1;
END;
$$;
