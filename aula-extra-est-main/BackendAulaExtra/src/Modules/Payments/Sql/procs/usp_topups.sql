CREATE OR REPLACE FUNCTION public.usp_topups_select_all01()
RETURNS SETOF public.topups
LANGUAGE sql
AS $$
    SELECT *
    FROM public.topups
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_topups_select_details01(
    p_id_topup uuid
)
RETURNS SETOF public.topups
LANGUAGE sql
AS $$
    SELECT *
    FROM public.topups
    WHERE id_topup = p_id_topup;
$$;

CREATE OR REPLACE FUNCTION public.usp_topups_insert(
    p_wallet_id uuid,
    p_payment_method_id uuid,
    p_amount numeric,
    p_provider_reference varchar,
    p_topup_type varchar,
    p_status varchar,
    p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.topups (wallet_id, payment_method_id, amount, provider_reference, topup_type, status, created_at)
    VALUES (
        p_wallet_id,
        p_payment_method_id,
        p_amount,
        p_provider_reference,
        p_topup_type,
        p_status,
        COALESCE(p_created_at, now())
    )
    RETURNING id_topup;
$$;

CREATE OR REPLACE FUNCTION public.usp_topups_update(
    p_id_topup uuid,
    p_wallet_id uuid,
    p_payment_method_id uuid,
    p_amount numeric,
    p_provider_reference varchar,
    p_topup_type varchar,
    p_status varchar,
    p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.topups
        SET wallet_id = p_wallet_id,
            payment_method_id = p_payment_method_id,
            amount = p_amount,
            provider_reference = p_provider_reference,
            topup_type = p_topup_type,
            status = p_status,
            created_at = p_created_at
        WHERE id_topup = p_id_topup
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_topups_delete(
    p_id_topup uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.topups
        WHERE id_topup = p_id_topup
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
