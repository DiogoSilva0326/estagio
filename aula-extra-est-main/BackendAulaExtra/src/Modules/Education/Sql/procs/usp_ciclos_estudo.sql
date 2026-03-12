DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_select_all01();
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_insert(character varying, text, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_update(uuid, character varying, text);
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_select_all01()
RETURNS SETOF public.ciclos_estudo
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.ciclos_estudo
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_select_details01(
  p_id_ciclo_estudo uuid
)
RETURNS SETOF public.ciclos_estudo
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.ciclos_estudo
  WHERE id_ciclo_estudo = p_id_ciclo_estudo;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_insert(
  p_nome varchar(150),
  p_descricao text,
  p_created_at timestamp,
  p_updated_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.ciclos_estudo (nome, descricao, created_at, updated_at)
  VALUES (p_nome, p_descricao, COALESCE(p_created_at, now()), COALESCE(p_updated_at, now()))
  RETURNING id_ciclo_estudo INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_update(
  p_id_ciclo_estudo uuid,
  p_nome varchar(150),
  p_descricao text
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.ciclos_estudo
  SET nome = p_nome,
      descricao = p_descricao,
      updated_at = now()
  WHERE id_ciclo_estudo = p_id_ciclo_estudo;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_delete(
  p_id_ciclo_estudo uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.ciclos_estudo
  WHERE id_ciclo_estudo = p_id_ciclo_estudo;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
