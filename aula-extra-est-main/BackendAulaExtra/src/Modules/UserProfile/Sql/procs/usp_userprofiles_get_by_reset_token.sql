-- Get user profile by password reset token
-- Uses SETOF to automatically match table structure
CREATE OR REPLACE FUNCTION public.usp_userprofiles_get_by_reset_token(
    p_token TEXT
)
RETURNS SETOF public.userprofiles AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.userprofiles
    WHERE reset_password_token = p_token
      AND reset_password_token_expiry > NOW()
      AND inactive = false
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
