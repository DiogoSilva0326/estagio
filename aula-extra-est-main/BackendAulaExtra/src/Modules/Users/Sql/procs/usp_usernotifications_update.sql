DROP FUNCTION IF EXISTS public.usp_usernotifications_update(int, text, text, boolean, boolean, int);
DROP FUNCTION IF EXISTS public.usp_usernotifications_update(uuid, text, text, boolean, boolean, uuid);

CREATE OR REPLACE FUNCTION public.usp_usernotifications_update(
    p_id uuid,
    p_title text DEFAULT NULL,
    p_message text DEFAULT NULL,
    p_is_read boolean DEFAULT NULL,
    p_inactive boolean DEFAULT NULL,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.user_notification
    SET
        title = COALESCE(p_title, title),
        message = COALESCE(p_message, message),
        is_read = COALESCE(p_is_read, is_read),
        inactive = COALESCE(p_inactive, inactive),
        last_update = now(),
        last_user_id = COALESCE(p_last_user_id, last_user_id)
    WHERE id = p_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
