DROP FUNCTION IF EXISTS public.usp_disciplinas_select_all01();
DROP FUNCTION IF EXISTS public.usp_disciplinas_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_disciplinas_select_by_area01(uuid);
DROP FUNCTION IF EXISTS public.usp_disciplinas_ensure_for_area01(uuid, character varying, text);
DROP FUNCTION IF EXISTS public.usp_disciplinas_insert(character varying, text, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_disciplinas_insert(uuid, character varying, text, timestamp, timestamp);
DROP FUNCTION IF EXISTS public.usp_disciplinas_update(uuid, character varying, text);
DROP FUNCTION IF EXISTS public.usp_disciplinas_update(uuid, uuid, character varying, text);
DROP FUNCTION IF EXISTS public.usp_disciplinas_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_disciplinas_select_all01()
RETURNS SETOF public.disciplinas
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.disciplinas
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_disciplinas_select_details01(
  p_id_disciplina uuid
)
RETURNS SETOF public.disciplinas
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.disciplinas
  WHERE id_disciplina = p_id_disciplina;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_disciplinas_insert(
  p_id_area uuid,
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
  INSERT INTO public.disciplinas (id_area, nome, descricao, created_at, updated_at)
  VALUES (p_id_area, p_nome, p_descricao, COALESCE(p_created_at, now()), COALESCE(p_updated_at, now()))
  RETURNING id_disciplina INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_disciplinas_select_by_area01(
  p_id_area uuid
)
RETURNS SETOF public.disciplinas
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.disciplinas
  WHERE id_area = p_id_area
  ORDER BY nome;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_disciplinas_ensure_for_area01(
  p_id_area uuid,
  p_nome varchar(150),
  p_descricao text
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  SELECT d.id_disciplina
  INTO v_id
  FROM public.disciplinas d
  WHERE d.id_area = p_id_area
    AND lower(trim(d.nome)) = lower(trim(p_nome))
  LIMIT 1;

  IF v_id IS NOT NULL THEN
    RETURN v_id;
  END IF;

  INSERT INTO public.disciplinas (id_area, nome, descricao, created_at, updated_at)
  VALUES (p_id_area, p_nome, p_descricao, now(), now())
  RETURNING id_disciplina INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_disciplinas_update(
  p_id_disciplina uuid,
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
  UPDATE public.disciplinas
  SET id_area = p_id_area,
      nome = p_nome,
      descricao = p_descricao,
      updated_at = now()
  WHERE id_disciplina = p_id_disciplina;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_disciplinas_delete(
  p_id_disciplina uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.disciplinas
  WHERE id_disciplina = p_id_disciplina;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
