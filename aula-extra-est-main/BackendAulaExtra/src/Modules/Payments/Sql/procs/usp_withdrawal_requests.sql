CREATE OR REPLACE FUNCTION public.usp_withdrawal_requests_select_all01()
RETURNS SETOF public.withdrawal_requests
LANGUAGE sql
AS $$
    SELECT *
    FROM public.withdrawal_requests
    ORDER BY requested_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_requests_select_details01(
    p_id_withdrawal_request uuid
)
RETURNS SETOF public.withdrawal_requests
LANGUAGE sql
AS $$
    SELECT *
    FROM public.withdrawal_requests
    WHERE id_withdrawal_request = p_id_withdrawal_request;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_requests_insert(
    p_wallet_id uuid,
    p_requested_amount numeric,
    p_fee_amount numeric,
    p_net_amount numeric,
    p_payment_method_id uuid,
    p_payment_provider_id uuid,
    p_withdrawal_policy_id uuid,
    p_status varchar,
    p_requested_at timestamp,
    p_processed_at timestamp,
    p_processed_by_user_id uuid
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.withdrawal_requests (
        wallet_id, requested_amount, fee_amount, net_amount, payment_method_id, payment_provider_id, withdrawal_policy_id,
        status, requested_at, processed_at, processed_by_user_id
    )
    VALUES (
        p_wallet_id, p_requested_amount, p_fee_amount, p_net_amount, p_payment_method_id, p_payment_provider_id, p_withdrawal_policy_id,
        p_status, COALESCE(p_requested_at, now()), p_processed_at, p_processed_by_user_id
    )
    RETURNING id_withdrawal_request;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_requests_update(
    p_id_withdrawal_request uuid,
    p_wallet_id uuid,
    p_requested_amount numeric,
    p_fee_amount numeric,
    p_net_amount numeric,
    p_payment_method_id uuid,
    p_payment_provider_id uuid,
    p_withdrawal_policy_id uuid,
    p_status varchar,
    p_requested_at timestamp,
    p_processed_at timestamp,
    p_processed_by_user_id uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.withdrawal_requests
        SET wallet_id = p_wallet_id,
            requested_amount = p_requested_amount,
            fee_amount = p_fee_amount,
            net_amount = p_net_amount,
            payment_method_id = p_payment_method_id,
            payment_provider_id = p_payment_provider_id,
            withdrawal_policy_id = p_withdrawal_policy_id,
            status = p_status,
            requested_at = p_requested_at,
            processed_at = p_processed_at,
            processed_by_user_id = p_processed_by_user_id
        WHERE id_withdrawal_request = p_id_withdrawal_request
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_requests_delete(
    p_id_withdrawal_request uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.withdrawal_requests
        WHERE id_withdrawal_request = p_id_withdrawal_request
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
