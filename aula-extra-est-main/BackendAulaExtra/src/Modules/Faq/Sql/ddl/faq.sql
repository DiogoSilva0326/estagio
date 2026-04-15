CREATE TABLE IF NOT EXISTS public.faq_categories (
  id_faq_category UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(150) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  user_id UUID REFERENCES public.users(id_user)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_faq_categories_name
  ON public.faq_categories (LOWER(name));

CREATE TABLE IF NOT EXISTS public.faqs (
  id_faq UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_faq_category UUID,
  question TEXT NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(150),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  user_id UUID REFERENCES public.users(id_user)
);

ALTER TABLE public.faqs
  ADD COLUMN IF NOT EXISTS id_faq_category UUID;

ALTER TABLE public.faqs
  ADD COLUMN IF NOT EXISTS category VARCHAR(150);

INSERT INTO public.faq_categories (name, description, created_at, updated_at, user_id)
SELECT DISTINCT
  seed.name,
  NULL::TEXT,
  now(),
  now(),
  NULL::UUID
FROM (
  VALUES
    ('Para Alunos'),
    ('Para Explicadores'),
    ('Pagamentos e Preços'),
    ('Aulas e Tecnologia'),
    ('Conta e Segurança')
) AS seed(name)
WHERE NOT EXISTS (
  SELECT 1
  FROM public.faq_categories c
  WHERE LOWER(c.name) = LOWER(seed.name)
);

INSERT INTO public.faq_categories (name, description, created_at, updated_at, user_id)
SELECT DISTINCT
  f.category,
  NULL::TEXT,
  COALESCE(f.created_at, now()),
  COALESCE(f.updated_at, now()),
  f.user_id::UUID
FROM public.faqs f
WHERE f.category IS NOT NULL
  AND btrim(f.category) <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM public.faq_categories c
    WHERE LOWER(c.name) = LOWER(f.category)
  );

UPDATE public.faqs f
SET id_faq_category = c.id_faq_category
FROM public.faq_categories c
WHERE (
    f.id_faq_category IS NULL
    OR f.id_faq_category = '00000000-0000-0000-0000-000000000000'::UUID
  )
  AND f.category IS NOT NULL
  AND LOWER(c.name) = LOWER(f.category);

ALTER TABLE public.faqs
  DROP CONSTRAINT IF EXISTS fk_faqs_category;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_faqs_category'
      AND table_name = 'faqs'
      AND table_schema = 'public'
  ) THEN
    ALTER TABLE public.faqs
      ADD CONSTRAINT fk_faqs_category
      FOREIGN KEY (id_faq_category)
      REFERENCES public.faq_categories(id_faq_category)
      ON DELETE RESTRICT;
  END IF;
END $$;

ALTER TABLE public.faqs
  ALTER COLUMN id_faq_category SET NOT NULL;

DROP INDEX IF EXISTS ux_faqs_category_question;
DROP INDEX IF EXISTS ix_faqs_category;

CREATE UNIQUE INDEX IF NOT EXISTS ux_faqs_category_question
  ON public.faqs (id_faq_category, LOWER(question));

CREATE INDEX IF NOT EXISTS ix_faqs_id_faq_category
  ON public.faqs (id_faq_category);

INSERT INTO public.faqs (id_faq_category, question, description, created_at, updated_at, user_id)
SELECT
  c.id_faq_category,
  seed.question,
  seed.description,
  now(),
  now(),
  NULL::UUID
FROM (
  VALUES
    (
      'Para Alunos',
      'Como marco uma aula?',
      'Vai à área de marcação, escolhe a disciplina e o explicador, seleciona um horário disponível e confirma a marcação.'
    ),
    (
      'Para Alunos',
      'Quanto custa uma aula?',
      'O preço varia consoante o explicador e a duração da aula. Vês sempre o valor final antes de confirmares.'
    ),
    (
      'Para Alunos',
      'Posso cancelar ou reagendar uma aula?',
      'Sim. Nas tuas aulas marcadas podes cancelar ou reagendar, desde que respeites a antecedência definida pelo explicador.'
    ),
    (
      'Para Alunos',
      'O que acontece se o explicador não aparecer?',
      'Podes reportar a situação na aula marcada. A equipa analisa o caso e ajuda-te a reagendar ou resolver o pagamento conforme aplicável.'
    ),
    (
      'Para Alunos',
      'Posso ter uma aula experimental antes de me comprometer?',
      'Depende do explicador. Alguns oferecem uma primeira sessão curta/experimental; verifica essa informação no perfil do explicador.'
    ),
    (
      'Para Alunos',
      'Como funciona o sistema de avaliações?',
      'Depois da aula podes avaliar o explicador e deixar feedback. As avaliações ajudam outros alunos a escolherem com confiança.'
    )
) AS seed(category_name, question, description)
JOIN public.faq_categories c
  ON LOWER(c.name) = LOWER(seed.category_name)
WHERE NOT EXISTS (
  SELECT 1
  FROM public.faqs f
  WHERE f.id_faq_category = c.id_faq_category
    AND LOWER(f.question) = LOWER(seed.question)
);

ALTER TABLE public.faqs
  DROP COLUMN IF EXISTS category;
