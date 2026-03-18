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
  related_id INTEGER,
  related_entity_id UUID,
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now()
);

ALTER TABLE public.transactions ADD COLUMN IF NOT EXISTS related_entity_id UUID;

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
  transaction_id UUID NOT NULL REFERENCES transactions(id_transaction) ON DELETE CASCADE,
  id_reservation UUID,
  raised_by_user_id UUID REFERENCES users(id_user),
  reason TEXT,
  status VARCHAR(20),
  resolution_note TEXT,
  created_at TIMESTAMP DEFAULT now()
);

ALTER TABLE public.disputes ADD COLUMN IF NOT EXISTS id_reservation UUID;

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
  gross_amount NUMERIC(12,2),
  platform_fee_amount NUMERIC(12,2),
  teacher_net_amount NUMERIC(12,2),
  status VARCHAR(20),
  hold_release_at TIMESTAMPTZ,
  created_at TIMESTAMP DEFAULT now()
);

ALTER TABLE public.reservation_payments ADD COLUMN IF NOT EXISTS gross_amount NUMERIC(12,2);
ALTER TABLE public.reservation_payments ADD COLUMN IF NOT EXISTS platform_fee_amount NUMERIC(12,2);
ALTER TABLE public.reservation_payments ADD COLUMN IF NOT EXISTS teacher_net_amount NUMERIC(12,2);
ALTER TABLE public.reservation_payments ADD COLUMN IF NOT EXISTS hold_release_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS invoices (
  id_invoice UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_transaction UUID NOT NULL REFERENCES transactions(id_transaction) ON DELETE CASCADE,
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  invoice_type VARCHAR(50),
  document_reference VARCHAR(255),
  pdf_url TEXT,
  total_amount NUMERIC(12,2),
  tax_amount NUMERIC(12,2),
  issued_at TIMESTAMP DEFAULT now(),
  related_invoice_id UUID,
  at_status VARCHAR(50)
);

CREATE INDEX IF NOT EXISTS ix_invoices_transaction
  ON public.invoices (id_transaction);

CREATE INDEX IF NOT EXISTS ix_invoices_user
  ON public.invoices (id_user);

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