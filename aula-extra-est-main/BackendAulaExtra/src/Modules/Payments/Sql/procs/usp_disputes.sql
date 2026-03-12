CREATE OR REPLACE FUNCTION public.usp_disputes_select_all01()
RETURNS SETOF public.disputes
LANGUAGE sql
AS $$
    SELECT *
    FROM public.disputes
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_disputes_select_details01(
    p_id_dispute uuid
)
RETURNS SETOF public.disputes
LANGUAGE sql
AS $$
    SELECT *
    FROM public.disputes
    WHERE id_dispute = p_id_dispute;
$$;

CREATE OR REPLACE FUNCTION public.usp_disputes_insert(
    p_transaction_id uuid,
    p_raised_by_user_id uuid,
    p_reason text,
    p_status varchar,
    p_resolution_note text,
    p_created_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.disputes (transaction_id, raised_by_user_id, reason, status, resolution_note, created_at)
    VALUES (
        p_transaction_id,
        p_raised_by_user_id,
        p_reason,
        p_status,
        p_resolution_note,
        COALESCE(p_created_at, now())
    )
    RETURNING id_dispute;
$$;

CREATE OR REPLACE FUNCTION public.usp_disputes_update(
    p_id_dispute uuid,
    p_transaction_id uuid,
    p_raised_by_user_id uuid,
    p_reason text,
    p_status varchar,
    p_resolution_note text,
    p_created_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.disputes
        SET transaction_id = p_transaction_id,
            raised_by_user_id = p_raised_by_user_id,
            reason = p_reason,
            status = p_status,
            resolution_note = p_resolution_note,
            created_at = p_created_at
        WHERE id_dispute = p_id_dispute
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_disputes_delete(
    p_id_dispute uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.disputes
        WHERE id_dispute = p_id_dispute
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
