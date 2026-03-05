CREATE OR REPLACE FUNCTION public.usp_usernotifications_select_details01(
    p_id uuid
)
RETURNS SETOF public.user_notification
LANGUAGE sql
AS $$
    SELECT un.*
    FROM public.user_notification un
    WHERE un.id = p_id;
$$;
