-- Get UserProfile by User ID
-- Uses SETOF to automatically match table structure
DROP FUNCTION IF EXISTS public.usp_userprofiles_get_by_id(integer);
DROP FUNCTION IF EXISTS public.usp_userprofiles_get_by_id(uuid);

CREATE FUNCTION public.usp_userprofiles_get_by_id(
  p_id UUID
)
RETURNS SETOF public.userprofiles
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.userprofiles
    WHERE user_id = p_id
      AND inactive = false
    LIMIT 1;
END;
$$;
