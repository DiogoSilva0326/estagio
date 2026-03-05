CREATE TABLE IF NOT EXISTS reservations (
  id_reservation UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  id_lesson UUID NOT NULL REFERENCES lessons(id_lesson) ON DELETE CASCADE,
  id_lesson_schedule_block UUID REFERENCES lesson_schedule_blocks(id_lesson_schedule_block),
  id_schedule_block UUID REFERENCES schedule_blocks(id_schedule_block),
  id_block_part UUID REFERENCES block_parts(id_block_part),
  min_students_at_booking INTEGER DEFAULT 1,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now()
);

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