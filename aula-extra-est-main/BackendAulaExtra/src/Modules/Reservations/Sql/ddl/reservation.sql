CREATE TABLE IF NOT EXISTS reservations (
  id_reservation UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  id_lesson UUID NOT NULL REFERENCES lessons(id_lesson) ON DELETE CASCADE,
  id_lesson_schedule_block UUID REFERENCES lesson_schedule_blocks(id_lesson_schedule_block),
  id_schedule_block UUID REFERENCES schedule_blocks(id_schedule_block),
  id_block_part UUID REFERENCES block_parts(id_block_part),
  id_user_lesson_pack UUID,
  min_students_at_booking INTEGER DEFAULT 1,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  status VARCHAR(20),
  locked_price NUMERIC(12,2),
  student_confirmed_at TIMESTAMPTZ,
  attendance_status VARCHAR(30),
  forgiveness_window_ends_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  is_forgiven BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now()
);

-- Ensure additive migrations on existing DBs.
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS id_user_lesson_pack UUID;
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS locked_price NUMERIC(12,2);
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS student_confirmed_at TIMESTAMPTZ;
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS attendance_status VARCHAR(30);
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS forgiveness_window_ends_at TIMESTAMPTZ;
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS canceled_at TIMESTAMPTZ;
ALTER TABLE public.reservations ADD COLUMN IF NOT EXISTS is_forgiven BOOLEAN DEFAULT false;

-- Link disputes to reservations (diagram) once both tables exist.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_disputes_reservation'
  ) AND EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'disputes'
      AND column_name = 'id_reservation'
  ) THEN
    ALTER TABLE public.disputes
      ADD CONSTRAINT fk_disputes_reservation
      FOREIGN KEY (id_reservation)
      REFERENCES public.reservations(id_reservation)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS exception_rules (
  id_exception_rule UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID NOT NULL REFERENCES professors(id_professor) ON DELETE CASCADE,
  id_schedule_block UUID REFERENCES schedule_blocks(id_schedule_block),
  rule_type VARCHAR(50),
  custom_duration_minutes INTEGER,
  part_start_offset_minutes INTEGER,
  part_end_offset_minutes INTEGER,
  originating_request_id INTEGER,
  effective_from TIMESTAMP,
  effective_to TIMESTAMP,
  note TEXT
);

CREATE TABLE IF NOT EXISTS exception_requests (
  id_exception_request UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID REFERENCES users(id_user),
  id_reservation UUID REFERENCES reservations(id_reservation) ON DELETE CASCADE,
  id_professor UUID REFERENCES professors(id_professor),
  request_type VARCHAR(50),
  id_exception_rule UUID REFERENCES exception_rules(id_exception_rule),
  requested_duration_minutes INTEGER,
  requested_start TIMESTAMP,
  requested_end TIMESTAMP,
  status VARCHAR(20),
  reason TEXT,
  created_at TIMESTAMP DEFAULT now()
);