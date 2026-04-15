CREATE OR REPLACE FUNCTION public.usp_faq_select_public01(
    p_id_faq_category UUID DEFAULT NULL,
    p_query TEXT DEFAULT NULL
)
RETURNS TABLE (
    id_faq UUID,
    id_faq_category UUID,
    question TEXT,
    description TEXT,
    category VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    user_id UUID
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id_faq,
        f.id_faq_category,
        f.question,
        f.description,
        c.name AS category,
        f.created_at,
        f.updated_at,
        f.user_id
    FROM public.faqs f
    JOIN public.faq_categories c ON c.id_faq_category = f.id_faq_category
    WHERE (
        p_id_faq_category IS NULL
        OR f.id_faq_category = p_id_faq_category
    )
    AND (
        p_query IS NULL
        OR btrim(p_query) = ''
        OR LOWER(f.question) LIKE '%' || LOWER(btrim(p_query)) || '%'
        OR LOWER(COALESCE(f.description, '')) LIKE '%' || LOWER(btrim(p_query)) || '%'
    )
    ORDER BY c.name ASC, f.created_at ASC, f.question ASC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_faq_categories_select_public01()
RETURNS TABLE (
    id_faq_category UUID,
    category VARCHAR,
    description TEXT,
    faq_count INTEGER
)
LANGUAGE sql
AS $$
    SELECT
        c.id_faq_category,
        c.name AS category,
        c.description,
        COUNT(f.id_faq)::INT AS faq_count
    FROM public.faq_categories c
    LEFT JOIN public.faqs f ON f.id_faq_category = c.id_faq_category
    GROUP BY c.id_faq_category, c.name, c.description
    ORDER BY c.name ASC;
$$;
