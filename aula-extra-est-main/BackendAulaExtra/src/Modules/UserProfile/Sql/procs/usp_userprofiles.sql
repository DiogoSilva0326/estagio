CREATE OR REPLACE FUNCTION public.usp_userprofiles_select_all01()
RETURNS SETOF public.userprofiles
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.userprofiles
  WHERE inactive = false
  ORDER BY id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_userprofiles_select_details01(
  p_user_id uuid
)
RETURNS SETOF public.userprofiles
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.userprofiles
  WHERE user_id = p_user_id
    AND inactive = false
  LIMIT 1;
END;
$$;
