CREATE OR REPLACE FUNCTION public.usp_contact_form_categories_select_all01()
RETURNS TABLE (
    id_contact_form_category UUID,
    name TEXT,
    description TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
AS $$
    SELECT
        c.id_contact_form_category,
        c.name,
        c.description,
        c.created_at,
        c.updated_at
    FROM public.contact_form_categories c
    ORDER BY c.name ASC;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_categories_select_details01(
    p_id_contact_form_category UUID
)
RETURNS TABLE (
    id_contact_form_category UUID,
    name TEXT,
    description TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE sql
AS $$
    SELECT
        c.id_contact_form_category,
        c.name,
        c.description,
        c.created_at,
        c.updated_at
    FROM public.contact_form_categories c
    WHERE c.id_contact_form_category = p_id_contact_form_category
    LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_categories_insert(
    p_name TEXT,
    p_description TEXT DEFAULT NULL,
    p_created_at TIMESTAMPTZ DEFAULT NULL,
    p_updated_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS UUID
LANGUAGE sql
AS $$
    INSERT INTO public.contact_form_categories (
        name,
        description,
        created_at,
        updated_at
    )
    VALUES (
        btrim(p_name),
        NULLIF(btrim(COALESCE(p_description, '')), ''),
        COALESCE(p_created_at, now()),
        COALESCE(p_updated_at, now())
    )
    RETURNING id_contact_form_category;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_categories_update(
    p_id_contact_form_category UUID,
    p_name TEXT,
    p_description TEXT DEFAULT NULL,
    p_updated_at TIMESTAMPTZ DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INTEGER;
BEGIN
    UPDATE public.contact_form_categories
    SET
        name = btrim(p_name),
        description = NULLIF(btrim(COALESCE(p_description, '')), ''),
        updated_at = COALESCE(p_updated_at, now())
    WHERE id_contact_form_category = p_id_contact_form_category;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_contact_form_categories_delete(
    p_id_contact_form_category UUID
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INTEGER;
BEGIN
    DELETE FROM public.contact_form_categories
    WHERE id_contact_form_category = p_id_contact_form_category;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$$;
