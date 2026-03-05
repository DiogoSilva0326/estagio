-- Aula Extra - professor rooms (public.*)
-- Kept isolated from legacy professor.sql to avoid mismatched UUID-based schema.

CREATE TABLE IF NOT EXISTS public.professor_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    professor_id UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
    professor_name VARCHAR(255) NOT NULL,
    room_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_professor_rooms_professor UNIQUE (professor_id)
);

CREATE INDEX IF NOT EXISTS idx_professor_rooms_professor ON public.professor_rooms(professor_id);
CREATE INDEX IF NOT EXISTS idx_professor_rooms_room_name ON public.professor_rooms(room_name);
CREATE INDEX IF NOT EXISTS idx_professor_rooms_active ON public.professor_rooms(is_active);

CREATE OR REPLACE FUNCTION public.update_professor_rooms_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_professor_rooms_updated_at ON public.professor_rooms;
CREATE TRIGGER trigger_professor_rooms_updated_at
    BEFORE UPDATE ON public.professor_rooms
    FOR EACH ROW
    EXECUTE FUNCTION public.update_professor_rooms_updated_at();
