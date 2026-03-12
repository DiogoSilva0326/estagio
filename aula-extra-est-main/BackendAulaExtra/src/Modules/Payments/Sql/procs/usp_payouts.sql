CREATE OR REPLACE FUNCTION public.usp_payouts_select_all01()
RETURNS SETOF public.payouts
LANGUAGE sql
AS $$
    SELECT *
    FROM public.payouts
    ORDER BY processed_at DESC NULLS LAST;
$$;

CREATE OR REPLACE FUNCTION public.usp_payouts_select_details01(
    p_id_payout uuid
)
RETURNS SETOF public.payouts
LANGUAGE sql
AS $$
    SELECT *
    FROM public.payouts
    WHERE id_payout = p_id_payout;
$$;

CREATE OR REPLACE FUNCTION public.usp_payouts_insert(
    p_withdrawal_request_id uuid,
    p_transaction_id uuid,
    p_gross_amount numeric,
    p_provider_fee_amount numeric,
    p_platform_fee_amount numeric,
    p_net_amount numeric,
    p_status varchar,
    p_processed_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.payouts (
        withdrawal_request_id, transaction_id, gross_amount, provider_fee_amount, platform_fee_amount, net_amount, status, processed_at
    )
    VALUES (
        p_withdrawal_request_id, p_transaction_id, p_gross_amount, p_provider_fee_amount, p_platform_fee_amount, p_net_amount, p_status, p_processed_at
    )
    RETURNING id_payout;
$$;

CREATE OR REPLACE FUNCTION public.usp_payouts_update(
    p_id_payout uuid,
    p_withdrawal_request_id uuid,
    p_transaction_id uuid,
    p_gross_amount numeric,
    p_provider_fee_amount numeric,
    p_platform_fee_amount numeric,
    p_net_amount numeric,
    p_status varchar,
    p_processed_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.payouts
        SET withdrawal_request_id = p_withdrawal_request_id,
            transaction_id = p_transaction_id,
            gross_amount = p_gross_amount,
            provider_fee_amount = p_provider_fee_amount,
            platform_fee_amount = p_platform_fee_amount,
            net_amount = p_net_amount,
            status = p_status,
            processed_at = p_processed_at
        WHERE id_payout = p_id_payout
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_payouts_delete(
    p_id_payout uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.payouts
        WHERE id_payout = p_id_payout
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
