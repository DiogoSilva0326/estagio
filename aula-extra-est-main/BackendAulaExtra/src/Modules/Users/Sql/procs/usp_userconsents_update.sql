DROP FUNCTION IF EXISTS public.usp_userconsents_update(uuid, boolean, timestamptz, timestamptz, text, boolean, int);

CREATE OR REPLACE FUNCTION public.usp_userconsents_update(
    p_id uuid,
    p_granted boolean DEFAULT NULL,
    p_granted_at timestamptz DEFAULT NULL,
    p_revoked_at timestamptz DEFAULT NULL,
    p_ip_address text DEFAULT NULL,
    p_inactive boolean DEFAULT NULL,
    p_last_user_id uuid DEFAULT NULL
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.user_consents
    SET
        granted = COALESCE(p_granted, granted),
        granted_at = COALESCE(p_granted_at, granted_at),
        revoked_at = COALESCE(p_revoked_at, revoked_at),
        ip_address = COALESCE(p_ip_address, ip_address),
        inactive = COALESCE(p_inactive, inactive),
        last_update = now(),
        last_user_id = COALESCE(p_last_user_id, last_user_id)
    WHERE id = p_id;

    RETURN CASE WHEN FOUND THEN 1 ELSE 0 END;
END;
$$;
