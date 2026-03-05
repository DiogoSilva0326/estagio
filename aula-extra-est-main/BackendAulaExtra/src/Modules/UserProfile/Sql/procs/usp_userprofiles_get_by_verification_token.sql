-- Get user profile by email verification token
-- Uses SETOF to automatically match table structure
CREATE OR REPLACE FUNCTION public.usp_userprofiles_get_by_verification_token(
    p_token TEXT
)
RETURNS SETOF public.userprofiles AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.userprofiles
    WHERE email_verification_token = p_token
      AND inactive = false
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
