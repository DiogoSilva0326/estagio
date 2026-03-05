CREATE OR REPLACE FUNCTION public.usp_professor_rooms_select_all01()
RETURNS SETOF public.professor_rooms
LANGUAGE sql
AS $$
    SELECT *
    FROM public.professor_rooms
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_rooms_select_details01(
    p_id uuid
)
RETURNS SETOF public.professor_rooms
LANGUAGE sql
AS $$
    SELECT *
    FROM public.professor_rooms
    WHERE id = p_id;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_rooms_insert(
    p_professor_id uuid,
    p_professor_name varchar,
    p_room_name varchar,
    p_description text,
    p_is_active boolean
)
RETURNS uuid
LANGUAGE sql
AS $$
    INSERT INTO public.professor_rooms (professor_id, professor_name, room_name, description, is_active)
    VALUES (p_professor_id, p_professor_name, p_room_name, p_description, p_is_active)
    RETURNING id;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_rooms_update(
    p_id uuid,
    p_professor_id uuid,
    p_professor_name varchar,
    p_room_name varchar,
    p_description text,
    p_is_active boolean
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH updated AS (
        UPDATE public.professor_rooms
        SET professor_id = p_professor_id,
            professor_name = p_professor_name,
            room_name = p_room_name,
            description = p_description,
            is_active = p_is_active
        WHERE id = p_id
        RETURNING 1
    )
    SELECT count(*)::int FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_professor_rooms_delete(
    p_id uuid
)
RETURNS integer
LANGUAGE sql
AS $$
    WITH deleted AS (
        DELETE FROM public.professor_rooms
        WHERE id = p_id
        RETURNING 1
    )
    SELECT count(*)::int FROM deleted;
$$;
