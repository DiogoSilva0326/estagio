CREATE OR REPLACE FUNCTION public.usp_professors_select_all01()
RETURNS SETOF public.professors
LANGUAGE sql
AS $$
    SELECT *
    FROM public.professors
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_professors_select_details01(
    p_id_professor uuid
)
RETURNS SETOF public.professors
LANGUAGE sql
AS $$
    SELECT *
    FROM public.professors
    WHERE id_professor = p_id_professor;
$$;

CREATE OR REPLACE FUNCTION public.usp_professors_select_by_user01(
    p_id_user uuid
)
RETURNS SETOF public.professors
LANGUAGE sql
AS $$
    SELECT *
    FROM public.professors
    WHERE id_user = p_id_user;
$$;

CREATE OR REPLACE FUNCTION public.usp_professors_insert(
    p_id_user uuid,
    p_current_school varchar,
    p_years_experience integer,
    p_photo text,
    p_biography text,
    p_presentation_video_url text,
    p_vat varchar,
    p_iban varchar,
    p_iban_document_url text,
    p_is_verified_iban boolean,
    p_is_active boolean,
    p_is_verified boolean,
    p_is_rejected boolean,
    p_created_at timestamp,
    p_updated_at timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.professors (
        id_user, current_school, years_experience, photo, biography, presentation_video_url,
        vat, iban, iban_document_url,
        is_verified_iban, is_active, is_verified, is_rejected, created_at, updated_at
    )
    VALUES (
        p_id_user, p_current_school, p_years_experience, p_photo, p_biography, p_presentation_video_url,
        p_vat, p_iban, p_iban_document_url,
        COALESCE(p_is_verified_iban, false),
        COALESCE(p_is_active, true),
        COALESCE(p_is_verified, false),
        COALESCE(p_is_rejected, false),
        COALESCE(p_created_at, now()),
        COALESCE(p_updated_at, now())
    )
    RETURNING id_professor;
$$;

CREATE OR REPLACE FUNCTION public.usp_professors_update(
    p_id_professor uuid,
    p_id_user uuid,
    p_current_school varchar,
    p_years_experience integer,
    p_photo text,
    p_biography text,
    p_presentation_video_url text,
    p_vat varchar,
    p_iban varchar,
    p_iban_document_url text,
    p_is_verified_iban boolean,
    p_is_active boolean,
    p_is_verified boolean,
    p_is_rejected boolean
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.professors
        SET id_user = p_id_user,
            current_school = p_current_school,
            years_experience = p_years_experience,
            photo = p_photo,
            biography = p_biography,
            presentation_video_url = p_presentation_video_url,
            vat = p_vat,
            iban = p_iban,
            iban_document_url = p_iban_document_url,
            is_verified_iban = COALESCE(p_is_verified_iban, is_verified_iban),
            is_active = COALESCE(p_is_active, is_active),
            is_verified = COALESCE(p_is_verified, is_verified),
            is_rejected = COALESCE(p_is_rejected, is_rejected),
            updated_at = now()
        WHERE id_professor = p_id_professor
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;


CREATE OR REPLACE FUNCTION public.usp_professors_delete(
    p_id_professor uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.professors
        WHERE id_professor = p_id_professor
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
