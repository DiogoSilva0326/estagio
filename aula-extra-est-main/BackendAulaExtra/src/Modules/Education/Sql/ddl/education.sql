CREATE TABLE IF NOT EXISTS public.areas (
  id_area UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(150) NOT NULL,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS public.disciplinas (
  id_disciplina UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_area UUID NULL,
  nome VARCHAR(150) NOT NULL,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Backwards-compatible upgrade: older databases may have `disciplinas` without `id_area`.
ALTER TABLE public.disciplinas
  ADD COLUMN IF NOT EXISTS id_area UUID;

ALTER TABLE public.disciplinas
  DROP CONSTRAINT IF EXISTS fk_disciplinas_area;

ALTER TABLE public.disciplinas
  ADD CONSTRAINT fk_disciplinas_area
  FOREIGN KEY (id_area) REFERENCES public.areas(id_area)
  ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_disciplinas_id_area ON public.disciplinas(id_area);

CREATE TABLE IF NOT EXISTS anos_escolaridade (
  id_ano_escolaridade UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(100),
  ano_index INTEGER,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ciclos_estudo (
  id_ciclo_estudo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(150) NOT NULL,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ciclos_estudo_anos (
  id_ciclo_estudo_ano_escolaridade UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_ciclo_estudo UUID NOT NULL REFERENCES ciclos_estudo(id_ciclo_estudo),
  id_ano_escolaridade UUID NOT NULL REFERENCES anos_escolaridade(id_ano_escolaridade),
  created_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_ciclo_estudo, id_ano_escolaridade)
);