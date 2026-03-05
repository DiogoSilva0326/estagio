DROP FUNCTION IF EXISTS public.usp_areas_select_all01();
DROP FUNCTION IF EXISTS public.usp_areas_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_areas_insert01(character varying, text);
DROP FUNCTION IF EXISTS public.usp_areas_update01(uuid, character varying, text);
DROP FUNCTION IF EXISTS public.usp_areas_delete01(uuid);
DROP FUNCTION IF EXISTS public.usp_areas_ensure01(character varying, text);

CREATE OR REPLACE FUNCTION public.usp_areas_select_all01()
RETURNS SETOF public.areas
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.areas
  ORDER BY nome;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_areas_select_details01(
  p_id_area uuid
)
RETURNS SETOF public.areas
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.areas
  WHERE id_area = p_id_area;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_areas_insert01(
  p_nome varchar(150),
  p_descricao text
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.areas (nome, descricao, created_at, updated_at)
  VALUES (p_nome, p_descricao, now(), now())
  RETURNING id_area INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_areas_update01(
  p_id_area uuid,
  p_nome varchar(150),
  p_descricao text
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.areas
  SET nome = p_nome,
      descricao = p_descricao,
      updated_at = now()
  WHERE id_area = p_id_area;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_areas_delete01(
  p_id_area uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.areas
  WHERE id_area = p_id_area;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_areas_ensure01(
  p_nome varchar(150),
  p_descricao text
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  SELECT a.id_area
  INTO v_id
  FROM public.areas a
  WHERE lower(trim(a.nome)) = lower(trim(p_nome))
  LIMIT 1;

  IF v_id IS NOT NULL THEN
    RETURN v_id;
  END IF;

  INSERT INTO public.areas (nome, descricao, created_at, updated_at)
  VALUES (p_nome, p_descricao, now(), now())
  RETURNING id_area INTO v_id;

  RETURN v_id;
END;
$$;
