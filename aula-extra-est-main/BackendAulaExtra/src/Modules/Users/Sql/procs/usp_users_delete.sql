CREATE OR REPLACE FUNCTION public.usp_users_delete(
    p_id uuid
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.users WHERE id_user = p_id;
    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
