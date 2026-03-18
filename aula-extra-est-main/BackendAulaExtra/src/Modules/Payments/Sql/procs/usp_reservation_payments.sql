CREATE OR REPLACE FUNCTION public.usp_reservation_payments_select_all01()
RETURNS SETOF public.reservation_payments
LANGUAGE sql
AS $$
    SELECT *
    FROM public.reservation_payments
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservation_payments_select_details01(
    p_id_reservation_payment uuid
)
RETURNS SETOF public.reservation_payments
LANGUAGE sql
AS $$
    SELECT *
    FROM public.reservation_payments
    WHERE id_reservation_payment = p_id_reservation_payment;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservation_payments_insert(
    p_reservation_id uuid,
    p_payer_wallet_id uuid,
    p_transaction_id uuid,
    p_commission_rule_id uuid,
    p_amount numeric,
    p_gross_amount numeric,
    p_platform_fee_amount numeric,
    p_teacher_net_amount numeric,
    p_status varchar,
    p_hold_release_at timestamp,
    p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.reservation_payments (
        reservation_id, payer_wallet_id, transaction_id, commission_rule_id, amount, gross_amount, platform_fee_amount, teacher_net_amount, status, hold_release_at, created_at
    )
    VALUES (
        p_reservation_id, p_payer_wallet_id, p_transaction_id, p_commission_rule_id, p_amount, p_gross_amount, p_platform_fee_amount, p_teacher_net_amount, p_status, p_hold_release_at, COALESCE(p_created_at, now())
    )
    RETURNING id_reservation_payment;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservation_payments_update(
    p_id_reservation_payment uuid,
    p_reservation_id uuid,
    p_payer_wallet_id uuid,
    p_transaction_id uuid,
    p_commission_rule_id uuid,
    p_amount numeric,
    p_gross_amount numeric,
    p_platform_fee_amount numeric,
    p_teacher_net_amount numeric,
    p_status varchar,
    p_hold_release_at timestamp,
    p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.reservation_payments
        SET reservation_id = p_reservation_id,
            payer_wallet_id = p_payer_wallet_id,
            transaction_id = p_transaction_id,
            commission_rule_id = p_commission_rule_id,
            amount = p_amount,
            gross_amount = p_gross_amount,
            platform_fee_amount = p_platform_fee_amount,
            teacher_net_amount = p_teacher_net_amount,
            status = p_status,
            hold_release_at = p_hold_release_at,
            created_at = p_created_at
        WHERE id_reservation_payment = p_id_reservation_payment
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservation_payments_delete(
    p_id_reservation_payment uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.reservation_payments
        WHERE id_reservation_payment = p_id_reservation_payment
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
