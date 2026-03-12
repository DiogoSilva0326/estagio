CREATE OR REPLACE FUNCTION public.usp_userconsents_select_details01(
    p_id uuid
)
RETURNS SETOF public.user_consents
LANGUAGE sql
AS $$
    SELECT c.*
    FROM public.user_consents c
    WHERE c.id = p_id;
$$;
