CREATE OR REPLACE FUNCTION public.usp_commission_rules_select_all01()
RETURNS SETOF public.commission_rules
LANGUAGE sql
AS $$
    SELECT *
    FROM public.commission_rules
    ORDER BY effective_from DESC NULLS LAST;
$$;

CREATE OR REPLACE FUNCTION public.usp_commission_rules_select_details01(
    p_id_commission_rule uuid
)
RETURNS SETOF public.commission_rules
LANGUAGE sql
AS $$
    SELECT *
    FROM public.commission_rules
    WHERE id_commission_rule = p_id_commission_rule;
$$;

CREATE OR REPLACE FUNCTION public.usp_commission_rules_insert(
    p_id_professor uuid,
    p_percent numeric,
    p_fixed_fee numeric,
    p_applies_to varchar,
    p_effective_from timestamp,
    p_effective_to timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.commission_rules (id_professor, percent, fixed_fee, applies_to, effective_from, effective_to)
    VALUES (p_id_professor, p_percent, p_fixed_fee, p_applies_to, p_effective_from, p_effective_to)
    RETURNING id_commission_rule;
$$;

CREATE OR REPLACE FUNCTION public.usp_commission_rules_update(
    p_id_commission_rule uuid,
    p_id_professor uuid,
    p_percent numeric,
    p_fixed_fee numeric,
    p_applies_to varchar,
    p_effective_from timestamp,
    p_effective_to timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.commission_rules
        SET id_professor = p_id_professor,
            percent = p_percent,
            fixed_fee = p_fixed_fee,
            applies_to = p_applies_to,
            effective_from = p_effective_from,
            effective_to = p_effective_to
        WHERE id_commission_rule = p_id_commission_rule
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_commission_rules_delete(
    p_id_commission_rule uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.commission_rules
        WHERE id_commission_rule = p_id_commission_rule
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
