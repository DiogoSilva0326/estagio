CREATE OR REPLACE FUNCTION public.usp_wallets_select_all01()
RETURNS SETOF public.wallets
LANGUAGE sql
AS $$
    SELECT *
    FROM public.wallets
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_wallets_select_details01(
    p_id_wallet uuid
)
RETURNS SETOF public.wallets
LANGUAGE sql
AS $$
    SELECT *
    FROM public.wallets
    WHERE id_wallet = p_id_wallet;
$$;

CREATE OR REPLACE FUNCTION public.usp_wallets_insert(
    p_owner_type varchar,
    p_owner_user_id uuid,
    p_balance numeric,
    p_hold_amount numeric,
    p_currency varchar,
    p_created_at timestamp,
    p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.wallets (owner_type, owner_user_id, balance, hold_amount, currency, created_at, updated_at)
    VALUES (
        p_owner_type,
        p_owner_user_id,
        COALESCE(p_balance, 0),
        COALESCE(p_hold_amount, 0),
        COALESCE(p_currency, 'EUR'),
        COALESCE(p_created_at, now()),
        COALESCE(p_updated_at, now())
    )
    RETURNING id_wallet;
$$;

CREATE OR REPLACE FUNCTION public.usp_wallets_update(
    p_id_wallet uuid,
    p_owner_type varchar,
    p_owner_user_id uuid,
    p_balance numeric,
    p_hold_amount numeric,
    p_currency varchar
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.wallets
        SET owner_type = p_owner_type,
            owner_user_id = p_owner_user_id,
            balance = p_balance,
            hold_amount = p_hold_amount,
            currency = p_currency,
            updated_at = now()
        WHERE id_wallet = p_id_wallet
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_wallets_delete(
    p_id_wallet uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.wallets
        WHERE id_wallet = p_id_wallet
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
