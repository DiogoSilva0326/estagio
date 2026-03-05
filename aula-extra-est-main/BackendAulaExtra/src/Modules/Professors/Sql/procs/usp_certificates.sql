CREATE OR REPLACE FUNCTION public.usp_certificates_select_all01()
RETURNS SETOF public.certificates
LANGUAGE sql
AS $$
    SELECT *
    FROM public.certificates
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_certificates_select_details01(
    p_id_certificate uuid
)
RETURNS SETOF public.certificates
LANGUAGE sql
AS $$
    SELECT *
    FROM public.certificates
    WHERE id_certificate = p_id_certificate;
$$;

CREATE OR REPLACE FUNCTION public.usp_certificates_insert(
    p_id_professor uuid,
    p_name varchar,
    p_file_url text,
    p_verified boolean,
    p_verified_by_user_id uuid,
    p_created_at timestamp,
    p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.certificates (id_professor, name, file_url, verified, verified_by_user_id, created_at, updated_at)
    VALUES (
        p_id_professor,
        p_name,
        p_file_url,
        COALESCE(p_verified, false),
        p_verified_by_user_id,
        COALESCE(p_created_at, now()),
        COALESCE(p_updated_at, now())
    )
    RETURNING id_certificate;
$$;

CREATE OR REPLACE FUNCTION public.usp_certificates_update(
    p_id_certificate uuid,
    p_id_professor uuid,
    p_name varchar,
    p_file_url text,
    p_verified boolean,
    p_verified_by_user_id uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.certificates
        SET id_professor = p_id_professor,
            name = p_name,
            file_url = p_file_url,
            verified = COALESCE(p_verified, verified),
            verified_by_user_id = p_verified_by_user_id,
            updated_at = now()
        WHERE id_certificate = p_id_certificate
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_certificates_delete(
    p_id_certificate uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.certificates
        WHERE id_certificate = p_id_certificate
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
