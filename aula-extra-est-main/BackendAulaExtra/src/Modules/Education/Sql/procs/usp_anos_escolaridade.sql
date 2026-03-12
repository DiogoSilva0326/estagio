DROP FUNCTION IF EXISTS public.usp_anos_escolaridade_select_all01();
DROP FUNCTION IF EXISTS public.usp_anos_escolaridade_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_anos_escolaridade_insert(character varying, integer, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_anos_escolaridade_update(uuid, character varying, integer);
DROP FUNCTION IF EXISTS public.usp_anos_escolaridade_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_anos_escolaridade_select_all01()
RETURNS SETOF public.anos_escolaridade
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.anos_escolaridade
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_anos_escolaridade_select_details01(
  p_id_ano_escolaridade uuid
)
RETURNS SETOF public.anos_escolaridade
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.anos_escolaridade
  WHERE id_ano_escolaridade = p_id_ano_escolaridade;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_anos_escolaridade_insert(
  p_nome varchar(100),
  p_ano_index integer,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.anos_escolaridade (nome, ano_index, created_at, updated_at)
  VALUES (p_nome, p_ano_index, COALESCE(p_created_at, now()), COALESCE(p_updated_at, now()))
  RETURNING id_ano_escolaridade INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_anos_escolaridade_update(
  p_id_ano_escolaridade uuid,
  p_nome varchar(100),
  p_ano_index integer
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.anos_escolaridade
  SET nome = p_nome,
      ano_index = p_ano_index,
      updated_at = now()
  WHERE id_ano_escolaridade = p_id_ano_escolaridade;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_anos_escolaridade_delete(
  p_id_ano_escolaridade uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.anos_escolaridade
  WHERE id_ano_escolaridade = p_id_ano_escolaridade;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
