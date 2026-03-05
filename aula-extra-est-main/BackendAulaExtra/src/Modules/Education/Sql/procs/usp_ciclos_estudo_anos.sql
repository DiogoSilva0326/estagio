DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_anos_select_all01();
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_anos_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_anos_insert(uuid, uuid, timestamp);
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_anos_update(uuid, uuid, uuid);
DROP FUNCTION IF EXISTS public.usp_ciclos_estudo_anos_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_anos_select_all01()
RETURNS SETOF public.ciclos_estudo_anos
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.ciclos_estudo_anos
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_anos_select_details01(
  p_id_ciclo_estudo_ano_escolaridade uuid
)
RETURNS SETOF public.ciclos_estudo_anos
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.ciclos_estudo_anos
  WHERE id_ciclo_estudo_ano_escolaridade = p_id_ciclo_estudo_ano_escolaridade;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_anos_insert(
  p_id_ciclo_estudo uuid,
  p_id_ano_escolaridade uuid,
  p_created_at timestamp
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.ciclos_estudo_anos (id_ciclo_estudo, id_ano_escolaridade, created_at)
  VALUES (p_id_ciclo_estudo, p_id_ano_escolaridade, COALESCE(p_created_at, now()))
  RETURNING id_ciclo_estudo_ano_escolaridade INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_anos_update(
  p_id_ciclo_estudo_ano_escolaridade uuid,
  p_id_ciclo_estudo uuid,
  p_id_ano_escolaridade uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.ciclos_estudo_anos
  SET id_ciclo_estudo = p_id_ciclo_estudo,
      id_ano_escolaridade = p_id_ano_escolaridade
  WHERE id_ciclo_estudo_ano_escolaridade = p_id_ciclo_estudo_ano_escolaridade;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_ciclos_estudo_anos_delete(
  p_id_ciclo_estudo_ano_escolaridade uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.ciclos_estudo_anos
  WHERE id_ciclo_estudo_ano_escolaridade = p_id_ciclo_estudo_ano_escolaridade;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
