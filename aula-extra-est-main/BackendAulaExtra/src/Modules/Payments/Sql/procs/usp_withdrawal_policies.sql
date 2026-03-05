CREATE OR REPLACE FUNCTION public.usp_withdrawal_policies_select_all01()
RETURNS SETOF public.withdrawal_policies
LANGUAGE sql
AS $$
    SELECT *
    FROM public.withdrawal_policies
    ORDER BY effective_from DESC NULLS LAST;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_policies_select_details01(
    p_id_withdrawal_policy uuid
)
RETURNS SETOF public.withdrawal_policies
LANGUAGE sql
AS $$
    SELECT *
    FROM public.withdrawal_policies
    WHERE id_withdrawal_policy = p_id_withdrawal_policy;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_policies_insert(
    p_payment_provider_id uuid,
    p_min_amount numeric,
    p_min_balance_after numeric,
    p_fixed_fee numeric,
    p_percent_fee numeric,
    p_active boolean,
    p_effective_from timestamp,
    p_effective_to timestamp,
    p_note varchar
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.withdrawal_policies (
        payment_provider_id, min_amount, min_balance_after, fixed_fee, percent_fee,
        active, effective_from, effective_to, note
    )
    VALUES (
        p_payment_provider_id, p_min_amount, p_min_balance_after, p_fixed_fee, p_percent_fee,
        p_active, p_effective_from, p_effective_to, p_note
    )
    RETURNING id_withdrawal_policy;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_policies_update(
    p_id_withdrawal_policy uuid,
    p_payment_provider_id uuid,
    p_min_amount numeric,
    p_min_balance_after numeric,
    p_fixed_fee numeric,
    p_percent_fee numeric,
    p_active boolean,
    p_effective_from timestamp,
    p_effective_to timestamp,
    p_note varchar
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.withdrawal_policies
        SET payment_provider_id = p_payment_provider_id,
            min_amount = p_min_amount,
            min_balance_after = p_min_balance_after,
            fixed_fee = p_fixed_fee,
            percent_fee = p_percent_fee,
            active = p_active,
            effective_from = p_effective_from,
            effective_to = p_effective_to,
            note = p_note
        WHERE id_withdrawal_policy = p_id_withdrawal_policy
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_withdrawal_policies_delete(
    p_id_withdrawal_policy uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.withdrawal_policies
        WHERE id_withdrawal_policy = p_id_withdrawal_policy
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
