-- Aula Extra platform schema (namespaced under aula_extra)
-- Kept separate from Confidant chat/calls tables (which live in public.*)

-- UUID support
CREATE EXTENSION IF NOT EXISTS pgcrypto;

---CREATE SCHEMA IF NOT EXISTS aula_extra;
SET search_path TO public;

-- ========== CORE ROLES & USERS ==========
-- CREATE TABLE IF NOT EXISTS roles (
--   id_role UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   name VARCHAR(50) NOT NULL,
--   description TEXT,
--   created_at TIMESTAMP DEFAULT now(),
--   updated_at TIMESTAMP DEFAULT now()
-- );

-- CREATE TABLE IF NOT EXISTS users (
--   id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),

--   -- Identidade básica
--   username TEXT NOT NULL UNIQUE,
--   display_name TEXT NULL,
--   name VARCHAR(150) NOT NULL,

--   -- Contato
--   email VARCHAR(255) UNIQUE,
--   cell_phone_number VARCHAR(50),

--   -- Autenticação
--   password_hash TEXT,

--   -- Status
--   email_verified BOOLEAN DEFAULT false,

--   -- Relacionamentos
--   id_role UUID NOT NULL REFERENCES roles(id_role),

--   -- Opcional: ligação ao utilizador do Confidant (public.users.id) sem acoplar os schemas
--   confidant_user_id BIGINT NULL,

--   -- Timestamps
--   created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
--   updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
-- );

-- ========== PROFESSOR & PROFILE ==========
CREATE TABLE IF NOT EXISTS professors (
  id_professor UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES public.users(id_user),
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
  id_user UUID NOT NULL REFERENCES public.users(id_user),
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
  verified_by_user_id UUID REFERENCES public.users(id_user),
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
  id_user UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
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
  id_user UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
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
  id_user UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
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
  id_user UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
  status VARCHAR(20),
  price_paid NUMERIC(10,2),
  created_at TIMESTAMP DEFAULT now()
);

-- ========== RESERVATIONS & EXCEPTIONS ==========
CREATE TABLE IF NOT EXISTS reservations (
  id_reservation UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
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
  id_user UUID REFERENCES public.users(id_user),
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
  id_user UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
  type VARCHAR(50),
  message VARCHAR(500),
  was_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS messages (
  id_message UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_user_id UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
  receiver_user_id UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
  message_content TEXT,
  is_read BOOLEAN DEFAULT false,
  sent_at TIMESTAMP DEFAULT now(),
  read_at TIMESTAMP
);

-- ========== COMPLAINTS ==========
CREATE TABLE IF NOT EXISTS complaints (
  id_complaint UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_user_id UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
  receiver_user_id UUID REFERENCES public.users(id_user),
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
  admin_user_id UUID NOT NULL REFERENCES public.users(id_user),
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
  id_user UUID REFERENCES public.users(id_user),
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
  managed_by_user_id UUID REFERENCES public.users(id_user) ON DELETE SET NULL,
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
  owner_user_id UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
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
  related_id INTEGER,
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS payment_methods (
  id_payment_method UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_type VARCHAR(20),
  owner_user_id UUID NOT NULL REFERENCES public.users(id_user) ON DELETE CASCADE,
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
  raised_by_user_id UUID REFERENCES public.users(id_user),
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
  processed_by_user_id UUID REFERENCES public.users(id_user)
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

RESET search_path;
