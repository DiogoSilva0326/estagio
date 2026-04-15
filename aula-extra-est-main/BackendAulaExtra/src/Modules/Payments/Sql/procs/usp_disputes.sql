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
    p_id_reservation uuid,
    p_reservation_payment_id uuid,
    p_topup_id uuid,
    p_raised_by_user_id uuid,
    p_reporter_name varchar,
    p_reporter_email varchar,
    p_reporter_role varchar,
    p_subject varchar,
    p_reason text,
    p_payment_reference text,
    p_payment_source varchar,
    p_status varchar,
    p_resolution_note text,
    p_created_at timestamp,
    p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.disputes (
        transaction_id,
        id_reservation,
        reservation_payment_id,
        topup_id,
        raised_by_user_id,
        reporter_name,
        reporter_email,
        reporter_role,
        subject,
        reason,
        payment_reference,
        payment_source,
        status,
        resolution_note,
        created_at,
        updated_at)
    VALUES (
        p_transaction_id,
        p_id_reservation,
        p_reservation_payment_id,
        p_topup_id,
        p_raised_by_user_id,
        p_reporter_name,
        p_reporter_email,
        p_reporter_role,
        p_subject,
        p_reason,
        p_payment_reference,
        p_payment_source,
        p_status,
        p_resolution_note,
        COALESCE(p_created_at, now()),
        COALESCE(p_updated_at, now())
    )
    RETURNING id_dispute;
$$;

CREATE OR REPLACE FUNCTION public.usp_disputes_update(
    p_id_dispute uuid,
    p_transaction_id uuid,
    p_id_reservation uuid,
    p_reservation_payment_id uuid,
    p_topup_id uuid,
    p_raised_by_user_id uuid,
    p_reporter_name varchar,
    p_reporter_email varchar,
    p_reporter_role varchar,
    p_subject varchar,
    p_reason text,
    p_payment_reference text,
    p_payment_source varchar,
    p_status varchar,
    p_resolution_note text,
    p_created_at timestamp,
    p_updated_at timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.disputes
        SET transaction_id = p_transaction_id,
            id_reservation = p_id_reservation,
            reservation_payment_id = p_reservation_payment_id,
            topup_id = p_topup_id,
            raised_by_user_id = p_raised_by_user_id,
            reporter_name = p_reporter_name,
            reporter_email = p_reporter_email,
            reporter_role = p_reporter_role,
            subject = p_subject,
            reason = p_reason,
            payment_reference = p_payment_reference,
            payment_source = p_payment_source,
            status = p_status,
            resolution_note = p_resolution_note,
            created_at = p_created_at,
            updated_at = COALESCE(p_updated_at, now())
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
