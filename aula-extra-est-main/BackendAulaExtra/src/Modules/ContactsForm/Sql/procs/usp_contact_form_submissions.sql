CREATE OR REPLACE FUNCTION public.usp_contact_form_submissions_select_all01(
    p_status TEXT DEFAULT NULL
)
RETURNS TABLE (
    id_contact_form_submission UUID,
    id_contact_form_category UUID,
    name TEXT,
    email TEXT,
    subject TEXT,
    message TEXT,
    status TEXT,
    user_id UUID,
    user_id_response UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    category_name TEXT,
    response_user_display_name TEXT
)
LANGUAGE sql
AS $$
    SELECT
        s.id_contact_form_submission,
        s.id_contact_form_category,
        s.name,
        s.email,
        s.subject,
        s.message,
        s.status,
        s.user_id,
        s.user_id_response,
        s.created_at,
        s.updated_at,
        c.name AS category_name,
        responder.display_name AS response_user_display_name
    FROM public.contact_form_submissions s
    LEFT JOIN public.contact_form_categories c ON c.id_contact_form_category = s.id_contact_form_category
    LEFT JOIN public.users responder ON responder.id_user = s.user_id_response
    WHERE (
        COALESCE(btrim(p_status), '') = ''
        OR LOWER(s.status) = LOWER(btrim(p_status))
    )
    ORDER BY s.created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_submissions_select_details01(
    p_id_contact_form_submission UUID
)
RETURNS TABLE (
    id_contact_form_submission UUID,
    id_contact_form_category UUID,
    name TEXT,
    email TEXT,
    subject TEXT,
    message TEXT,
    status TEXT,
    user_id UUID,
    user_id_response UUID,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    category_name TEXT,
    response_user_display_name TEXT
)
LANGUAGE sql
AS $$
    SELECT
        s.id_contact_form_submission,
        s.id_contact_form_category,
        s.name,
        s.email,
        s.subject,
        s.message,
        s.status,
        s.user_id,
        s.user_id_response,
        s.created_at,
        s.updated_at,
        c.name AS category_name,
        responder.display_name AS response_user_display_name
    FROM public.contact_form_submissions s
    LEFT JOIN public.contact_form_categories c ON c.id_contact_form_category = s.id_contact_form_category
    LEFT JOIN public.users responder ON responder.id_user = s.user_id_response
    WHERE s.id_contact_form_submission = p_id_contact_form_submission
    LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_submissions_insert(
    p_id_contact_form_category UUID DEFAULT NULL,
    p_name TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_subject TEXT DEFAULT NULL,
    p_message TEXT DEFAULT NULL,
    p_status TEXT DEFAULT 'não lida',
    p_user_id UUID DEFAULT NULL,
    p_user_id_response UUID DEFAULT NULL,
    p_created_at TIMESTAMPTZ DEFAULT NULL,
    p_updated_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID
LANGUAGE sql
AS $$
    INSERT INTO public.contact_form_submissions (
        id_contact_form_category,
        name,
        email,
        subject,
        message,
        status,
        user_id,
        user_id_response,
        created_at,
        updated_at
    )
    VALUES (
        p_id_contact_form_category,
        btrim(COALESCE(p_name, '')),
        btrim(COALESCE(p_email, '')),
        btrim(COALESCE(p_subject, '')),
        btrim(COALESCE(p_message, '')),
        COALESCE(NULLIF(btrim(COALESCE(p_status, '')), ''), 'não lida'),
        p_user_id,
        p_user_id_response,
        COALESCE(p_created_at, now()),
        COALESCE(p_updated_at, now())
    )
    RETURNING id_contact_form_submission;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_submissions_update(
    p_id_contact_form_submission UUID,
    p_id_contact_form_category UUID DEFAULT NULL,
    p_name TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_subject TEXT DEFAULT NULL,
    p_message TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_user_id_response UUID DEFAULT NULL,
    p_updated_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INTEGER;
BEGIN
    UPDATE public.contact_form_submissions
    SET
        id_contact_form_category = p_id_contact_form_category,
        name = btrim(COALESCE(p_name, '')),
        email = btrim(COALESCE(p_email, '')),
        subject = btrim(COALESCE(p_subject, '')),
        message = btrim(COALESCE(p_message, '')),
        status = COALESCE(NULLIF(btrim(COALESCE(p_status, '')), ''), 'não lida'),
        user_id = p_user_id,
        user_id_response = p_user_id_response,
        updated_at = COALESCE(p_updated_at, now())
    WHERE id_contact_form_submission = p_id_contact_form_submission;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_submissions_delete(
    p_id_contact_form_submission UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INTEGER;
BEGIN
    DELETE FROM public.contact_form_submissions
    WHERE id_contact_form_submission = p_id_contact_form_submission;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$$;
