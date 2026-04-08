-- seed_dev.sql
--
-- Seed (mock) data for Aula Extra (PostgreSQL).
--
-- Intended usage:
-- - Run AFTER creating schema/procs (e.g., via `BackendAulaExtra/migration/apply_ddl_to_postgres.sh`).
-- - Safe to re-run on a fresh dev DB. Inserts are idempotent via fixed UUIDs + `ON CONFLICT DO NOTHING`.

BEGIN;
SET search_path TO public;

-- ==========================================================
-- 0) Minimal roles table (used by public.user_role + user procs)
-- ==========================================================
CREATE TABLE IF NOT EXISTS public.role (
  id SERIAL PRIMARY KEY,
  description TEXT NOT NULL UNIQUE
);

INSERT INTO public.role (description)
VALUES
  ('Standard'),
  ('admin'),
  ('professor'),
  ('aluno')
ON CONFLICT (description) DO NOTHING;

-- ==========================================================
-- 1) Users (public.users)
-- ==========================================================
-- Fixed IDs to keep FK references stable across re-runs.

-- Tutors (also professors)
INSERT INTO public.users (
  id_user,
  email,
  password,
  first_name,
  last_name,
  username,
  display_name,
  mobile_number,
  inactive
) VALUES
  -- Admin (used by usp_users_register02 as audit/creator)
  ('00000000-0000-0000-0000-000000000001', 'admin@aulaextra.dev', 'PRDZoJBcPPaTb/UO1v4D7w==.I8S5c7ek0vEsvK8zfv0RbNbyIAc50r0rzJDwJR+zFOI=', 'Administrador', 'AulaExtra', 'admin', 'Administrador', '+351910000000', false),

  ('11111111-1111-1111-1111-111111111111', 'joao.silva@aulaextra.dev', 'Fvz22qH4EjuZiVnHaraI5A==.lkkFMCpp1rUh0p8LyO+c3Oni1MCFeMNP/IuW0zXNOmY=', 'João', 'Silva', 'joao.silva', 'João Silva', '+351910000001', false),
  ('22222222-2222-2222-2222-222222222222', 'maria.santos@aulaextra.dev', 'RVBlC83ZwIJzs8uikgayCQ==.n85ErEIliewxavh32vQ6o4lNApt72Qn/BRFNWeLiK+o=', 'Maria', 'Santos', 'maria.santos', 'Maria Santos', '+351910000002', false),
  ('33333333-3333-3333-3333-333333333333', 'pedro.costa@aulaextra.dev', 'RL+EqY9lHg0j2BdgpRtQyg==.zTftRzjOxQQ1be2e2/mm8a7qCguhd3HdZaczyExEFsE=', 'Pedro', 'Costa', 'pedro.costa', 'Pedro Costa', '+351910000003', false),
  ('44444444-4444-4444-4444-444444444444', 'ana.rodrigues@aulaextra.dev', 'xJtwwDtPhpgcbIr+zWm0Fw==.HgE33HPcRh/FqA8DoFP4zi9BipbEvAYBjJF2v9ZOksw=', 'Ana', 'Rodrigues', 'ana.rodrigues', 'Ana Rodrigues', '+351910000004', false),
  ('55555555-5555-5555-5555-555555555555', 'carlos.ferreira@aulaextra.dev', 'jxfg3W+QG951by9I0m1skA==.Aj82H4JER/0zsMTUrbDHS3von0F9QcX+vqNvkfvVO3k=', 'Carlos', 'Ferreira', 'carlos.ferreira', 'Carlos Ferreira', '+351910000005', false),

  -- Student used by the mocked UI (payments/notifications)
  ('66666666-6666-6666-6666-666666666666', 'sofia.oliveira@aulaextra.dev', 'w+imOUYXHhqKICxjIwFpaw==.t7WZUsgYE71EIjuFIo9VdXUhxtJrBJjbbChDfzEjlHM=', 'Sofia', 'Oliveira', 'sofia.oliveira', 'Sofia Oliveira', '+351910000006', false)
ON CONFLICT (id_user) DO NOTHING;

-- Ensure known dev password hash for the fixed seed users (idempotent).
UPDATE public.users SET password = 'PRDZoJBcPPaTb/UO1v4D7w==.I8S5c7ek0vEsvK8zfv0RbNbyIAc50r0rzJDwJR+zFOI=' WHERE id_user = '00000000-0000-0000-0000-000000000001';
UPDATE public.users SET password = 'Fvz22qH4EjuZiVnHaraI5A==.lkkFMCpp1rUh0p8LyO+c3Oni1MCFeMNP/IuW0zXNOmY=' WHERE id_user = '11111111-1111-1111-1111-111111111111';
UPDATE public.users SET password = 'RVBlC83ZwIJzs8uikgayCQ==.n85ErEIliewxavh32vQ6o4lNApt72Qn/BRFNWeLiK+o=' WHERE id_user = '22222222-2222-2222-2222-222222222222';
UPDATE public.users SET password = 'RL+EqY9lHg0j2BdgpRtQyg==.zTftRzjOxQQ1be2e2/mm8a7qCguhd3HdZaczyExEFsE=' WHERE id_user = '33333333-3333-3333-3333-333333333333';
UPDATE public.users SET password = 'xJtwwDtPhpgcbIr+zWm0Fw==.HgE33HPcRh/FqA8DoFP4zi9BipbEvAYBjJF2v9ZOksw=' WHERE id_user = '44444444-4444-4444-4444-444444444444';
UPDATE public.users SET password = 'jxfg3W+QG951by9I0m1skA==.Aj82H4JER/0zsMTUrbDHS3von0F9QcX+vqNvkfvVO3k=' WHERE id_user = '55555555-5555-5555-5555-555555555555';
UPDATE public.users SET password = 'w+imOUYXHhqKICxjIwFpaw==.t7WZUsgYE71EIjuFIo9VdXUhxtJrBJjbbChDfzEjlHM=' WHERE id_user = '66666666-6666-6666-6666-666666666666';

