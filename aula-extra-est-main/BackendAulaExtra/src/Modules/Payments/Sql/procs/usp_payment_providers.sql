CREATE OR REPLACE FUNCTION public.usp_payment_providers_select_all01()
RETURNS SETOF public.payment_providers
LANGUAGE sql
AS $$
    SELECT *
    FROM public.payment_providers
    ORDER BY name NULLS LAST;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_providers_select_details01(
    p_id_payment_provider uuid
)
RETURNS SETOF public.payment_providers
LANGUAGE sql
AS $$
    SELECT *
    FROM public.payment_providers
    WHERE id_payment_provider = p_id_payment_provider;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_providers_insert(
    p_name varchar,
    p_config_info varchar
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.payment_providers (name, config_info)
    VALUES (p_name, p_config_info)
    RETURNING id_payment_provider;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_providers_update(
    p_id_payment_provider uuid,
    p_name varchar,
    p_config_info varchar
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.payment_providers
        SET name = p_name,
            config_info = p_config_info
        WHERE id_payment_provider = p_id_payment_provider
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_payment_providers_delete(
    p_id_payment_provider uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.payment_providers
        WHERE id_payment_provider = p_id_payment_provider
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
