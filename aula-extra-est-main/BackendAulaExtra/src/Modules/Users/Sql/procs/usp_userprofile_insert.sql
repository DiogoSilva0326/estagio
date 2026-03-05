DROP FUNCTION IF EXISTS public.usp_userprofile_insert(int, numeric, text, text, text, boolean, int);

CREATE OR REPLACE FUNCTION public.usp_userprofile_insert(
    p_user_id uuid,
    p_total_spent numeric DEFAULT NULL,
    p_prefered_language text DEFAULT NULL,
    p_status text DEFAULT NULL,
    p_phone text DEFAULT NULL,
    p_inactive boolean DEFAULT false,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profile (
        user_id, total_spent, prefered_language, status, phone,
        inactive, creation_date, last_update, last_user_id
    )
    VALUES (
        p_user_id, p_total_spent, p_prefered_language, p_status, p_phone,
        p_inactive, now(), now(), p_last_user_id
    )
    ON CONFLICT (user_id) DO UPDATE SET
        total_spent = EXCLUDED.total_spent,
        prefered_language = EXCLUDED.prefered_language,
        status = EXCLUDED.status,
        phone = EXCLUDED.phone,
        inactive = EXCLUDED.inactive,
        last_update = now(),
        last_user_id = COALESCE(EXCLUDED.last_user_id, public.user_profile.last_user_id);

    RETURN 1;
END;
$$;
