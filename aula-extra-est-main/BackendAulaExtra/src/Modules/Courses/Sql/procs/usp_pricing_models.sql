DROP FUNCTION IF EXISTS public.usp_pricing_models_select_all01();
DROP FUNCTION IF EXISTS public.usp_pricing_models_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_pricing_models_insert(character varying, character varying, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_pricing_models_update(uuid, character varying, character varying);
DROP FUNCTION IF EXISTS public.usp_pricing_models_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_pricing_models_select_all01()
RETURNS SETOF public.pricing_models
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.pricing_models
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pricing_models_select_details01(
  p_id_pricing_model uuid
)
RETURNS SETOF public.pricing_models
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.pricing_models
  WHERE id_pricing_model = p_id_pricing_model;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pricing_models_insert(
  p_name varchar(100),
  p_description varchar(255),
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.pricing_models (name, description, created_at, updated_at)
  VALUES (p_name, p_description, COALESCE(p_created_at, now()), COALESCE(p_updated_at, now()))
  RETURNING id_pricing_model INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pricing_models_update(
  p_id_pricing_model uuid,
  p_name varchar(100),
  p_description varchar(255)
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.pricing_models
  SET name = p_name,
      description = p_description,
      updated_at = now()
  WHERE id_pricing_model = p_id_pricing_model;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_pricing_models_delete(
  p_id_pricing_model uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.pricing_models
  WHERE id_pricing_model = p_id_pricing_model;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
