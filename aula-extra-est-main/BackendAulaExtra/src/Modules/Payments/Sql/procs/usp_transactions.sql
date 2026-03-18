CREATE OR REPLACE FUNCTION public.usp_transactions_select_all01()
RETURNS SETOF public.transactions
LANGUAGE sql
AS $$
    SELECT *
    FROM public.transactions
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_transactions_select_details01(
    p_id_transaction uuid
)
RETURNS SETOF public.transactions
LANGUAGE sql
AS $$
    SELECT *
    FROM public.transactions
    WHERE id_transaction = p_id_transaction;
$$;

CREATE OR REPLACE FUNCTION public.usp_transactions_insert(
    p_wallet_id uuid,
    p_transaction_type varchar,
    p_amount numeric,
    p_balance_before numeric,
    p_balance_after numeric,
    p_related_id integer,
    p_related_entity_id uuid,
    p_status varchar,
    p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.transactions (wallet_id, transaction_type, amount, balance_before, balance_after, related_id, related_entity_id, status, created_at)
    VALUES (
        p_wallet_id,
        p_transaction_type,
        p_amount,
        p_balance_before,
        p_balance_after,
        p_related_id,
        p_related_entity_id,
        p_status,
        COALESCE(p_created_at, now())
    )
    RETURNING id_transaction;
$$;

CREATE OR REPLACE FUNCTION public.usp_transactions_update(
    p_id_transaction uuid,
    p_wallet_id uuid,
    p_transaction_type varchar,
    p_amount numeric,
    p_balance_before numeric,
    p_balance_after numeric,
    p_related_id integer,
    p_related_entity_id uuid,
    p_status varchar,
    p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.transactions
        SET wallet_id = p_wallet_id,
            transaction_type = p_transaction_type,
            amount = p_amount,
            balance_before = p_balance_before,
            balance_after = p_balance_after,
            related_id = p_related_id,
            related_entity_id = p_related_entity_id,
            status = p_status,
            created_at = p_created_at
        WHERE id_transaction = p_id_transaction
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_transactions_delete(
    p_id_transaction uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.transactions
        WHERE id_transaction = p_id_transaction
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