-- Optional user profile rows (some procs rely on this table existing).
INSERT INTO public.user_profile (
  user_id,
  total_spent,
  prefered_language,
  status,
  inactive,
  creation_date,
  last_update,
  last_user_id
) VALUES
  ('00000000-0000-0000-0000-000000000001', 0, 'pt', 'active', false, now(), now(), NULL),
  ('11111111-1111-1111-1111-111111111111', 0, 'pt', 'active', false, now(), now(), NULL),
  ('22222222-2222-2222-2222-222222222222', 0, 'pt', 'active', false, now(), now(), NULL),
  ('33333333-3333-3333-3333-333333333333', 0, 'pt', 'active', false, now(), now(), NULL),
  ('44444444-4444-4444-4444-444444444444', 0, 'pt', 'active', false, now(), now(), NULL),
  ('55555555-5555-5555-5555-555555555555', 0, 'pt', 'active', false, now(), now(), NULL),
  ('66666666-6666-6666-6666-666666666666', 138, 'pt', 'active', false, now(), now(), NULL)
ON CONFLICT (user_id) DO NOTHING;

-- Assign roles to seeded users.
INSERT INTO public.user_role (role_id, user_id)
SELECT r.id, m.user_id
FROM (
  VALUES
    ('admin',    '00000000-0000-0000-0000-000000000001'::uuid),
    ('professor','11111111-1111-1111-1111-111111111111'::uuid),
    ('professor','22222222-2222-2222-2222-222222222222'::uuid),
    ('professor','33333333-3333-3333-3333-333333333333'::uuid),
    ('professor','44444444-4444-4444-4444-444444444444'::uuid),
    ('professor','55555555-5555-5555-5555-555555555555'::uuid),
    ('aluno',    '66666666-6666-6666-6666-666666666666'::uuid)
) AS m(role_description, user_id)
JOIN public.role r ON r.description = m.role_description
ON CONFLICT (role_id, user_id) DO NOTHING;

-- ==========================================================
-- 2) Professors
-- ==========================================================
INSERT INTO professors (
  id_professor,
  id_user,
  current_school,
  years_experience,
  photo,
  biography,
  vat,
  iban,
  is_verified_iban,
  is_active,
  is_verified,
  created_at,
  updated_at
) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 'Escola Secundária Central', 6, 'https://i.pravatar.cc/200?img=12', 'Explicador de Matemática com foco em exames.', '123456789', 'PT50000000000000000000000', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '22222222-2222-2222-2222-222222222222', 'Escola Secundária Central', 4, 'https://i.pravatar.cc/200?img=47', 'Explicadora de Física/Química.', '223456789', 'PT50000000000000000000001', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', '33333333-3333-3333-3333-333333333333', 'Colégio do Atlântico', 5, 'https://i.pravatar.cc/200?img=32', 'Inglês para todos os níveis.', '323456789', 'PT50000000000000000000002', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', '44444444-4444-4444-4444-444444444444', 'Colégio do Atlântico', 3, 'https://i.pravatar.cc/200?img=5', 'Matemática (7º ao 12º).', '423456789', 'PT50000000000000000000003', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', '55555555-5555-5555-5555-555555555555', 'Escola Secundária do Norte', 7, 'https://i.pravatar.cc/200?img=58', 'Física aplicada e preparação para testes.', '523456789', 'PT50000000000000000000004', true, true, true, now(), now())
ON CONFLICT (id_professor) DO NOTHING;

UPDATE professors
SET presentation_video_url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
WHERE id_professor = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1';

-- Seed professor rooms using the normalized naming expected by the live classroom flow.
INSERT INTO public.professor_rooms (
  professor_id,
  professor_name,
  room_name,
  description,
  is_active
)
SELECT
  u.id_user,
  COALESCE(NULLIF(u.display_name, ''), CONCAT_WS(' ', u.first_name, u.last_name), u.username),
  CONCAT('professor_', LOWER(u.username)),
  CONCAT('Sala do professor ', COALESCE(NULLIF(u.display_name, ''), CONCAT_WS(' ', u.first_name, u.last_name), u.username)),
  true
FROM public.professors p
JOIN public.users u ON u.id_user = p.id_user
ON CONFLICT (professor_id) DO UPDATE
SET professor_name = EXCLUDED.professor_name,
    room_name = EXCLUDED.room_name,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active;

-- ==========================================================
-- 3) Education taxonomy (disciplines + levels)
-- ==========================================================
INSERT INTO public.areas (id_area, nome, descricao)
VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Matemática', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Ciências', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Línguas', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0004', 'Humanidades', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0005', 'Tecnologia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0006', 'Artes', NULL)
ON CONFLICT (id_area) DO NOTHING;

INSERT INTO disciplinas (id_disciplina, id_area, nome, descricao)
VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Matemática', 'Álgebra, geometria, trigonometria.'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Física', 'Mecânica, eletricidade e ondas.'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Química', 'Estequiometria e reações químicas.'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Inglês', 'Gramática, conversação e escrita.')
ON CONFLICT (id_disciplina) DO NOTHING;

