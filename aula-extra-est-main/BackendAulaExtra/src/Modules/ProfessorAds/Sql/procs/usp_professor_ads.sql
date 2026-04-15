DROP FUNCTION IF EXISTS public.usp_professor_ads_upsert01(uuid, uuid, varchar, varchar);
DROP FUNCTION IF EXISTS public.usp_professor_ads_delete01(uuid, uuid);

CREATE OR REPLACE FUNCTION public.usp_professor_ads_upsert01(
  p_id_professor uuid,
  p_id_course uuid,
  p_photo_url varchar,
  p_status varchar
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.professor_ads (
    id_professor,
    id_course,
    photo_url,
    status,
    created_at,
    updated_at
  )
  VALUES (
    p_id_professor,
    p_id_course,
    NULLIF(BTRIM(p_photo_url), ''),
    COALESCE(NULLIF(BTRIM(p_status), ''), 'published'),
    now(),
    now()
  )
  ON CONFLICT (id_course) DO UPDATE
  SET photo_url = EXCLUDED.photo_url,
      status = EXCLUDED.status,
      updated_at = now()
  RETURNING id_professor_ad INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_ads_delete01(
  p_id_professor_ad uuid,
  p_id_professor uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rows integer;
BEGIN
  DELETE FROM public.professor_ads
  WHERE id_professor_ad = p_id_professor_ad
    AND id_professor = p_id_professor;

  GET DIAGNOSTICS v_rows = ROW_COUNT;
  RETURN v_rows;
END;
$$;
