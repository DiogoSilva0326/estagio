DROP FUNCTION IF EXISTS public.usp_usernotifications_insert(int, text, text, boolean, boolean, int);
DROP FUNCTION IF EXISTS public.usp_usernotifications_insert(uuid, text, text, boolean, boolean, uuid);

CREATE OR REPLACE FUNCTION public.usp_usernotifications_insert(
    p_user_id uuid,
    p_title text,
    p_message text,
    p_is_read boolean DEFAULT false,
    p_inactive boolean DEFAULT false,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE v_new_id uuid;
BEGIN
    INSERT INTO public.user_notification (
        user_id, title, message, is_read, inactive, creation_date, last_update, last_user_id
    )
    VALUES (
        p_user_id, p_title, p_message, p_is_read, p_inactive, now(), now(), p_last_user_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;
