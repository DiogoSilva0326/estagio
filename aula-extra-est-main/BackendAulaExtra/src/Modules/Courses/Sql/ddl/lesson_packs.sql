CREATE TABLE IF NOT EXISTS lesson_packs (
  id_lesson_pack UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_course UUID NOT NULL REFERENCES courses(id_course) ON DELETE CASCADE,
  name VARCHAR(200),
  number_of_lessons INTEGER NOT NULL,
  session_duration_minutes INTEGER,
  total_price NUMERIC(12,2),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_lesson_packs (
  id_user_lesson_pack UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  id_lesson_pack UUID NOT NULL REFERENCES lesson_packs(id_lesson_pack) ON DELETE CASCADE,
  remaining_count INTEGER,
  status VARCHAR(30),
  purchased_at TIMESTAMP DEFAULT now(),
  expires_at TIMESTAMPTZ
);

-- Ensure reservations can optionally reference a purchased pack.
ALTER TABLE public.reservations
  ADD COLUMN IF NOT EXISTS id_user_lesson_pack UUID;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_reservations_user_lesson_pack'
  ) THEN
    ALTER TABLE public.reservations
      ADD CONSTRAINT fk_reservations_user_lesson_pack
      FOREIGN KEY (id_user_lesson_pack)
      REFERENCES public.user_lesson_packs(id_user_lesson_pack)
      ON DELETE SET NULL;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS pack_transactions (
  id_pack_transaction UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user_lesson_pack UUID NOT NULL REFERENCES user_lesson_packs(id_user_lesson_pack) ON DELETE CASCADE,
  id_reservation UUID REFERENCES reservations(id_reservation) ON DELETE SET NULL,
  transaction_type VARCHAR(50),
  value_change INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_pack_transactions_user_lesson_pack
  ON public.pack_transactions (id_user_lesson_pack);