-- Extra disciplines used by the student "Minhas Áreas" UI (dialog categories)
INSERT INTO disciplinas (id_disciplina, id_area, nome, descricao)
VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb101', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Álgebra', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb102', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Geometria', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb103', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Trigonometria', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb104', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Cálculo', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb105', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Estatística', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb106', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Biologia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb107', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Geologia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb108', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Português', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb109', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Espanhol', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb110', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Francês', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Alemão', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb112', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0004', 'História', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb113', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0004', 'Geografia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb114', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0004', 'Filosofia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb115', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0004', 'Sociologia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb116', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0004', 'Economia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb117', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0006', 'Artes Visuais', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb118', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0006', 'Música', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb119', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0006', 'Teatro', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb120', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0006', 'Dança', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb121', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0006', 'Design', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb122', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0005', 'Programação', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb123', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0005', 'Robótica', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb124', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0005', 'Informática', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb125', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0005', 'Multimédia', NULL),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb126', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0005', 'Redes', NULL)
ON CONFLICT (id_disciplina) DO NOTHING;

-- Student discipline selections ("Minhas Áreas")
INSERT INTO public.user_disciplina (user_id, id_disciplina)
VALUES
  ('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001'),
  ('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002'),
  ('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004')
ON CONFLICT (user_id, id_disciplina) DO NOTHING;

INSERT INTO public.languages (id_language, nome)
VALUES
  ('abababab-abab-abab-abab-abababab0001', 'Português'),
  ('abababab-abab-abab-abab-abababab0002', 'Inglês'),
  ('abababab-abab-abab-abab-abababab0003', 'Espanhol'),
  ('abababab-abab-abab-abab-abababab0004', 'Francês')
ON CONFLICT (id_language) DO NOTHING;

INSERT INTO public.professor_languages (id_professor, id_language, proficiency_level)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'abababab-abab-abab-abab-abababab0001', 'Nativo'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'abababab-abab-abab-abab-abababab0002', 'Avançado'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'abababab-abab-abab-abab-abababab0001', 'Nativo'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'abababab-abab-abab-abab-abababab0002', 'Nativo'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'abababab-abab-abab-abab-abababab0003', 'Intermédio')
ON CONFLICT (id_professor, id_language) DO NOTHING;

INSERT INTO anos_escolaridade (id_ano_escolaridade, nome, ano_index)
VALUES
  ('cccccccc-cccc-cccc-cccc-ccccccccc010', '7º Ano', 7),
  ('cccccccc-cccc-cccc-cccc-ccccccccc011', '8º Ano', 8),
  ('cccccccc-cccc-cccc-cccc-ccccccccc012', '9º Ano', 9),
  ('cccccccc-cccc-cccc-cccc-ccccccccc100', '10º Ano', 10),
  ('cccccccc-cccc-cccc-cccc-ccccccccc110', '11º Ano', 11),
  ('cccccccc-cccc-cccc-cccc-ccccccccc120', '12º Ano', 12)
ON CONFLICT (id_ano_escolaridade) DO NOTHING;

INSERT INTO ciclos_estudo (id_ciclo_estudo, nome, descricao)
VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddd001', '3º Ciclo', '7º ao 9º ano'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd002', 'Secundário', '10º ao 12º ano')
ON CONFLICT (id_ciclo_estudo) DO NOTHING;

INSERT INTO ciclos_estudo_anos (id_ciclo_estudo_ano_escolaridade, id_ciclo_estudo, id_ano_escolaridade)
VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddd101', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'cccccccc-cccc-cccc-cccc-ccccccccc010'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd102', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'cccccccc-cccc-cccc-cccc-ccccccccc011'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd103', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'cccccccc-cccc-cccc-cccc-ccccccccc012'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd201', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'cccccccc-cccc-cccc-cccc-ccccccccc100'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd202', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'cccccccc-cccc-cccc-cccc-ccccccccc110'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd203', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'cccccccc-cccc-cccc-cccc-ccccccccc120')
ON CONFLICT (id_ciclo_estudo_ano_escolaridade) DO NOTHING;

-- ==========================================================
-- 4) Courses + pricing (matches the mocked UI subjects)
-- ==========================================================
INSERT INTO tutoring_types (id_tutoring_type, name, description)
VALUES
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'Individual', 'Aula 1:1'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeee0002', 'Grupo', 'Aula em grupo')
ON CONFLICT (id_tutoring_type) DO NOTHING;

INSERT INTO pricing_models (id_pricing_model, name, description)
VALUES
  ('ffffffff-ffff-ffff-ffff-ffffffff0001', 'Preço por sessão', 'Preço fixo por sessão'),
  ('ffffffff-ffff-ffff-ffff-ffffffff0002', 'Preço por aluno', 'Preço por aluno')
ON CONFLICT (id_pricing_model) DO NOTHING;

-- Each tutor has a single course in their mocked discipline.
INSERT INTO courses (
  id_course,
  id_professor,
  id_pricing_model,
  id_tutoring_type,
  id_disciplina,
  id_ano_escolaridade,
  id_ciclo_estudo,
  name,
  description,
  level_of_education,
  num_max_students,
  num_min_students,
  created_at,
  updated_at
) VALUES
  ('10101010-1010-1010-1010-101010101001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'cccccccc-cccc-cccc-cccc-ccccccccc120', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Matemática - Preparação Exames', 'Aulas focadas em exercícios e exame.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'cccccccc-cccc-cccc-cccc-ccccccccc110', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Física - Sessões Práticas', 'Resolução guiada e preparação para testes.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'cccccccc-cccc-cccc-cccc-ccccccccc100', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Inglês - Conversação', 'Aulas focadas em speaking/listening.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'cccccccc-cccc-cccc-cccc-ccccccccc012', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'Matemática - 3º Ciclo', 'Bases e resolução de fichas.', '3º Ciclo', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'cccccccc-cccc-cccc-cccc-ccccccccc110', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Física - Preparação Testes', 'Preparação para fichas e exames.', 'Secundário', 1, 1, now(), now())
