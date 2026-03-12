CREATE OR REPLACE FUNCTION public.usp_complaint_resolutions_select_all01()
RETURNS SETOF public.complaint_resolutions
LANGUAGE sql
AS $$
  SELECT *
  FROM public.complaint_resolutions
  ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaint_resolutions_select_details01(
  p_id_complaint_resolution uuid
)
RETURNS SETOF public.complaint_resolutions
LANGUAGE sql
AS $$
  SELECT *
  FROM public.complaint_resolutions
  WHERE id_complaint_resolution = p_id_complaint_resolution;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaint_resolutions_insert(
  p_complaint_id uuid,
  p_admin_user_id uuid,
  p_resolution_status varchar(50),
  p_resolution_notes text,
  p_resolved_at timestamp,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.complaint_resolutions (
    complaint_id,
    admin_user_id,
    resolution_status,
    resolution_notes,
    resolved_at,
    created_at,
    updated_at
  )
  VALUES (
    p_complaint_id,
    p_admin_user_id,
    p_resolution_status,
    p_resolution_notes,
    p_resolved_at,
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id_complaint_resolution;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaint_resolutions_update(
  p_id_complaint_resolution uuid,
  p_complaint_id uuid,
  p_admin_user_id uuid,
  p_resolution_status varchar(50),
  p_resolution_notes text,
  p_resolved_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.complaint_resolutions
    SET complaint_id = p_complaint_id,
        admin_user_id = p_admin_user_id,
        resolution_status = p_resolution_status,
        resolution_notes = p_resolution_notes,
        resolved_at = p_resolved_at,
        updated_at = now()
    WHERE id_complaint_resolution = p_id_complaint_resolution
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_complaint_resolutions_delete(
  p_id_complaint_resolution uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.complaint_resolutions
    WHERE id_complaint_resolution = p_id_complaint_resolution
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
