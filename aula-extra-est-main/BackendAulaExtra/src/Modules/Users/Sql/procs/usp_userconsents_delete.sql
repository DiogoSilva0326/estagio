CREATE OR REPLACE FUNCTION public.usp_userconsents_delete(
    p_id uuid
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.user_consents WHERE id = p_id;
    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