ON CONFLICT (id_course) DO NOTHING;

INSERT INTO course_prices (id_course_price, id_course, session_price, price_per_student, number_students, active)
VALUES
  ('12121212-1212-1212-1212-121212121001', '10101010-1010-1010-1010-101010101001', 25.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121002', '10101010-1010-1010-1010-101010101002', 30.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121003', '10101010-1010-1010-1010-101010101003', 28.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121004', '10101010-1010-1010-1010-101010101004', 25.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121005', '10101010-1010-1010-1010-101010101005', 30.00, NULL, 1, true)
ON CONFLICT (id_course_price) DO NOTHING;

-- ==========================================================
-- 5) Lessons + enrollments + reservations (calendar + payments)
-- ==========================================================
INSERT INTO lessons (
  id_lesson,
  id_course,
  id_professor,
  title,
  students,
  duration_minutes,
  scheduled_start,
  scheduled_end,
  uses_custom_blocks,
  max_students,
  base_price
) VALUES
  ('20202020-2020-2020-2020-202020202001', '10101010-1010-1010-1010-101010101001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Aula de Matemática', 1, 60, '2026-01-27 14:30:00', '2026-01-27 15:30:00', false, 1, 25.00),
  ('20202020-2020-2020-2020-202020202002', '10101010-1010-1010-1010-101010101002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Aula de Física', 1, 60, '2026-01-27 16:00:00', '2026-01-27 17:00:00', false, 1, 30.00),
  ('20202020-2020-2020-2020-202020202003', '10101010-1010-1010-1010-101010101003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Aula de Inglês', 1, 60, '2026-01-28 10:00:00', '2026-01-28 11:00:00', false, 1, 28.00),
  ('20202020-2020-2020-2020-202020202004', '10101010-1010-1010-1010-101010101004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Aula de Matemática (3º Ciclo)', 1, 60, '2026-01-28 15:00:00', '2026-01-28 16:00:00', false, 1, 25.00),
  ('20202020-2020-2020-2020-202020202005', '10101010-1010-1010-1010-101010101005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Aula de Física (Extra)', 1, 60, '2026-01-28 16:30:00', '2026-01-28 17:30:00', false, 1, 30.00),
  ('20202020-2020-2020-2020-202020202006', '10101010-1010-1010-1010-101010101003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Aula de Inglês (Prática)', 1, 60, '2026-01-29 10:00:00', '2026-01-29 11:00:00', false, 1, 28.00),
  ('20202020-2020-2020-2020-202020202007', '10101010-1010-1010-1010-101010101001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Aula de Matemática (Revisão)', 1, 60, '2026-01-29 14:00:00', '2026-01-29 15:00:00', false, 1, 25.00),
  ('20202020-2020-2020-2020-202020202008', '10101010-1010-1010-1010-101010101002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Aula de Física (Exercícios)', 1, 60, '2026-01-29 18:00:00', '2026-01-29 19:00:00', false, 1, 30.00),
  ('20202020-2020-2020-2020-202020202009', '10101010-1010-1010-1010-101010101004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Aula de Matemática (Dúvidas)', 1, 60, '2026-01-30 09:00:00', '2026-01-30 10:00:00', false, 1, 25.00),
  ('20202020-2020-2020-2020-202020202010', '10101010-1010-1010-1010-101010101005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Aula de Física (Laboratório)', 1, 60, '2026-01-31 11:00:00', '2026-01-31 12:00:00', false, 1, 30.00),
  ('20202020-2020-2020-2020-202020202011', '10101010-1010-1010-1010-101010101003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Aula de Inglês (Speaking)', 1, 60, '2026-02-01 16:00:00', '2026-02-01 17:00:00', false, 1, 28.00),
  ('20202020-2020-2020-2020-202020202012', '10101010-1010-1010-1010-101010101001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Aula de Matemática (Extra)', 1, 60, '2026-02-02 18:00:00', '2026-02-02 19:00:00', false, 1, 25.00),
  ('20202020-2020-2020-2020-202020202013', '10101010-1010-1010-1010-101010101004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Aula de Matemática (Noite)', 1, 60, '2026-02-03 01:00:00', '2026-02-03 02:00:00', false, 1, 25.00),
  ('20202020-2020-2020-2020-202020202014', '10101010-1010-1010-1010-101010101005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Aula de Física (Madrugada)', 1, 60, '2026-02-06 02:00:00', '2026-02-06 03:00:00', false, 1, 30.00)
ON CONFLICT (id_lesson) DO NOTHING;

INSERT INTO lesson_prices (id_lesson_price, id_lesson, session_price, price_per_student)
VALUES
  ('21212121-2121-2121-2121-212121212001', '20202020-2020-2020-2020-202020202001', 25.00, NULL),
  ('21212121-2121-2121-2121-212121212002', '20202020-2020-2020-2020-202020202002', 30.00, NULL),
  ('21212121-2121-2121-2121-212121212003', '20202020-2020-2020-2020-202020202003', 28.00, NULL),
  ('21212121-2121-2121-2121-212121212004', '20202020-2020-2020-2020-202020202004', 25.00, NULL),
  ('21212121-2121-2121-2121-212121212005', '20202020-2020-2020-2020-202020202005', 30.00, NULL),
  ('21212121-2121-2121-2121-212121212006', '20202020-2020-2020-2020-202020202006', 28.00, NULL),
  ('21212121-2121-2121-2121-212121212007', '20202020-2020-2020-2020-202020202007', 25.00, NULL),
  ('21212121-2121-2121-2121-212121212008', '20202020-2020-2020-2020-202020202008', 30.00, NULL),
  ('21212121-2121-2121-2121-212121212009', '20202020-2020-2020-2020-202020202009', 25.00, NULL),
  ('21212121-2121-2121-2121-212121212010', '20202020-2020-2020-2020-202020202010', 30.00, NULL),
  ('21212121-2121-2121-2121-212121212011', '20202020-2020-2020-2020-202020202011', 28.00, NULL),
  ('21212121-2121-2121-2121-212121212012', '20202020-2020-2020-2020-202020202012', 25.00, NULL),
  ('21212121-2121-2121-2121-212121212013', '20202020-2020-2020-2020-202020202013', 25.00, NULL),
  ('21212121-2121-2121-2121-212121212014', '20202020-2020-2020-2020-202020202014', 30.00, NULL)
