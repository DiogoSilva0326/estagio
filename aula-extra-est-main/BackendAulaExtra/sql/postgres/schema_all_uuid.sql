-- Postgres schema for Aula Extra platform (UUID version)
-- Fresh DB creation only: uses UUID primary keys with default gen_random_uuid().
-- Requires extension: pgcrypto
-- Use in psql: \i sql/postgres/schema_all_uuid.sql

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ========== CORE ROLES & USERS ==========
CREATE TABLE IF NOT EXISTS roles (
  id_role UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS users (
  id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE,
  display_name TEXT,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(255) UNIQUE,
  password_hash TEXT,
  cell_phone_number VARCHAR(50),
  email_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  id_role UUID NOT NULL REFERENCES roles(id_role)
);

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

CREATE TABLE IF NOT EXISTS certificates (
  id_certificate UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID NOT NULL REFERENCES professors(id_professor),
  name VARCHAR(255),
  file_url TEXT,
  verified BOOLEAN DEFAULT false,
  verified_by_user_id UUID REFERENCES users(id_user),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- ========== EDUCATION TAXONOMY ==========
CREATE TABLE IF NOT EXISTS disciplinas (
  id_disciplina UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(150) NOT NULL,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS anos_escolaridade (
  id_ano_escolaridade UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(100),
  ano_index INTEGER,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ciclos_estudo (
  id_ciclo_estudo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(150) NOT NULL,
  descricao TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ciclos_estudo_anos (
  id_ciclo_estudo_ano_escolaridade UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_ciclo_estudo UUID NOT NULL REFERENCES ciclos_estudo(id_ciclo_estudo),
  id_ano_escolaridade UUID NOT NULL REFERENCES anos_escolaridade(id_ano_escolaridade),
  created_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_ciclo_estudo, id_ano_escolaridade)
);

-- ========== COURSE & PRICING ==========
CREATE TABLE IF NOT EXISTS tutoring_types (
  id_tutoring_type UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS pricing_models (
  id_pricing_model UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS courses (
  id_course UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID REFERENCES professors(id_professor),
  id_pricing_model UUID REFERENCES pricing_models(id_pricing_model),
  id_tutoring_type UUID REFERENCES tutoring_types(id_tutoring_type),
  id_disciplina UUID REFERENCES disciplinas(id_disciplina),
  id_ano_escolaridade UUID REFERENCES anos_escolaridade(id_ano_escolaridade),
  id_ciclo_estudo UUID REFERENCES ciclos_estudo(id_ciclo_estudo),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  level_of_education VARCHAR(100),
  num_max_students INTEGER,
  num_min_students INTEGER,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_professor, id_disciplina, id_ano_escolaridade, id_tutoring_type)
);

CREATE TABLE IF NOT EXISTS course_prices (
  id_course_price UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_course UUID NOT NULL REFERENCES courses(id_course) ON DELETE CASCADE,
  session_price NUMERIC(10,2),
  price_per_student NUMERIC(10,2),
  number_students INTEGER,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- ========== WISHLIST & FAVORITES ==========
CREATE TABLE IF NOT EXISTS wishlists (
  id_wishlist UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT now(),
  UNIQUE (id_user)
);

CREATE TABLE IF NOT EXISTS wishlist_items (
  id_wishlist_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_wishlist UUID NOT NULL REFERENCES wishlists(id_wishlist) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id_course) ON DELETE SET NULL,
  added_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS favorites (
  id_favorite UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,

  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),

  UNIQUE (id_user)
);

CREATE TABLE IF NOT EXISTS favorite_items (
  id_favorite_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_favorite UUID NOT NULL REFERENCES favorites(id_favorite) ON DELETE CASCADE,
  id_professor UUID NOT NULL REFERENCES professors(id_professor) ON DELETE CASCADE,
  added_at TIMESTAMP DEFAULT now(),
  UNIQUE(id_favorite, id_professor)
);

-- ========== SCHEDULING ==========
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

-- ========== LESSON & ENROLLMENTS ==========
CREATE TABLE IF NOT EXISTS lessons (
  id_lesson UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_course UUID REFERENCES courses(id_course) ON DELETE SET NULL,

  id_professor UUID REFERENCES professors(id_professor) ON DELETE SET NULL,
  title VARCHAR(200),
  students INTEGER,
  duration_minutes INTEGER,
  scheduled_start TIMESTAMP,
  scheduled_end TIMESTAMP,
  uses_custom_blocks BOOLEAN,
  max_students INTEGER,
  base_price NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS lesson_feedback (
  id_lesson_feedback UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_lesson UUID NOT NULL REFERENCES lessons(id_lesson) ON DELETE CASCADE,
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  is_valid BOOLEAN DEFAULT true,
  rating INTEGER,
  comments TEXT,
  created_at TIMESTAMP DEFAULT now()
);

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

-- ========== RESERVATIONS & EXCEPTIONS ==========
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
  originating_request_id UUID,
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

-- ========== COMMUNICATION & NOTIFICATIONS ==========
CREATE TABLE IF NOT EXISTS notifications (
  id_notification UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  type VARCHAR(50),
  message VARCHAR(500),
  was_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS messages (
  id_message UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  receiver_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  message_content TEXT,
  is_read BOOLEAN DEFAULT false,
  sent_at TIMESTAMP DEFAULT now(),
  read_at TIMESTAMP
);

-- ========== CONTACTS ==========
CREATE TABLE IF NOT EXISTS contacts (
  id_contact UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- The user who owns this contact
  owner_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  -- The contact user
  contact_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  -- Display name override (optional)
  display_name_override TEXT NULL,
  -- Contact status: pending, accepted, blocked
  status TEXT NOT NULL DEFAULT 'pending',
  -- Optional notes about the contact
  notes TEXT NULL,
  -- Metadata (JSON for extensibility)
  metadata JSONB NULL,
  -- Timestamps
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  -- Prevent duplicate contacts
  UNIQUE (owner_user_id, contact_user_id),
  -- Prevent self-contact
  CHECK (owner_user_id <> contact_user_id)
);

CREATE INDEX IF NOT EXISTS idx_contacts_owner ON contacts (owner_user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_contact ON contacts (contact_user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_status ON contacts (status);

-- ========== VIDEO CALLS ==========
CREATE TABLE IF NOT EXISTS video_calls (
  id_video_call UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Unique call identifier (Agora channel name)
  channel_name TEXT NOT NULL,
  -- Optional friendly name for the call
  call_name TEXT NULL,
  -- Call type: 'video', 'audio', 'screen_share'
  call_type TEXT NOT NULL DEFAULT 'video',
  -- Optional associated room/group identifier (no FK here to keep schema_all_uuid standalone)
  group_room_id UUID NULL,
  -- User who initiated the call
  initiated_by_user_id UUID NULL REFERENCES users(id_user) ON DELETE SET NULL,
  -- Call status: 'active', 'ended', 'missed', 'declined'
  status TEXT NOT NULL DEFAULT 'active',
  -- Timestamps
  started_at TIMESTAMP DEFAULT now(),
  ended_at TIMESTAMP NULL,
  -- Calculated duration in seconds (updated when call ends)
  duration_seconds INTEGER NULL,
  -- Max concurrent participants during the call
  max_participants INTEGER NOT NULL DEFAULT 0,
  -- Recording info (if call was recorded)
  recording_url TEXT NULL,
  is_recorded BOOLEAN NOT NULL DEFAULT false,
  -- Metadata (Agora app settings, quality info, etc.)
  metadata JSONB NULL
);

CREATE INDEX IF NOT EXISTS idx_video_calls_channel ON video_calls (channel_name);
CREATE INDEX IF NOT EXISTS idx_video_calls_room ON video_calls (group_room_id);
CREATE INDEX IF NOT EXISTS idx_video_calls_initiator ON video_calls (initiated_by_user_id);
CREATE INDEX IF NOT EXISTS idx_video_calls_status ON video_calls (status);
CREATE INDEX IF NOT EXISTS idx_video_calls_started ON video_calls (started_at);

CREATE TABLE IF NOT EXISTS video_call_participants (
  id_video_call_participant UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- The call
  call_id UUID NOT NULL REFERENCES video_calls(id_video_call) ON DELETE CASCADE,
  -- The participant user
  user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  -- Participant role: 'host', 'co-host', 'participant'
  role TEXT NOT NULL DEFAULT 'participant',
  -- Join/leave times for this participant
  joined_at TIMESTAMP DEFAULT now(),
  left_at TIMESTAMP NULL,
  -- Duration this participant was in the call (seconds)
  duration_seconds INTEGER NULL,
  -- Connection quality metrics (optional)
  avg_video_quality TEXT NULL,
  avg_audio_quality TEXT NULL,
  -- Whether user had video/audio enabled
  had_video BOOLEAN NOT NULL DEFAULT true,
  had_audio BOOLEAN NOT NULL DEFAULT true,
  had_screen_share BOOLEAN NOT NULL DEFAULT false,
  -- Device/platform info
  device_type TEXT NULL,
  -- Metadata (connection stats, etc.)
  metadata JSONB NULL
);

CREATE INDEX IF NOT EXISTS idx_call_participants_call ON video_call_participants (call_id);
CREATE INDEX IF NOT EXISTS idx_call_participants_user ON video_call_participants (user_id);
CREATE INDEX IF NOT EXISTS idx_call_participants_joined ON video_call_participants (joined_at);

-- Views
CREATE OR REPLACE VIEW v_active_calls AS
SELECT 
  vc.id_video_call,
  vc.channel_name,
  vc.call_name,
  vc.call_type,
  vc.started_at,
  vc.initiated_by_user_id,
  u.display_name AS initiated_by_name,
  COUNT(vcp.id_video_call_participant) AS current_participants
FROM video_calls vc
LEFT JOIN users u ON vc.initiated_by_user_id = u.id_user
LEFT JOIN video_call_participants vcp 
  ON vc.id_video_call = vcp.call_id AND vcp.left_at IS NULL
WHERE vc.status = 'active'
GROUP BY vc.id_video_call, u.display_name;

CREATE OR REPLACE VIEW v_user_call_history AS
SELECT 
  vcp.user_id,
  vc.id_video_call AS call_id,
  vc.channel_name,
  vc.call_name,
  vc.call_type,
  vc.status AS call_status,
  vcp.role,
  vcp.joined_at,
  vcp.left_at,
  vcp.duration_seconds,
  vc.started_at AS call_started_at,
  vc.ended_at AS call_ended_at,
  vc.duration_seconds AS total_call_duration
FROM video_call_participants vcp
JOIN video_calls vc ON vcp.call_id = vc.id_video_call
ORDER BY vcp.joined_at DESC;

-- ========== PROFESSOR ROOMS ==========
CREATE TABLE IF NOT EXISTS professor_rooms (
  id_professor_room UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- The professor who owns this room
  professor_id UUID NOT NULL REFERENCES professors(id_professor) ON DELETE CASCADE,
  -- The professor's display name (denormalized for quick access)
  professor_name VARCHAR(255) NOT NULL,
  -- Unique room name for video calls (default: Professor_<username>)
  room_name VARCHAR(255) NOT NULL UNIQUE,
  -- Optional description of the room
  description TEXT NULL,
  -- Whether the room is active
  is_active BOOLEAN NOT NULL DEFAULT true,
  -- Timestamps
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  -- Ensure one room per professor
  UNIQUE (professor_id)
);

CREATE INDEX IF NOT EXISTS idx_professor_rooms_professor ON professor_rooms(professor_id);
CREATE INDEX IF NOT EXISTS idx_professor_rooms_room_name ON professor_rooms(room_name);
CREATE INDEX IF NOT EXISTS idx_professor_rooms_active ON professor_rooms(is_active);

CREATE OR REPLACE FUNCTION update_professor_rooms_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_professor_rooms_updated_at ON professor_rooms;
CREATE TRIGGER trigger_professor_rooms_updated_at
  BEFORE UPDATE ON professor_rooms
  FOR EACH ROW
  EXECUTE FUNCTION update_professor_rooms_updated_at();

INSERT INTO professor_rooms (professor_id, professor_name, room_name)
SELECT 
  p.id_professor,
  COALESCE(u.display_name, u.username, u.name),
  CONCAT('Professor_', COALESCE(u.username, p.id_professor::text))
FROM professors p
JOIN users u ON u.id_user = p.id_user
WHERE NOT EXISTS (
  SELECT 1 FROM professor_rooms pr WHERE pr.professor_id = p.id_professor
)
ON CONFLICT (professor_id) DO NOTHING;

-- ========== COMPLAINTS ==========
CREATE TABLE IF NOT EXISTS complaints (
  id_complaint UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  receiver_user_id UUID REFERENCES users(id_user),
  complaint_type VARCHAR(100),
  complaint_subject VARCHAR(160),
  complaint_message VARCHAR(1000),
  status VARCHAR(30),
  is_read BOOLEAN DEFAULT false,
  sender_display_name VARCHAR(160),
  receiver_display_name VARCHAR(160),
  sender_role VARCHAR(30),
  receiver_role VARCHAR(30),
  relationship_context VARCHAR(30),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS complaint_resolutions (
  id_complaint_resolution UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  complaint_id UUID NOT NULL REFERENCES complaints(id_complaint) ON DELETE CASCADE,
  admin_user_id UUID NOT NULL REFERENCES users(id_user),
  resolution_status VARCHAR(50),
  resolution_notes TEXT,
  resolved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- ========== API DATA (CALLS/WHITEBOARD/CHAT) ==========
CREATE TABLE IF NOT EXISTS calls_api_data (
  id_calls_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_name VARCHAR(255),
  project_name VARCHAR(255),
  app_id VARCHAR(255),
  primary_certificate VARCHAR(255),
  channel_token TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS whiteboard_api_data (
  id_whiteboard_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel_name VARCHAR(255),
  project_name VARCHAR(255),
  app_identifier VARCHAR(255),
  sdk_token TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chat_api_data (
  id_chat_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID REFERENCES users(id_user),
  chat_user_temp_token VARCHAR(255),
  chat_app_temp_token VARCHAR(255),
  appkey VARCHAR(255),
  orgname VARCHAR(255),
  appname VARCHAR(255),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS management_statuses (
  id_management_status UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  status_name VARCHAR(100),
  description TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS api_data (
  id_api_data UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  managed_by_user_id UUID REFERENCES users(id_user) ON DELETE SET NULL,
  id_professor UUID NOT NULL REFERENCES professors(id_professor) ON DELETE CASCADE,
  id_calls_api_data UUID REFERENCES calls_api_data(id_calls_api_data),
  id_whiteboard_api_data UUID REFERENCES whiteboard_api_data(id_whiteboard_api_data),
  id_chat_api_data UUID REFERENCES chat_api_data(id_chat_api_data),
  id_management_status UUID NOT NULL REFERENCES management_statuses(id_management_status),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- ========== WALLET & PAYMENTS ==========
CREATE TABLE IF NOT EXISTS wallets (
  id_wallet UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type VARCHAR(20),
  owner_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  balance NUMERIC(12,2) DEFAULT 0,
  hold_amount NUMERIC(12,2) DEFAULT 0,
  currency VARCHAR(10) DEFAULT 'EUR',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (owner_type, owner_user_id)
);

CREATE TABLE IF NOT EXISTS transactions (
  id_transaction UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES wallets(id_wallet) ON DELETE CASCADE,
  transaction_type VARCHAR(30),
  amount NUMERIC(12,2) NOT NULL,
  balance_before NUMERIC(12,2),
  balance_after NUMERIC(12,2),
  related_id UUID,
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS payment_methods (
  id_payment_method UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type VARCHAR(20),
  owner_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  method_type VARCHAR(30),
  masked_details VARCHAR(255),
  provider_token VARCHAR(255),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS payment_providers (
  id_payment_provider UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100),
  config_info VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS withdrawal_policies (
  id_withdrawal_policy UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_provider_id UUID REFERENCES payment_providers(id_payment_provider),
  min_amount NUMERIC(12,2),
  min_balance_after NUMERIC(12,2),
  fixed_fee NUMERIC(12,2),
  percent_fee NUMERIC(5,2),
  active BOOLEAN,
  effective_from TIMESTAMP,
  effective_to TIMESTAMP,
  note VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS topups (
  id_topup UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES wallets(id_wallet) ON DELETE CASCADE,
  payment_method_id UUID REFERENCES payment_methods(id_payment_method),
  amount NUMERIC(12,2) NOT NULL,
  provider_reference VARCHAR(255),
  topup_type VARCHAR(30),
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS refunds (
  id_refund UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES transactions(id_transaction) ON DELETE CASCADE,
  to_wallet_id UUID NOT NULL REFERENCES wallets(id_wallet) ON DELETE CASCADE,
  amount NUMERIC(12,2),
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS disputes (
  id_dispute UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES transactions(id_transaction) ON DELETE CASCADE,
  id_reservation UUID,
  reservation_payment_id UUID,
  topup_id UUID,
  raised_by_user_id UUID REFERENCES users(id_user),
  reporter_name VARCHAR(160),
  reporter_email VARCHAR(255),
  reporter_role VARCHAR(20),
  subject VARCHAR(160),
  reason TEXT,
  payment_reference TEXT,
  payment_source VARCHAR(40),
  status VARCHAR(20),
  resolution_note TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS commission_rules (
  id_commission_rule UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_professor UUID REFERENCES professors(id_professor) ON DELETE CASCADE,
  percent NUMERIC(5,2),
  fixed_fee NUMERIC(12,2),
  applies_to VARCHAR(20),
  effective_from TIMESTAMP,
  effective_to TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reservation_payments (
  id_reservation_payment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id UUID NOT NULL REFERENCES reservations(id_reservation) ON DELETE CASCADE,
  payer_wallet_id UUID NOT NULL REFERENCES wallets(id_wallet) ON DELETE CASCADE,
  transaction_id UUID REFERENCES transactions(id_transaction),
  commission_rule_id UUID REFERENCES commission_rules(id_commission_rule) ON DELETE SET NULL,
  amount NUMERIC(12,2),
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS withdrawal_requests (
  id_withdrawal_request UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES wallets(id_wallet) ON DELETE CASCADE,
  requested_amount NUMERIC(12,2),
  fee_amount NUMERIC(12,2),
  net_amount NUMERIC(12,2),
  payment_method_id UUID REFERENCES payment_methods(id_payment_method),
  payment_provider_id UUID REFERENCES payment_providers(id_payment_provider),
  withdrawal_policy_id UUID REFERENCES withdrawal_policies(id_withdrawal_policy),
  status VARCHAR(30),
  requested_at TIMESTAMP DEFAULT now(),
  processed_at TIMESTAMP,
  processed_by_user_id UUID REFERENCES users(id_user)
);

CREATE TABLE IF NOT EXISTS payouts (
  id_payout UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  withdrawal_request_id UUID REFERENCES withdrawal_requests(id_withdrawal_request) ON DELETE SET NULL,
  transaction_id UUID REFERENCES transactions(id_transaction) ON DELETE SET NULL,
  gross_amount NUMERIC(12,2),
  provider_fee_amount NUMERIC(12,2),
  platform_fee_amount NUMERIC(12,2),
  net_amount NUMERIC(12,2),
  status VARCHAR(20),
  processed_at TIMESTAMP
);
