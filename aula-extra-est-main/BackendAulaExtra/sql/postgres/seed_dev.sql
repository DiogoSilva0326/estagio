-- seed_dev.sql
--
-- Seed (mock) data for Aula Extra (PostgreSQL).

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
  ('tutor'),
  ('psicologo'),
  ('aluno')
ON CONFLICT (description) DO NOTHING;

-- ==========================================================
-- 1) Users (public.users)
-- ==========================================================
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
  ('00000000-0000-0000-0000-000000000001', 'admin@aulaextra.dev', 'PRDZoJBcPPaTb/UO1v4D7w==.I8S5c7ek0vEsvK8zfv0RbNbyIAc50r0rzJDwJR+zFOI=', 'Administrador', 'AulaExtra', 'admin', 'Administrador', '+351910000000', false),
  ('00000000-0000-0000-0000-000000000007', 'admin@aulaextra.pt', 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=', 'Admin', 'Geral', 'admin.geral', 'Admin AulaExtra', '+351910000007', false),

  ('11111111-1111-1111-1111-111111111111', 'joao.silva@aulaextra.dev', 'Fvz22qH4EjuZiVnHaraI5A==.lkkFMCpp1rUh0p8LyO+c3Oni1MCFeMNP/IuW0zXNOmY=', 'João', 'Silva', 'joao.silva', 'João Silva', '+351910000001', false),
  ('22222222-2222-2222-2222-222222222222', 'maria.santos@aulaextra.dev', 'RVBlC83ZwIJzs8uikgayCQ==.n85ErEIliewxavh32vQ6o4lNApt72Qn/BRFNWeLiK+o=', 'Maria', 'Santos', 'maria.santos', 'Maria Santos', '+351910000002', false),
  ('33333333-3333-3333-3333-333333333333', 'pedro.costa@aulaextra.dev', 'RL+EqY9lHg0j2BdgpRtQyg==.zTftRzjOxQQ1be2e2/mm8a7qCguhd3HdZaczyExEFsE=', 'Pedro', 'Costa', 'pedro.costa', 'Pedro Costa', '+351910000003', false),
  ('44444444-4444-4444-4444-444444444444', 'ana.rodrigues@aulaextra.dev', 'xJtwwDtPhpgcbIr+zWm0Fw==.HgE33HPcRh/FqA8DoFP4zi9BipbEvAYBjJF2v9ZOksw=', 'Ana', 'Rodrigues', 'ana.rodrigues', 'Ana Rodrigues', '+351910000004', false),
  ('55555555-5555-5555-5555-555555555555', 'carlos.ferreira@aulaextra.dev', 'jxfg3W+QG951by9I0m1skA==.Aj82H4JER/0zsMTUrbDHS3von0F9QcX+vqNvkfvVO3k=', 'Carlos', 'Ferreira', 'carlos.ferreira', 'Carlos Ferreira', '+351910000005', false),
  ('77777777-7777-7777-7777-777777777777', 'luisa.almeida@aulaextra.dev', 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=', 'Luísa', 'Almeida', 'luisa.almeida', 'Luísa Almeida', '+351910000008', false),
  ('88888888-8888-8888-8888-888888888888', 'rui.matos@aulaextra.dev', 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=', 'Rui', 'Matos', 'rui.matos', 'Rui Matos', '+351910000009', false),
  ('99999999-9999-9999-9999-999999999999', 'monica.faria@aulaextra.dev', 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=', 'Mónica', 'Faria', 'monica.faria', 'Mónica Faria', '+351910000010', false),
  ('12121212-3434-5656-7878-909090909090', 'ines.batista@aulaextra.dev', 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=', 'Inês', 'Batista', 'ines.batista', 'Inês Batista', '+351910000011', false),
  ('13131313-3434-5656-7878-909090909090', 'tiago.carvalho@aulaextra.dev', 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=', 'Tiago', 'Carvalho', 'tiago.carvalho', 'Tiago Carvalho', '+351910000012', false),
  ('14141414-3434-5656-7878-909090909090', 'sara.coutinho@aulaextra.dev', 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=', 'Sara', 'Coutinho', 'sara.coutinho', 'Sara Coutinho', '+351910000013', false),

  -- Student used by the mocked UI (payments/notifications)
  ('66666666-6666-6666-6666-666666666666', 'sofia.oliveira@aulaextra.dev', 'w+imOUYXHhqKICxjIwFpaw==.t7WZUsgYE71EIjuFIo9VdXUhxtJrBJjbbChDfzEjlHM=', 'Sofia', 'Oliveira', 'sofia.oliveira', 'Sofia Oliveira', '+351910000006', false)
ON CONFLICT (id_user) DO NOTHING;

-- Ensure known dev password hash for the fixed seed users
UPDATE public.users SET password = 'PRDZoJBcPPaTb/UO1v4D7w==.I8S5c7ek0vEsvK8zfv0RbNbyIAc50r0rzJDwJR+zFOI=' WHERE id_user = '00000000-0000-0000-0000-000000000001';
UPDATE public.users SET password = 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=' WHERE id_user = '00000000-0000-0000-0000-000000000007';
UPDATE public.users SET password = 'Fvz22qH4EjuZiVnHaraI5A==.lkkFMCpp1rUh0p8LyO+c3Oni1MCFeMNP/IuW0zXNOmY=' WHERE id_user = '11111111-1111-1111-1111-111111111111';
UPDATE public.users SET password = 'RVBlC83ZwIJzs8uikgayCQ==.n85ErEIliewxavh32vQ6o4lNApt72Qn/BRFNWeLiK+o=' WHERE id_user = '22222222-2222-2222-2222-222222222222';
UPDATE public.users SET password = 'RL+EqY9lHg0j2BdgpRtQyg==.zTftRzjOxQQ1be2e2/mm8a7qCguhd3HdZaczyExEFsE=' WHERE id_user = '33333333-3333-3333-3333-333333333333';
UPDATE public.users SET password = 'xJtwwDtPhpgcbIr+zWm0Fw==.HgE33HPcRh/FqA8DoFP4zi9BipbEvAYBjJF2v9ZOksw=' WHERE id_user = '44444444-4444-4444-4444-444444444444';
UPDATE public.users SET password = 'jxfg3W+QG951by9I0m1skA==.Aj82H4JER/0zsMTUrbDHS3von0F9QcX+vqNvkfvVO3k=' WHERE id_user = '55555555-5555-5555-5555-555555555555';
UPDATE public.users SET password = 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=' WHERE id_user = '77777777-7777-7777-7777-777777777777';
UPDATE public.users SET password = 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=' WHERE id_user = '88888888-8888-8888-8888-888888888888';
UPDATE public.users SET password = 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=' WHERE id_user = '99999999-9999-9999-9999-999999999999';
UPDATE public.users SET password = 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=' WHERE id_user = '12121212-3434-5656-7878-909090909090';
UPDATE public.users SET password = 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=' WHERE id_user = '13131313-3434-5656-7878-909090909090';
UPDATE public.users SET password = 'xxRK0OxuHsOBeE0KMudaDw==.OUb/LisxNNSLz96cGh2qfSf3K0FkUTuYzv5z517LDOg=' WHERE id_user = '14141414-3434-5656-7878-909090909090';
UPDATE public.users SET password = 'w+imOUYXHhqKICxjIwFpaw==.t7WZUsgYE71EIjuFIo9VdXUhxtJrBJjbbChDfzEjlHM=' WHERE id_user = '66666666-6666-6666-6666-666666666666';

INSERT INTO public.user_profile (
  user_id, total_spent, prefered_language, status, inactive, creation_date, last_update, last_user_id
) VALUES
  ('00000000-0000-0000-0000-000000000001', 0, 'pt', 'active', false, now(), now(), NULL),
  ('00000000-0000-0000-0000-000000000007', 0, 'pt', 'active', false, now(), now(), NULL),
  ('11111111-1111-1111-1111-111111111111', 0, 'pt', 'active', false, now(), now(), NULL),
  ('22222222-2222-2222-2222-222222222222', 0, 'pt', 'active', false, now(), now(), NULL),
  ('33333333-3333-3333-3333-333333333333', 0, 'pt', 'active', false, now(), now(), NULL),
  ('44444444-4444-4444-4444-444444444444', 0, 'pt', 'active', false, now(), now(), NULL),
  ('55555555-5555-5555-5555-555555555555', 0, 'pt', 'active', false, now(), now(), NULL),
  ('77777777-7777-7777-7777-777777777777', 0, 'pt', 'active', false, now(), now(), NULL),
  ('88888888-8888-8888-8888-888888888888', 0, 'pt', 'active', false, now(), now(), NULL),
  ('99999999-9999-9999-9999-999999999999', 0, 'pt', 'active', false, now(), now(), NULL),
  ('12121212-3434-5656-7878-909090909090', 0, 'pt', 'active', false, now(), now(), NULL),
  ('13131313-3434-5656-7878-909090909090', 0, 'pt', 'active', false, now(), now(), NULL),
  ('14141414-3434-5656-7878-909090909090', 0, 'pt', 'active', false, now(), now(), NULL),
  ('66666666-6666-6666-6666-666666666666', 138, 'pt', 'active', false, now(), now(), NULL)
ON CONFLICT (user_id) DO NOTHING;

-- Assign roles
DELETE FROM public.user_role
WHERE user_id IN (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000007'::uuid,
  '11111111-1111-1111-1111-111111111111'::uuid,
  '22222222-2222-2222-2222-222222222222'::uuid,
  '33333333-3333-3333-3333-333333333333'::uuid,
  '44444444-4444-4444-4444-444444444444'::uuid,
  '55555555-5555-5555-5555-555555555555'::uuid,
  '66666666-6666-6666-6666-666666666666'::uuid,
  '77777777-7777-7777-7777-777777777777'::uuid,
  '88888888-8888-8888-8888-888888888888'::uuid,
  '99999999-9999-9999-9999-999999999999'::uuid,
  '12121212-3434-5656-7878-909090909090'::uuid,
  '13131313-3434-5656-7878-909090909090'::uuid,
  '14141414-3434-5656-7878-909090909090'::uuid
);

INSERT INTO public.user_role (role_id, user_id)
SELECT r.id, m.user_id
FROM (
  VALUES
    ('admin',    '00000000-0000-0000-0000-000000000001'::uuid),
    ('admin',    '00000000-0000-0000-0000-000000000007'::uuid),
    ('professor','11111111-1111-1111-1111-111111111111'::uuid),
    ('professor','22222222-2222-2222-2222-222222222222'::uuid),
    ('professor','33333333-3333-3333-3333-333333333333'::uuid),
    ('professor','44444444-4444-4444-4444-444444444444'::uuid),
    ('professor','55555555-5555-5555-5555-555555555555'::uuid),
    ('professor','77777777-7777-7777-7777-777777777777'::uuid),
    ('tutor',    '77777777-7777-7777-7777-777777777777'::uuid),
    ('professor','88888888-8888-8888-8888-888888888888'::uuid),
    ('tutor',    '88888888-8888-8888-8888-888888888888'::uuid),
    ('professor','99999999-9999-9999-9999-999999999999'::uuid),
    ('tutor',    '99999999-9999-9999-9999-999999999999'::uuid),
    ('professor','12121212-3434-5656-7878-909090909090'::uuid),
    ('psicologo','12121212-3434-5656-7878-909090909090'::uuid),
    ('professor','13131313-3434-5656-7878-909090909090'::uuid),
    ('psicologo','13131313-3434-5656-7878-909090909090'::uuid),
    ('professor','14141414-3434-5656-7878-909090909090'::uuid),
    ('psicologo','14141414-3434-5656-7878-909090909090'::uuid),
    ('aluno',    '66666666-6666-6666-6666-666666666666'::uuid)
) AS m(role_description, user_id)
JOIN public.role r ON r.description = m.role_description
ON CONFLICT (role_id, user_id) DO NOTHING;

-- ==========================================================
-- 2) Professors
-- ==========================================================
INSERT INTO professors (
  id_professor, id_user, current_school, years_experience, photo, biography, vat, iban, is_verified_iban, is_active, is_verified, created_at, updated_at
) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 'Escola Secundária Central', 6, 'https://i.pravatar.cc/200?img=12', 'Explicador de Matemática com foco em exames.', '123456789', 'PT50000000000000000000000', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '22222222-2222-2222-2222-222222222222', 'Escola Secundária Central', 4, 'https://i.pravatar.cc/200?img=47', 'Explicadora de Física/Química.', '223456789', 'PT50000000000000000000001', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', '33333333-3333-3333-3333-333333333333', 'Colégio do Atlântico', 5, 'https://i.pravatar.cc/200?img=32', 'Inglês para todos os níveis.', '323456789', 'PT50000000000000000000002', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', '44444444-4444-4444-4444-444444444444', 'Colégio do Atlântico', 3, 'https://i.pravatar.cc/200?img=5', 'Matemática (7º ao 12º).', '423456789', 'PT50000000000000000000003', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', '55555555-5555-5555-5555-555555555555', 'Escola Secundária do Norte', 7, 'https://i.pravatar.cc/200?img=58', 'Física aplicada e preparação para testes.', '523456789', 'PT50000000000000000000004', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', '77777777-7777-7777-7777-777777777777', 'Centro de Estudos Horizonte', 8, 'https://i.pravatar.cc/200?img=21', 'Tutora de Português e apoio ao estudo.', '623456789', 'PT50000000000000000000005', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa7', '88888888-8888-8888-8888-888888888888', 'Academia Saber+', 5, 'https://i.pravatar.cc/200?img=28', 'Tutor de História e preparação para exames.', '723456789', 'PT50000000000000000000006', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8', '99999999-9999-9999-9999-999999999999', 'Centro Explica', 6, 'https://i.pravatar.cc/200?img=48', 'Tutora focada em métodos de estudo e organização.', '823456789', 'PT50000000000000000000007', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9', '12121212-3434-5656-7878-909090909090', 'Clínica Equilíbrio', 9, 'https://i.pravatar.cc/200?img=15', 'Psicóloga educacional com foco em ansiedade escolar.', '923456789', 'PT50000000000000000000008', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', '13131313-3434-5656-7878-909090909090', 'Espaço Mente Serena', 11, 'https://i.pravatar.cc/200?img=61', 'Psicólogo com experiência em orientação vocacional.', '133456789', 'PT50000000000000000000009', true, true, true, now(), now()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', '14141414-3434-5656-7878-909090909090', 'Gabinete Crescer', 7, 'https://i.pravatar.cc/200?img=53', 'Psicóloga infantil e apoio emocional ao estudante.', '143456789', 'PT50000000000000000000010', true, true, true, now(), now())
ON CONFLICT (id_professor) DO NOTHING;

UPDATE professors
SET presentation_video_url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
WHERE id_professor = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1';

INSERT INTO public.professor_rooms (professor_id, professor_name, room_name, description, is_active)
SELECT u.id_user, COALESCE(NULLIF(u.display_name, ''), CONCAT_WS(' ', u.first_name, u.last_name), u.username), CONCAT('professor_', LOWER(u.username)), CONCAT('Sala do professor ', COALESCE(NULLIF(u.display_name, ''), CONCAT_WS(' ', u.first_name, u.last_name), u.username)), true
FROM public.professors p JOIN public.users u ON u.id_user = p.id_user
ON CONFLICT (professor_id) DO UPDATE
SET professor_name = EXCLUDED.professor_name, room_name = EXCLUDED.room_name, description = EXCLUDED.description, is_active = EXCLUDED.is_active;

-- ==========================================================
-- 3) Education taxonomy (disciplines + levels)
-- ==========================================================
INSERT INTO public.areas (id_area, nome, descricao, target_role) VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Matemática', NULL, 'ensino'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Ciências', NULL, 'ensino'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Línguas', NULL, 'ensino'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0004', 'Humanidades', NULL, 'ensino'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0005', 'Tecnologia', NULL, 'ensino'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0006', 'Artes', NULL, 'ensino'),
  ('cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Psicologia Clínica e da Saúde', 'Acompanhamento clínico geral', 'psicologia'),
  ('cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Psicologia Educacional', 'Foco no estudante e aprendizagem', 'psicologia'),
  ('cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Desenvolvimento e Infância', 'Acompanhamento infantil e parentalidade', 'psicologia'),
  ('cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0004', 'Neuropsicologia', 'Avaliação e reabilitação cognitiva', 'psicologia'),
  ('dddddddd-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Suporte ao Estudo e Produtividade', 'Métodos, foco e planeamento', 'tutoria'),
  ('dddddddd-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Apoio Académico Universitário', 'Apoio a teses e análise de dados', 'tutoria'),
  ('dddddddd-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Desenvolvimento Pessoal', 'Soft skills, comunicação e inteligência emocional', 'tutoria')
ON CONFLICT (id_area) DO NOTHING;

INSERT INTO disciplinas (id_disciplina, id_area, nome, descricao) VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Matemática', 'Álgebra, geometria, trigonometria.'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Física', 'Mecânica, eletricidade e ondas.'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb003', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Química', 'Estequiometria e reações químicas.'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Inglês', 'Gramática, conversação e escrita.'),
  ('cccccccc-cccc-bbbb-bbbb-bbbbbbbbb001', 'cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Ansiedade e Depressão', 'Intervenção clínica focada.'),
  ('cccccccc-cccc-bbbb-bbbb-bbbbbbbbb002', 'cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Terapia de Casal e Familiar', 'Dinâmicas relacionais.'),
  ('cccccccc-cccc-bbbb-bbbb-bbbbbbbbb003', 'cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Orientação Vocacional', 'Decisão de carreira e percurso académico.'),
  ('cccccccc-cccc-bbbb-bbbb-bbbbbbbbb004', 'cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Dificuldades de Aprendizagem', 'Apoio em casos de Dislexia ou TDAH.'),
  ('cccccccc-cccc-bbbb-bbbb-bbbbbbbbb005', 'cccccccc-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Treino de Competências Parentais', 'Orientação para pais.'),
  ('dddddddd-dddd-bbbb-bbbb-bbbbbbbbb001', 'dddddddd-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Métodos de Estudo', 'Ensino de técnicas e organização.'),
  ('dddddddd-dddd-bbbb-bbbb-bbbbbbbbb002', 'dddddddd-bbbb-bbbb-bbbb-bbbbbbbb0001', 'Gestão de Tempo', 'Foco e planeamento semanal.'),
  ('dddddddd-dddd-bbbb-bbbb-bbbbbbbbb003', 'dddddddd-bbbb-bbbb-bbbb-bbbbbbbb0002', 'Escrita Académica', 'Apoio a teses e formatação APA/APA.'),
  ('dddddddd-dddd-bbbb-bbbb-bbbbbbbbb004', 'dddddddd-bbbb-bbbb-bbbb-bbbbbbbb0003', 'Preparação para Entrevistas', 'Treino prático e feedback.'),
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

INSERT INTO public.user_disciplina (user_id, id_disciplina) VALUES
  ('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001'),
  ('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002'),
  ('66666666-6666-6666-6666-666666666666', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004')
ON CONFLICT (user_id, id_disciplina) DO NOTHING;

INSERT INTO public.languages (id_language, nome) VALUES
  ('abababab-abab-abab-abab-abababab0001', 'Português'),
  ('abababab-abab-abab-abab-abababab0002', 'Inglês'),
  ('abababab-abab-abab-abab-abababab0003', 'Espanhol'),
  ('abababab-abab-abab-abab-abababab0004', 'Francês')
ON CONFLICT (id_language) DO NOTHING;

INSERT INTO public.professor_languages (id_professor, id_language, proficiency_level) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'abababab-abab-abab-abab-abababab0001', 'Nativo'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'abababab-abab-abab-abab-abababab0002', 'Avançado'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'abababab-abab-abab-abab-abababab0001', 'Nativo'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'abababab-abab-abab-abab-abababab0002', 'Nativo'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'abababab-abab-abab-abab-abababab0003', 'Intermédio')
ON CONFLICT (id_professor, id_language) DO NOTHING;

INSERT INTO anos_escolaridade (id_ano_escolaridade, nome, ano_index) VALUES
  ('cccccccc-cccc-cccc-cccc-ccccccccc010', '7º Ano', 7),
  ('cccccccc-cccc-cccc-cccc-ccccccccc011', '8º Ano', 8),
  ('cccccccc-cccc-cccc-cccc-ccccccccc012', '9º Ano', 9),
  ('cccccccc-cccc-cccc-cccc-ccccccccc100', '10º Ano', 10),
  ('cccccccc-cccc-cccc-cccc-ccccccccc110', '11º Ano', 11),
  ('cccccccc-cccc-cccc-cccc-ccccccccc120', '12º Ano', 12)
ON CONFLICT (id_ano_escolaridade) DO NOTHING;

INSERT INTO ciclos_estudo (id_ciclo_estudo, nome, descricao) VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddd001', '3º Ciclo', '7º ao 9º ano'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd002', 'Secundário', '10º ao 12º ano')
ON CONFLICT (id_ciclo_estudo) DO NOTHING;

INSERT INTO ciclos_estudo_anos (id_ciclo_estudo_ano_escolaridade, id_ciclo_estudo, id_ano_escolaridade) VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddd101', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'cccccccc-cccc-cccc-cccc-ccccccccc010'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd102', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'cccccccc-cccc-cccc-cccc-ccccccccc011'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd103', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'cccccccc-cccc-cccc-cccc-ccccccccc012'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd201', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'cccccccc-cccc-cccc-cccc-ccccccccc100'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd202', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'cccccccc-cccc-cccc-cccc-ccccccccc110'),
  ('dddddddd-dddd-dddd-dddd-ddddddddd203', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'cccccccc-cccc-cccc-cccc-ccccccccc120')
ON CONFLICT (id_ciclo_estudo_ano_escolaridade) DO NOTHING;

-- Associar os profissionais às disciplinas pretendidas
INSERT INTO public.professor_disciplina (id_professor, id_disciplina, is_active)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', true), -- 1: Matemática
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb108', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa7', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb112', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8', 'dddddddd-dddd-bbbb-bbbb-bbbbbbbbb001', true), -- 8: Métodos de Estudo
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9', 'cccccccc-cccc-bbbb-bbbb-bbbbbbbbb004', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'cccccccc-cccc-bbbb-bbbb-bbbbbbbbb003', true),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'cccccccc-cccc-bbbb-bbbb-bbbbbbbbb001', true)  -- 11: Apoio Emocional
ON CONFLICT (id_professor, id_disciplina) DO NOTHING;

-- ==========================================================
-- 4) Courses + pricing (matches the mocked UI subjects)
-- ==========================================================
INSERT INTO tutoring_types (id_tutoring_type, name, description) VALUES
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'Individual', 'Aula 1:1'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeee0002', 'Grupo', 'Aula em grupo')
ON CONFLICT (id_tutoring_type) DO NOTHING;

INSERT INTO pricing_models (id_pricing_model, name, description) VALUES
  ('ffffffff-ffff-ffff-ffff-ffffffff0001', 'Preço por sessão', 'Preço fixo por sessão'),
  ('ffffffff-ffff-ffff-ffff-ffffffff0002', 'Preço por aluno', 'Preço por aluno')
ON CONFLICT (id_pricing_model) DO NOTHING;

INSERT INTO courses (
  id_course, id_professor, id_pricing_model, id_tutoring_type, id_disciplina, id_ano_escolaridade, id_ciclo_estudo, name, description, level_of_education, num_max_students, num_min_students, created_at, updated_at
) VALUES
  ('10101010-1010-1010-1010-101010101001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'cccccccc-cccc-cccc-cccc-ccccccccc120', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Matemática - Preparação Exames', 'Aulas focadas em exercícios e exame.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'cccccccc-cccc-cccc-cccc-ccccccccc110', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Física - Sessões Práticas', 'Resolução guiada e preparação para testes.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb004', 'cccccccc-cccc-cccc-cccc-ccccccccc100', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Inglês - Conversação', 'Aulas focadas em speaking/listening.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101004', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb001', 'cccccccc-cccc-cccc-cccc-ccccccccc012', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'Matemática - 3º Ciclo', 'Bases e resolução de fichas.', '3º Ciclo', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101005', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb002', 'cccccccc-cccc-cccc-cccc-ccccccccc110', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Física - Preparação Testes', 'Preparação para fichas e exames.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101006', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb108', 'cccccccc-cccc-cccc-cccc-ccccccccc012', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'Português - Apoio ao Estudo', 'Plano semanal de acompanhamento escolar.', '3º Ciclo', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101007', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa7', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbb112', 'cccccccc-cccc-cccc-cccc-ccccccccc110', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'História - Preparação Exames', 'Acompanhamento focado em testes e exame nacional.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101008', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'dddddddd-dddd-bbbb-bbbb-bbbbbbbbb001', 'cccccccc-cccc-cccc-cccc-ccccccccc100', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Métodos de Estudo', 'Sessões para organização, foco e autonomia.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101009', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa9', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'cccccccc-cccc-bbbb-bbbb-bbbbbbbbb004', 'cccccccc-cccc-cccc-cccc-ccccccccc100', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Psicologia Educacional', 'Acompanhamento individual para ansiedade e desempenho.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101010', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa10', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'cccccccc-cccc-bbbb-bbbb-bbbbbbbbb003', 'cccccccc-cccc-cccc-cccc-ccccccccc120', 'dddddddd-dddd-dddd-dddd-ddddddddd002', 'Orientação Vocacional', 'Sessões práticas para escolha de percurso académico.', 'Secundário', 1, 1, now(), now()),
  ('10101010-1010-1010-1010-101010101011', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'ffffffff-ffff-ffff-ffff-ffffffff0001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeee0001', 'cccccccc-cccc-bbbb-bbbb-bbbbbbbbb001', 'cccccccc-cccc-cccc-cccc-ccccccccc012', 'dddddddd-dddd-dddd-dddd-ddddddddd001', 'Apoio Emocional ao Estudante', 'Sessões de apoio emocional e gestão de stress escolar.', '3º Ciclo', 1, 1, now(), now())
ON CONFLICT (id_course) DO NOTHING;

INSERT INTO course_prices (id_course_price, id_course, session_price, price_per_student, number_students, active) VALUES
  ('12121212-1212-1212-1212-121212121001', '10101010-1010-1010-1010-101010101001', 25.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121002', '10101010-1010-1010-1010-101010101002', 30.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121003', '10101010-1010-1010-1010-101010101003', 28.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121004', '10101010-1010-1010-1010-101010101004', 25.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121005', '10101010-1010-1010-1010-101010101005', 30.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121006', '10101010-1010-1010-1010-101010101006', 22.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121007', '10101010-1010-1010-1010-101010101007', 24.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121008', '10101010-1010-1010-1010-101010101008', 21.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121009', '10101010-1010-1010-1010-101010101009', 35.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121010', '10101010-1010-1010-1010-101010101010', 35.00, NULL, 1, true),
  ('12121212-1212-1212-1212-121212121011', '10101010-1010-1010-1010-101010101011', 32.00, NULL, 1, true)
ON CONFLICT (id_course_price) DO NOTHING;

-- ==========================================================
-- 5) Lessons + enrollments + reservations (calendar + payments)
-- ==========================================================
-- In this section we ONLY insert the 3 specific lessons for Sofia (Explicador, Tutor, Psicólogo).
-- And some other generic lessons for other students to keep the DB populated.

INSERT INTO lessons (
  id_lesson, id_course, id_professor, title, students, duration_minutes, scheduled_start, scheduled_end, uses_custom_blocks, max_students, base_price
) VALUES
  -- Sofia's 3 Lessons
  ('20202020-2020-2020-2020-202020202001', '10101010-1010-1010-1010-101010101001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Aula de Matemática', 1, 60, '2026-01-27 14:30:00', '2026-01-27 15:30:00', false, 1, 25.00),
  ('20202020-2020-2020-2020-202020202008', '10101010-1010-1010-1010-101010101008', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8', 'Aula de Métodos de Estudo', 1, 60, '2026-01-29 18:00:00', '2026-01-29 19:00:00', false, 1, 21.00),
  ('20202020-2020-2020-2020-202020202011', '10101010-1010-1010-1010-101010101011', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 'Consulta Apoio Emocional', 1, 60, '2026-02-01 16:00:00', '2026-02-01 17:00:00', false, 1, 32.00),

  -- Other generic lessons (no Sofia enrollment)
  ('20202020-2020-2020-2020-202020202002', '10101010-1010-1010-1010-101010101002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Aula de Física', 1, 60, '2026-01-27 16:00:00', '2026-01-27 17:00:00', false, 1, 30.00),
  ('20202020-2020-2020-2020-202020202003', '10101010-1010-1010-1010-101010101003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Aula de Inglês', 1, 60, '2026-01-28 10:00:00', '2026-01-28 11:00:00', false, 1, 28.00)
ON CONFLICT (id_lesson) DO NOTHING;

INSERT INTO lesson_prices (id_lesson_price, id_lesson, session_price, price_per_student) VALUES
  ('21212121-2121-2121-2121-212121212001', '20202020-2020-2020-2020-202020202001', 25.00, NULL),
  ('21212121-2121-2121-2121-212121212008', '20202020-2020-2020-2020-202020202008', 21.00, NULL),
  ('21212121-2121-2121-2121-212121212011', '20202020-2020-2020-2020-202020202011', 32.00, NULL),
  ('21212121-2121-2121-2121-212121212002', '20202020-2020-2020-2020-202020202002', 30.00, NULL),
  ('21212121-2121-2121-2121-212121212003', '20202020-2020-2020-2020-202020202003', 28.00, NULL)
ON CONFLICT (id_lesson_price) DO NOTHING;

-- Enrollments: SOFIA is ONLY enrolled in 001, 008, and 011.
INSERT INTO enrollments (id_enrollment, id_lesson, id_user, status, price_paid) VALUES
  ('30303030-3030-3030-3030-303030303001', '20202020-2020-2020-2020-202020202001', '66666666-6666-6666-6666-666666666666', 'active', 25.00),
  ('30303030-3030-3030-3030-303030303008', '20202020-2020-2020-2020-202020202008', '66666666-6666-6666-6666-666666666666', 'active', 21.00),
  ('30303030-3030-3030-3030-303030303011', '20202020-2020-2020-2020-202020202011', '66666666-6666-6666-6666-666666666666', 'active', 32.00)
ON CONFLICT (id_enrollment) DO NOTHING;

INSERT INTO lesson_feedback (id_lesson_feedback, id_lesson, id_user, is_valid, rating, comments, created_at) VALUES
  ('90909090-9090-9090-9090-909090909001', '20202020-2020-2020-2020-202020202001', '66666666-6666-6666-6666-666666666666', true, 5, 'Muito boa aula.', '2026-01-27 16:10:00')
ON CONFLICT (id_lesson_feedback) DO NOTHING;

INSERT INTO professor_feedback (id_professor_feedback, id_professor, id_user, is_valid, rating, comments, created_at) VALUES
  ('91919191-9191-9191-9191-919191919001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '66666666-6666-6666-6666-666666666666', true, 5, 'Recomendo!', '2026-01-28 18:00:00')
ON CONFLICT (id_professor_feedback) DO NOTHING;

INSERT INTO reservations (
  id_reservation, id_user, id_lesson, min_students_at_booking, start_time, end_time, status, created_at
) VALUES
  ('40404040-4040-4040-4040-404040404001', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202001', 1, '2026-01-20 14:30:00', '2026-01-20 15:30:00', 'paid', '2026-01-20 13:00:00'),
  ('40404040-4040-4040-4040-404040404008', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202008', 1, '2026-01-29 18:00:00', '2026-01-29 19:00:00', 'paid', '2026-01-29 16:00:00'),
  ('40404040-4040-4040-4040-404040404011', '66666666-6666-6666-6666-666666666666', '20202020-2020-2020-2020-202020202011', 1, '2026-02-01 16:00:00', '2026-02-01 17:00:00', 'paid', '2026-02-01 14:00:00')
ON CONFLICT (id_reservation) DO NOTHING;

-- Keep the seeded calendar useful by updating the timestamps dynamically
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
  SELECT '20202020-2020-2020-2020-202020202008'::uuid AS id_lesson, (base.week_start + interval '2 day 16 hour')       AS scheduled_start, (base.week_start + interval '2 day 17 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202011'::uuid AS id_lesson, (base.week_start - interval '3 day 10 hour')       AS scheduled_start, (base.week_start - interval '3 day 9 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202002'::uuid AS id_lesson, (base.week_start + interval '4 day 15 hour')       AS scheduled_start, (base.week_start + interval '4 day 16 hour')       AS scheduled_end FROM base
  UNION ALL
  SELECT '20202020-2020-2020-2020-202020202003'::uuid AS id_lesson, base.live_start AS scheduled_start, (base.live_start + interval '1 hour') AS scheduled_end FROM base
) v
WHERE l.id_lesson = v.id_lesson;

UPDATE reservations r
SET
  start_time = l.scheduled_start,
  end_time = l.scheduled_end,
  created_at = l.scheduled_start - interval '2 hours'
FROM lessons l
WHERE r.id_lesson = l.id_lesson
  AND r.id_reservation IN (
    '40404040-4040-4040-4040-404040404001'::uuid,
    '40404040-4040-4040-4040-404040404008'::uuid,
    '40404040-4040-4040-4040-404040404011'::uuid
  );

-- ==========================================================
-- 6) Wallet + transactions + reservation payments
-- ==========================================================
INSERT INTO wallets (id_wallet, owner_type, owner_user_id, balance, hold_amount, currency) VALUES
  ('50505050-5050-5050-5050-505050505001', 'user', '66666666-6666-6666-6666-666666666666', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505002', 'user', '11111111-1111-1111-1111-111111111111', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505003', 'user', '88888888-8888-8888-8888-888888888888', 0.00, 0.00, 'EUR'),
  ('50505050-5050-5050-5050-505050505004', 'user', '14141414-3434-5656-7878-909090909090', 0.00, 0.00, 'EUR')
ON CONFLICT (id_wallet) DO NOTHING;

INSERT INTO transactions (id_transaction, wallet_id, transaction_type, amount, balance_before, balance_after, status, created_at) VALUES
  ('60606060-6060-6060-6060-606060606001', '50505050-5050-5050-5050-505050505001', 'debit', 25.00, 138.00, 113.00, 'succeeded', '2026-01-20 13:01:00'),
  ('60606060-6060-6060-6060-606060606008', '50505050-5050-5050-5050-505050505001', 'debit', 21.00, 113.00, 92.00, 'succeeded', '2026-01-29 08:01:00'),
  ('60606060-6060-6060-6060-606060606011', '50505050-5050-5050-5050-505050505001', 'debit', 32.00, 92.00, 60.00, 'succeeded', '2026-02-01 14:01:00')
ON CONFLICT (id_transaction) DO NOTHING;

INSERT INTO commission_rules (id_commission_rule, id_professor, percent, fixed_fee, applies_to, effective_from) VALUES
  ('70707070-7070-7070-7070-707070707001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00'),
  ('70707070-7070-7070-7070-707070707008', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa8', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00'),
  ('70707070-7070-7070-7070-707070707011', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa11', 10.00, 0.00, 'reservation', '2026-01-01 00:00:00')
ON CONFLICT (id_commission_rule) DO NOTHING;

INSERT INTO reservation_payments (
  id_reservation_payment, reservation_id, payer_wallet_id, transaction_id, commission_rule_id, amount, status, created_at
) VALUES
  ('80808080-8080-8080-8080-808080808001', '40404040-4040-4040-4040-404040404001', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606001', '70707070-7070-7070-7070-707070707001', 25.00, 'paid', '2026-01-20 13:02:00'),
  ('80808080-8080-8080-8080-808080808008', '40404040-4040-4040-4040-404040404008', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606008', '70707070-7070-7070-7070-707070707008', 21.00, 'paid', '2026-01-29 08:02:00'),
  ('80808080-8080-8080-8080-808080808011', '40404040-4040-4040-4040-404040404011', '50505050-5050-5050-5050-505050505001', '60606060-6060-6060-6060-606060606011', '70707070-7070-7070-7070-707070707011', 32.00, 'paid', '2026-02-01 14:02:00')
ON CONFLICT (id_reservation_payment) DO NOTHING;

-- ==========================================================
-- 7) Notifications + messages (from mocked UI)
-- ==========================================================
INSERT INTO notifications (id_notification, id_user, type, message, was_read, created_at, updated_at) VALUES
  ('90909090-9090-9090-9090-909090909001', '66666666-6666-6666-6666-666666666666', 'aula', 'A sua aula de Matemática com João Silva começa em breve', false, now(), now()),
  ('90909090-9090-9090-9090-909090909003', '66666666-6666-6666-6666-666666666666', 'mensagem', 'Sara Coutinho enviou uma mensagem', false, now() - interval '1 hour', now() - interval '1 hour'),
  ('90909090-9090-9090-9090-909090909004', '66666666-6666-6666-6666-666666666666', 'avaliacao', 'Que tal avaliar a sua sessão de Tutoria com Rui Matos?', true, now() - interval '2 hours', now() - interval '2 hours')
ON CONFLICT (id_notification) DO NOTHING;

INSERT INTO messages (id_message, sender_user_id, receiver_user_id, message_content, is_read, sent_at) VALUES
  ('a0a0a0a0-a0a0-a0a0-a0a0-a0a0a0a0a001', '14141414-3434-5656-7878-909090909090', '66666666-6666-6666-6666-666666666666', 'Olá Sofia! Consegues confirmar a sessão de amanhã?', false, now() - interval '1 hour')
ON CONFLICT (id_message) DO NOTHING;

COMMIT;