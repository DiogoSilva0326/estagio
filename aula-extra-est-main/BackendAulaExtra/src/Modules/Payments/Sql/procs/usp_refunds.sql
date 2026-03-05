CREATE OR REPLACE FUNCTION public.usp_refunds_select_all01()
RETURNS SETOF public.refunds
LANGUAGE sql
AS $$
    SELECT *
    FROM public.refunds
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_refunds_select_details01(
    p_id_refund uuid
)
RETURNS SETOF public.refunds
LANGUAGE sql
AS $$
    SELECT *
    FROM public.refunds
    WHERE id_refund = p_id_refund;
$$;

CREATE OR REPLACE FUNCTION public.usp_refunds_insert(
    p_transaction_id uuid,
    p_to_wallet_id uuid,
    p_amount numeric,
    p_status varchar,
    p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.refunds (transaction_id, to_wallet_id, amount, status, created_at)
    VALUES (
        p_transaction_id,
        p_to_wallet_id,
        p_amount,
        p_status,
        COALESCE(p_created_at, now())
    )
    RETURNING id_refund;
$$;

CREATE OR REPLACE FUNCTION public.usp_refunds_update(
    p_id_refund uuid,
    p_transaction_id uuid,
    p_to_wallet_id uuid,
    p_amount numeric,
    p_status varchar,
    p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.refunds
        SET transaction_id = p_transaction_id,
            to_wallet_id = p_to_wallet_id,
            amount = p_amount,
            status = p_status,
            created_at = p_created_at
        WHERE id_refund = p_id_refund
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_refunds_delete(
    p_id_refund uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.refunds
        WHERE id_refund = p_id_refund
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
