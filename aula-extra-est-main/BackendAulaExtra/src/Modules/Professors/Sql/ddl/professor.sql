-- ========== PROFESSOR & PROFILE ==========
CREATE TABLE IF NOT EXISTS professors (
  id_professor UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user),
  current_school VARCHAR(255),
  years_experience INTEGER,
  photo TEXT,
  biography TEXT,
  presentation_video_url TEXT,
  vat VARCHAR(50),
  iban VARCHAR(50),
  iban_document_url TEXT,
  is_verified_iban BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_user)
);

CREATE TABLE IF NOT EXISTS professor_feedback (
  id_professor_feedback UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID NOT NULL REFERENCES professors(id_professor),
  id_user UUID NOT NULL REFERENCES users(id_user),
  is_valid BOOLEAN DEFAULT true,
  rating INTEGER,
  comments TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- One feedback per student per professor
CREATE UNIQUE INDEX IF NOT EXISTS ux_professor_feedback_professor_user
  ON public.professor_feedback (id_professor, id_user);

CREATE TABLE IF NOT EXISTS certificates (
  id_certificate UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID NOT NULL REFERENCES professors(id_professor),
  name VARCHAR(255),
  description TEXT,
  file_url TEXT,
  verified BOOLEAN DEFAULT false,
  verified_by_user_id UUID REFERENCES users(id_user),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE IF EXISTS public.certificates
  ADD COLUMN IF NOT EXISTS description TEXT;


-- professor_rooms is created in ../ddl/create_professor_rooms.sql (UUID-based).
-- Seed rooms for existing professors (if any)
INSERT INTO public.professor_rooms (professor_id, professor_name, room_name)
SELECT
  u.id_user,
  COALESCE(u.display_name, u.username),
  CONCAT('Professor_', u.username)
FROM public.professors p
JOIN public.users u ON u.id_user = p.id_user
WHERE NOT EXISTS (
  SELECT 1 FROM public.professor_rooms pr WHERE pr.professor_id = u.id_user
)
ON CONFLICT (professor_id) DO NOTHING;

COMMENT ON TABLE public.professor_rooms IS 'Video call rooms owned by professors - each professor has a unique room';
COMMENT ON COLUMN public.professor_rooms.room_name IS 'Unique room name for video calls. Default format: Professor_Username. Can be customized by the professor.';
