-- Role table (used by public.user_role)
-- Matches the updated class diagram: role(id SERIAL PK, description UNIQUE NOT NULL)

CREATE TABLE IF NOT EXISTS public.role (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    description TEXT NOT NULL UNIQUE
);

-- Seed minimal roles used by the app (idempotent)
INSERT INTO public.role (description)
VALUES ('Standard'), ('admin'), ('professor'), ('tutor'), ('psicologo'), ('aluno')
ON CONFLICT (description) DO NOTHING;
