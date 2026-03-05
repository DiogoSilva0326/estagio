CREATE OR REPLACE FUNCTION public.usp_reservations_select_all01()
RETURNS SETOF public.reservations
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.reservations
  ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservations_select_details01(
  p_id_reservation uuid
)
RETURNS SETOF public.reservations
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.reservations
  WHERE id_reservation = p_id_reservation;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservations_insert(
  p_id_user uuid,
  p_id_lesson uuid,
  p_id_lesson_schedule_block uuid,
  p_id_schedule_block uuid,
  p_id_block_part uuid,
  p_min_students_at_booking integer,
  p_start_time timestamp,
  p_end_time timestamp,
  p_status varchar(20)
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.reservations (
    id_user,
    id_lesson,
    id_lesson_schedule_block,
    id_schedule_block,
    id_block_part,
    min_students_at_booking,
    start_time,
    end_time,
    status
  )
  VALUES (
    p_id_user,
    p_id_lesson,
    p_id_lesson_schedule_block,
    p_id_schedule_block,
    p_id_block_part,
    p_min_students_at_booking,
    p_start_time,
    p_end_time,
    p_status
  )
  RETURNING id_reservation INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservations_update(
  p_id_reservation uuid,
  p_id_user uuid,
  p_id_lesson uuid,
  p_id_lesson_schedule_block uuid,
  p_id_schedule_block uuid,
  p_id_block_part uuid,
  p_min_students_at_booking integer,
  p_start_time timestamp,
  p_end_time timestamp,
  p_status varchar(20)
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.reservations
  SET id_user = p_id_user,
      id_lesson = p_id_lesson,
      id_lesson_schedule_block = p_id_lesson_schedule_block,
      id_schedule_block = p_id_schedule_block,
      id_block_part = p_id_block_part,
      min_students_at_booking = p_min_students_at_booking,
      start_time = p_start_time,
      end_time = p_end_time,
      status = p_status
  WHERE id_reservation = p_id_reservation;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_reservations_delete(
  p_id_reservation uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.reservations
  WHERE id_reservation = p_id_reservation;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