ON CONFLICT (id_lesson_price) DO NOTHING;

-- Student enrollments (Sofia enrolled in all lessons).
INSERT INTO enrollments (id_enrollment, id_lesson, id_user, status, price_paid)
VALUES
  ('30303030-3030-3030-3030-303030303001', '20202020-2020-2020-2020-202020202001', '66666666-6666-6666-6666-666666666666', 'active', 25.00),
  ('30303030-3030-3030-3030-303030303002', '20202020-2020-2020-2020-202020202002', '66666666-6666-6666-6666-666666666666', 'active', 30.00),
  ('30303030-3030-3030-3030-303030303003', '20202020-2020-2020-2020-202020202003', '66666666-6666-6666-6666-666666666666', 'active', 28.00),
  ('30303030-3030-3030-3030-303030303004', '20202020-2020-2020-2020-202020202004', '66666666-6666-6666-6666-666666666666', 'active', 25.00),
  ('30303030-3030-3030-3030-303030303005', '20202020-2020-2020-2020-202020202005', '66666666-6666-6666-6666-666666666666', 'active', 30.00),
  ('30303030-3030-3030-3030-303030303006', '20202020-2020-2020-2020-202020202006', '66666666-6666-6666-6666-666666666666', 'active', 28.00),
  ('30303030-3030-3030-3030-303030303007', '20202020-2020-2020-2020-202020202007', '66666666-6666-6666-6666-666666666666', 'active', 25.00),
  ('30303030-3030-3030-3030-303030303008', '20202020-2020-2020-2020-202020202008', '66666666-6666-6666-6666-666666666666', 'active', 30.00),
  ('30303030-3030-3030-3030-303030303009', '20202020-2020-2020-2020-202020202009', '66666666-6666-6666-6666-666666666666', 'active', 25.00),
  ('30303030-3030-3030-3030-303030303010', '20202020-2020-2020-2020-202020202010', '66666666-6666-6666-6666-666666666666', 'active', 30.00),
  ('30303030-3030-3030-3030-303030303011', '20202020-2020-2020-2020-202020202011', '66666666-6666-6666-6666-666666666666', 'active', 28.00),
  ('30303030-3030-3030-3030-303030303012', '20202020-2020-2020-2020-202020202012', '66666666-6666-6666-6666-666666666666', 'active', 25.00),
  ('30303030-3030-3030-3030-303030303013', '20202020-2020-2020-2020-202020202013', '66666666-6666-6666-6666-666666666666', 'active', 25.00),
  ('30303030-3030-3030-3030-303030303014', '20202020-2020-2020-2020-202020202014', '66666666-6666-6666-6666-666666666666', 'active', 30.00)
ON CONFLICT (id_enrollment) DO NOTHING;

-- Lesson feedback (ratings) shown in "Meus Explicadores".
-- Intentionally omit feedback for one lesson to test the "—" state.
INSERT INTO lesson_feedback (
  id_lesson_feedback,
  id_lesson,
  id_user,
  is_valid,
  rating,
  comments,
  created_at
) VALUES
  ('90909090-9090-9090-9090-909090909001', '20202020-2020-2020-2020-202020202001', '66666666-6666-6666-6666-666666666666', true, 5, 'Muito boa aula.', '2026-01-27 16:10:00'),
  ('90909090-9090-9090-9090-909090909002', '20202020-2020-2020-2020-202020202002', '66666666-6666-6666-6666-666666666666', true, 4, 'Explicação clara.', '2026-01-27 18:10:00'),
  ('90909090-9090-9090-9090-909090909003', '20202020-2020-2020-2020-202020202003', '66666666-6666-6666-6666-666666666666', true, 5, 'Excelente!', '2026-01-28 12:00:00'),
  ('90909090-9090-9090-9090-909090909004', '20202020-2020-2020-2020-202020202004', '66666666-6666-6666-6666-666666666666', true, 4, 'Gostei bastante.', '2026-01-28 17:30:00'),
  ('90909090-9090-9090-9090-909090909005', '20202020-2020-2020-2020-202020202013', '66666666-6666-6666-6666-666666666666', true, 5, 'Ótima para testar horário noturno.', '2026-02-03 02:15:00'),
  ('90909090-9090-9090-9090-909090909006', '20202020-2020-2020-2020-202020202014', '66666666-6666-6666-6666-666666666666', true, 4, 'Bom para validar a madrugada.', '2026-02-06 03:10:00')
ON CONFLICT (id_lesson_feedback) DO NOTHING;

