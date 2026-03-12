CREATE TABLE IF NOT EXISTS days (
  id_day UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(20) NOT NULL,
  day_index INTEGER
);

CREATE TABLE IF NOT EXISTS schedule_blocks (
  id_schedule_block UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID NOT NULL REFERENCES professors(id_professor) ON DELETE CASCADE,
  id_day UUID REFERENCES days(id_day),
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  default_duration_minutes INTEGER,
  is_available BOOLEAN,
  recurrence_rule TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS block_parts (
  id_block_part UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_schedule_block UUID NOT NULL REFERENCES schedule_blocks(id_schedule_block) ON DELETE CASCADE,
  start_offset_minutes INTEGER,
  end_offset_minutes INTEGER,
  is_available BOOLEAN
);