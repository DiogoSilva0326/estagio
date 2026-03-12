DROP FUNCTION IF EXISTS public.usp_userconsents_insert(uuid, int, text, boolean, timestamptz, timestamptz, text, boolean, int);

CREATE OR REPLACE FUNCTION public.usp_userconsents_insert(
    p_id uuid,
    p_user_id uuid,
    p_consent_type text,
    p_granted boolean,
    p_granted_at timestamptz DEFAULT NULL,
    p_revoked_at timestamptz DEFAULT NULL,
    p_ip_address text DEFAULT NULL,
    p_inactive boolean DEFAULT false,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_consents (
        id, user_id, consent_type, granted, granted_at, revoked_at,
        ip_address, inactive, creation_date, last_update, last_user_id
    )
    VALUES (
        p_id, p_user_id, p_consent_type, p_granted, p_granted_at, p_revoked_at,
        p_ip_address, p_inactive, now(), now(), p_last_user_id
    );

    RETURN 1;
END;
$$;
