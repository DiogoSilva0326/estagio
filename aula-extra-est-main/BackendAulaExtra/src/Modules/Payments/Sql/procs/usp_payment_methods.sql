CREATE OR REPLACE FUNCTION public.usp_payment_methods_select_all01()
RETURNS SETOF public.payment_methods
LANGUAGE sql
AS $$
    SELECT *
    FROM public.payment_methods
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_methods_select_details01(
    p_id_payment_method uuid
)
RETURNS SETOF public.payment_methods
LANGUAGE sql
AS $$
    SELECT *
    FROM public.payment_methods
    WHERE id_payment_method = p_id_payment_method;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_methods_insert(
    p_owner_type varchar,
    p_owner_user_id uuid,
    p_method_type varchar,
    p_masked_details varchar,
    p_provider_token varchar,
    p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.payment_methods (owner_type, owner_user_id, method_type, masked_details, provider_token, created_at)
    VALUES (
        p_owner_type,
        p_owner_user_id,
        p_method_type,
        p_masked_details,
        p_provider_token,
        COALESCE(p_created_at, now())
    )
    RETURNING id_payment_method;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_methods_update(
    p_id_payment_method uuid,
    p_owner_type varchar,
    p_owner_user_id uuid,
    p_method_type varchar,
    p_masked_details varchar,
    p_provider_token varchar,
    p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.payment_methods
        SET owner_type = p_owner_type,
            owner_user_id = p_owner_user_id,
            method_type = p_method_type,
            masked_details = p_masked_details,
            provider_token = p_provider_token,
            created_at = p_created_at
        WHERE id_payment_method = p_id_payment_method
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_methods_delete(
    p_id_payment_method uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.payment_methods
        WHERE id_payment_method = p_id_payment_method
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
