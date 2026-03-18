CREATE TABLE IF NOT EXISTS lessons (
  id_lesson UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_course UUID REFERENCES courses(id_course) ON DELETE SET NULL,
  id_professor UUID REFERENCES professors(id_professor) ON DELETE SET NULL,
  title VARCHAR(200),
  status VARCHAR(50),
  students INTEGER,
  duration_minutes INTEGER,
  scheduled_start TIMESTAMP,
  scheduled_end TIMESTAMP,
  uses_custom_blocks BOOLEAN,
  max_students INTEGER,
  base_price NUMERIC(10,2),
  has_priority_vacancy BOOLEAN DEFAULT false,
  actual_duration_minutes INTEGER,
  telemetry_status VARCHAR(50)
);

-- Keep migrations idempotent for existing DBs (CREATE TABLE IF NOT EXISTS does not add columns).
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS status VARCHAR(50);
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS has_priority_vacancy BOOLEAN DEFAULT false;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS actual_duration_minutes INTEGER;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS telemetry_status VARCHAR(50);

CREATE TABLE IF NOT EXISTS lesson_feedback (
  id_lesson_feedback UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lesson UUID NOT NULL REFERENCES lessons(id_lesson) ON DELETE CASCADE,
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  is_valid BOOLEAN DEFAULT true,
  rating INTEGER,
  comments TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Prevent duplicate feedback submissions for the same lesson by the same user.
-- We keep it partial on is_valid=true to match the app's logic and avoid blocking legacy invalid rows.
CREATE UNIQUE INDEX IF NOT EXISTS ux_lesson_feedback_lesson_user_valid
  ON public.lesson_feedback (id_lesson, id_user)
  WHERE is_valid = true;

CREATE TABLE IF NOT EXISTS lesson_prices (
  id_lesson_price UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lesson UUID NOT NULL REFERENCES lessons(id_lesson) ON DELETE CASCADE,
  session_price NUMERIC(10,2),
  price_per_student NUMERIC(10,2),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_lesson)
);

CREATE TABLE IF NOT EXISTS lesson_schedule_blocks (
  id_lesson_schedule_block UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lesson UUID NOT NULL REFERENCES lessons(id_lesson) ON DELETE CASCADE,
  id_schedule_block UUID NOT NULL REFERENCES schedule_blocks(id_schedule_block) ON DELETE CASCADE,
  id_block_part UUID REFERENCES block_parts(id_block_part),
  start_time TIMESTAMP,
  end_time TIMESTAMP
);

CREATE TABLE IF NOT EXISTS enrollments (
  id_enrollment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lesson UUID NOT NULL REFERENCES lessons(id_lesson) ON DELETE CASCADE,
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  status VARCHAR(20),
  price_paid NUMERIC(10,2),
  created_at TIMESTAMP DEFAULT now()
);