-- Optional professor feedback (not used by the current endpoint, but useful for other screens).
INSERT INTO professor_feedback (
  id_professor_feedback,
  id_professor,
  id_user,
  is_valid,
  rating,
  comments,
  created_at
) VALUES
  ('91919191-9191-9191-9191-919191919001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '66666666-6666-6666-6666-666666666666', true, 5, 'Recomendo!', '2026-01-28 18:00:00'),
  ('91919191-9191-9191-9191-919191919002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '66666666-6666-6666-6666-666666666666', true, 4, NULL, '2026-01-28 18:05:00')
ON CONFLICT (id_professor_feedback) DO NOTHING;

-- Reservations are the bookable/payment unit.
INSERT INTO reservations (
  id_reservation,
  id_user,
  id_lesson,
  min_students_at_booking,
  start_time,
  end_time,
  status,
  created_at
) VALUES
  ('40404040-4040-4040-4040-404040404001', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202001', 1, '2026-01-20 14:30:00', '2026-01-20 15:30:00', 'paid', '2026-01-20 13:00:00'),
  ('40404040-4040-4040-4040-404040404002', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202002', 1, '2026-01-22 16:00:00', '2026-01-22 17:00:00', 'paid', '2026-01-22 12:00:00'),
  ('40404040-4040-4040-4040-404040404003', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202003', 1, '2026-01-23 10:00:00', '2026-01-23 11:00:00', 'paid', '2026-01-23 09:00:00'),
  ('40404040-4040-4040-4040-404040404004', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202004', 1, '2026-01-24 15:00:00', '2026-01-24 16:00:00', 'paid', '2026-01-24 13:00:00'),
  ('40404040-4040-4040-4040-404040404005', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202005', 1, '2026-01-28 10:00:00', '2026-01-28 11:00:00', 'pending', '2026-01-28 08:00:00'),
  ('40404040-4040-4040-4040-404040404006', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202006', 1, '2026-01-29 10:00:00', '2026-01-29 11:00:00', 'paid', '2026-01-29 08:00:00'),
  ('40404040-4040-4040-4040-404040404007', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202007', 1, '2026-01-29 14:00:00', '2026-01-29 15:00:00', 'pending', '2026-01-29 12:00:00'),
  ('40404040-4040-4040-4040-404040404008', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202008', 1, '2026-01-29 18:00:00', '2026-01-29 19:00:00', 'paid', '2026-01-29 16:00:00'),
  ('40404040-4040-4040-4040-404040404009', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202009', 1, '2026-01-30 09:00:00', '2026-01-30 10:00:00', 'paid', '2026-01-30 07:00:00'),
  ('40404040-4040-4040-4040-404040404010', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202010', 1, '2026-01-31 11:00:00', '2026-01-31 12:00:00', 'pending', '2026-01-31 09:00:00'),
  ('40404040-4040-4040-4040-404040404011', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202011', 1, '2026-02-01 16:00:00', '2026-02-01 17:00:00', 'paid', '2026-02-01 14:00:00'),
  ('40404040-4040-4040-4040-404040404012', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202012', 1, '2026-02-02 18:00:00', '2026-02-02 19:00:00', 'pending', '2026-02-02 16:00:00'),
  ('40404040-4040-4040-4040-404040404013', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202013', 1, '2026-02-03 01:00:00', '2026-02-03 02:00:00', 'paid', '2026-02-02 23:00:00'),
  ('40404040-4040-4040-4040-404040404014', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202014', 1, '2026-02-06 02:00:00', '2026-02-06 03:00:00', 'pending', '2026-02-06 00:00:00')
ON CONFLICT (id_reservation) DO NOTHING;

-- Keep the seeded calendar useful by always placing lessons/reservations in the
-- current/next week. Pedro Costa's lesson with Sofia Oliveira is pinned to the
-- current moment so entering a class can be tested immediately after applying
-- the seed.
-- IDs stay stable; timestamps are updated on each seed run.
WITH base AS (
  SELECT
    date_trunc('week', now())::timestamp AS week_start,
    date_trunc('minute', now())::timestamp AS live_start
)
UPDATE lessons l
SET
  scheduled_start = v.scheduled_start,
  scheduled_end = v.scheduled_end
FROM (
  SELECT '20202020-2020-2020-2020-202020202001'::uuid AS id_lesson, (base.week_start + interval '0 day 14 hour 30 min') AS scheduled_start, (base.week_start + interval '0 day 15 hour 30 min') AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202002'::uuid AS id_lesson, (base.week_start + interval '2 day 16 hour')       AS scheduled_start, (base.week_start + interval '2 day 17 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202003'::uuid AS id_lesson, base.live_start AS scheduled_start, (base.live_start + interval '1 hour') AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202004'::uuid AS id_lesson, (base.week_start + interval '4 day 15 hour')       AS scheduled_start, (base.week_start + interval '4 day 16 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202005'::uuid AS id_lesson, (base.week_start + interval '8 day 10 hour')       AS scheduled_start, (base.week_start + interval '8 day 11 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202006'::uuid AS id_lesson, (base.week_start + interval '9 day 10 hour')       AS scheduled_start, (base.week_start + interval '9 day 11 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202007'::uuid AS id_lesson, (base.week_start + interval '3 day 14 hour')       AS scheduled_start, (base.week_start + interval '3 day 15 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202008'::uuid AS id_lesson, (base.week_start + interval '3 day 18 hour')       AS scheduled_start, (base.week_start + interval '3 day 19 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202009'::uuid AS id_lesson, (base.week_start + interval '4 day 9 hour')        AS scheduled_start, (base.week_start + interval '4 day 10 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202010'::uuid AS id_lesson, (base.week_start + interval '5 day 11 hour')       AS scheduled_start, (base.week_start + interval '5 day 12 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202011'::uuid AS id_lesson, (base.week_start + interval '6 day 16 hour')       AS scheduled_start, (base.week_start + interval '6 day 17 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202012'::uuid AS id_lesson, (base.week_start + interval '7 day 18 hour')       AS scheduled_start, (base.week_start + interval '7 day 19 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202013'::uuid AS id_lesson, (base.week_start + interval '1 day 1 hour')        AS scheduled_start, (base.week_start + interval '1 day 2 hour')        AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202014'::uuid AS id_lesson, (base.week_start + interval '4 day 2 hour')        AS scheduled_start, (base.week_start + interval '4 day 3 hour')        AS scheduled_end FROM base
) v
WHERE l.id_lesson = v.id_lesson;

-- Align reservations and seed-created timestamps with the lesson schedule.
UPDATE reservations r
SET
  start_time = l.scheduled_start,
  end_time = l.scheduled_end,
  created_at = l.scheduled_start - interval '2 hours'
FROM lessons l
WHERE r.id_lesson = l.id_lesson
  AND r.id_reservation IN (
    '40404040-4040-4040-4040-404040404001'::uuid,
    '40404040-4040-4040-4040-404040404002'::uuid,
    '40404040-4040-4040-4040-404040404003'::uuid,
    '40404040-4040-4040-4040-404040404004'::uuid,
    '40404040-4040-4040-4040-404040404005'::uuid,
    '40404040-4040-4040-4040-404040404006'::uuid,
    '40404040-4040-4040-4040-404040404007'::uuid,
    '40404040-4040-4040-4040-404040404008'::uuid,
    '40404040-4040-4040-4040-404040404009'::uuid,
    '40404040-4040-4040-4040-404040404010'::uuid,
    '40404040-4040-4040-4040-404040404011'::uuid,
    '40404040-4040-4040-4040-404040404012'::uuid,
    '40404040-4040-4040-4040-404040404013'::uuid,
    '40404040-4040-4040-4040-404040404014'::uuid
  );

-- ==========================================================
-- 6) Wallet + transactions + reservation payments
-- ==========================================================
-- One wallet per user.
INSERT INTO wallets (id_wallet, owner_type, owner_user_id, balance, hold_amount, currency)
VALUES
  ('50505050-5050-5050-5050-505050505001', 'user', '66666666-6666-6666-6666-666666666666', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505002', 'user', '11111111-1111-1111-1111-111111111111', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505003', 'user', '22222222-2222-2222-2222-222222222222', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505004', 'user', '33333333-3333-3333-3333-333333333333', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505005', 'user', '44444444-4444-4444-4444-444444444444', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505006', 'user', '55555555-5555-5555-5555-555555555555', 0.00, 0.00, 'EUR')
ON CONFLICT (id_wallet) DO NOTHING;

-- Transaction entries representing the mocked payments list.
INSERT INTO transactions (id_transaction, wallet_id, transaction_type, amount, balance_before, balance_after, status, created_at)
VALUES
  ('60606060-6060-6060-6060-606060606001', '50505050-5050-5050-5050-505050505001', 'debit', 25.00, 138.00, 113.00, 'succeeded', '2026-01-20 13:01:00'),
  ('60606060-6060-6060-6060-606060606002', '50505050-5050-5050-5050-505050505001', 'debit', 30.00, 113.00, 83.00, 'succeeded', '2026-01-22 12:01:00'),
  ('60606060-6060-6060-6060-606060606003', '50505050-5050-5050-5050-505050505001', 'debit', 28.00, 83.00, 55.00, 'succeeded', '2026-01-23 09:01:00'),
  ('60606060-6060-6060-6060-606060606004', '50505050-5050-5050-5050-505050505001', 'debit', 25.00, 55.00, 30.00, 'succeeded', '2026-01-24 13:01:00'),
  ('60606060-6060-6060-6060-606060606005', '50505050-5050-5050-5050-505050505001', 'debit', 30.00, 30.00, 0.00, 'pending', '2026-01-28 08:01:00'),
  ('60606060-6060-6060-6060-606060606006', '50505050-5050-5050-5050-505050505001', 'debit', 25.00, 0.00, 0.00, 'succeeded', '2026-02-02 23:01:00'),
  ('60606060-6060-6060-6060-606060606007', '50505050-5050-5050-5050-505050505001', 'debit', 30.00, 0.00, 0.00, 'pending', '2026-02-06 00:01:00'),
  ('60606060-6060-6060-6060-606060606008', '50505050-5050-5050-5050-505050505001', 'debit', 28.00, 0.00, 0.00, 'succeeded', '2026-01-29 08:01:00'),
  ('60606060-6060-6060-6060-606060606009', '50505050-5050-5050-5050-505050505001', 'debit', 28.00, 0.00, 0.00, 'succeeded', '2026-02-01 14:01:00')
ON CONFLICT (id_transaction) DO NOTHING;

-- A default commission rule (platform fee example).
INSERT INTO commission_rules (id_commission_rule, id_professor, percent, fixed_fee, applies_to, effective_from)
VALUES
  ('70707070-7070-7070-7070-707070707001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00'),
  ('70707070-7070-7070-7070-707070707002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00'),
  ('70707070-7070-7070-7070-707070707003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00'),
  ('70707070-7070-7070-7070-707070707004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00'),
  ('70707070-7070-7070-7070-707070707005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00')
ON CONFLICT (id_commission_rule) DO NOTHING;

INSERT INTO reservation_payments (
  id_reservation_payment,
  reservation_id,
  payer_wallet_id,
  transaction_id,
  commission_rule_id,
  amount,
  status,
  created_at
) VALUES
  ('80808080-8080-8080-8080-808080808001', '40404040-4040-4040-4040-404040404001', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606001', '70707070-7070-7070-7070-707070707001', 25.00, 'paid', '2026-01-20 13:02:00'),
  ('80808080-8080-8080-8080-808080808002', '40404040-4040-4040-4040-404040404002', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606002', '70707070-7070-7070-7070-707070707002', 30.00, 'paid', '2026-01-22 12:02:00'),
  ('80808080-8080-8080-8080-808080808003', '40404040-4040-4040-4040-404040404003', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606003', '70707070-7070-7070-7070-707070707003', 28.00, 'paid', '2026-01-23 09:02:00'),
  ('80808080-8080-8080-8080-808080808004', '40404040-4040-4040-4040-404040404004', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606004', '70707070-7070-7070-7070-707070707004', 25.00, 'paid', '2026-01-24 13:02:00'),
  ('80808080-8080-8080-8080-808080808005', '40404040-4040-4040-4040-404040404005', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606005', '70707070-7070-7070-7070-707070707005', 30.00, 'pending', '2026-01-28 08:02:00'),
  ('80808080-8080-8080-8080-808080808006', '40404040-4040-4040-4040-404040404013', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606006', '70707070-7070-7070-7070-707070707004', 25.00, 'paid', '2026-02-02 23:02:00'),
  ('80808080-8080-8080-8080-808080808007', '40404040-4040-4040-4040-404040404014', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606007', '70707070-7070-7070-7070-707070707005', 30.00, 'pending', '2026-02-06 00:02:00'),
  ('80808080-8080-8080-8080-808080808008', '40404040-4040-4040-4040-404040404006', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606008', '70707070-7070-7070-7070-707070707003', 28.00, 'paid', '2026-01-29 08:02:00'),
  ('80808080-8080-8080-8080-808080808009', '40404040-4040-4040-4040-404040404011', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606009', '70707070-7070-7070-7070-707070707003', 28.00, 'paid', '2026-02-01 14:02:00')
ON CONFLICT (id_reservation_payment) DO NOTHING;

-- ==========================================================
-- 7) Notifications + messages (from mocked UI)
-- ==========================================================
INSERT INTO notifications (id_notification, id_user, type, message, was_read, created_at, updated_at)
VALUES
  ('90909090-9090-9090-9090-909090909001', '66666666-6666-6666-6666-666666666666', 'aula', 'Sua aula com Pedro Costa começa agora', false, now(), now()),
  ('90909090-9090-9090-9090-909090909002', '66666666-6666-6666-6666-666666666666', 'tarefa', 'Você recebeu uma nova tarefa: Exercícios de Álgebra', false, now() - interval '15 minutes', now() - interval '15 minutes'),
  ('90909090-9090-9090-9090-909090909003', '66666666-6666-6666-6666-666666666666', 'mensagem', 'Maria Santos enviou uma mensagem', false, now() - interval '1 hour', now() - interval '1 hour'),
  ('90909090-9090-9090-9090-909090909004', '66666666-6666-6666-6666-666666666666', 'avaliacao', 'Que tal avaliar a aula com Pedro Costa?', true, now() - interval '2 hours', now() - interval '2 hours'),
  ('90909090-9090-9090-9090-909090909005', '66666666-6666-6666-6666-666666666666', 'aula', 'Sua aula de Física foi confirmada para amanhã às 10:00', true, now() - interval '3 hours', now() - interval '3 hours'),
  ('90909090-9090-9090-9090-909090909006', '66666666-6666-6666-6666-666666666666', 'pagamento', 'Seu pagamento de 25€ foi processado com sucesso', true, now() - interval '1 day', now() - interval '1 day'),
  ('91919191-9191-9191-9191-919191919001', '11111111-1111-1111-1111-111111111111', 'aula', 'Nova aula marcada com Sofia Oliveira para amanhã às 18:00', false, now() - interval '5 minutes', now() - interval '5 minutes'),
  ('91919191-9191-9191-9191-919191919002', '11111111-1111-1111-1111-111111111111', 'mensagem', 'Sofia Oliveira enviou uma nova mensagem sobre a próxima explicação', false, now() - interval '35 minutes', now() - interval '35 minutes'),
  ('91919191-9191-9191-9191-919191919003', '11111111-1111-1111-1111-111111111111', 'tarefa', 'Foi adicionada uma nova tarefa de preparação para a aula de Matemática', false, now() - interval '2 hours', now() - interval '2 hours'),
  ('92929292-9292-9292-9292-929292929001', '33333333-3333-3333-3333-333333333333', 'aula', 'Nova aula de Inglês marcada para hoje às 19:30', false, now() - interval '10 minutes', now() - interval '10 minutes'),
  ('92929292-9292-9292-9292-929292929002', '33333333-3333-3333-3333-333333333333', 'mensagem', 'Sofia Oliveira enviou uma mensagem com dúvidas sobre os exercícios', false, now() - interval '50 minutes', now() - interval '50 minutes'),
  ('92929292-9292-9292-9292-929292929003', '33333333-3333-3333-3333-333333333333', 'tarefa', 'Foi criada uma nova tarefa de vocabulário para revisão antes da aula', false, now() - interval '3 hours', now() - interval '3 hours')
ON CONFLICT (id_notification) DO NOTHING;

INSERT INTO messages (id_message, sender_user_id, receiver_user_id, message_content, is_read, sent_at)
VALUES
  ('a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a001', '22222222-2222-2222-2222-222222222222', '66666666-6666-6666-6666-666666666666', 'Olá Sofia! Consegues confirmar a aula de Física de amanhã?', false, now() - interval '1 hour')
ON CONFLICT (id_message) DO NOTHING;

COMMIT;
