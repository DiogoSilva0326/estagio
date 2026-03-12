CREATE OR REPLACE FUNCTION public.usp_lesson_schedule_blocks_select_all01()
RETURNS SETOF public.lesson_schedule_blocks
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lesson_schedule_blocks;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_schedule_blocks_select_details01(
  p_id_lesson_schedule_block uuid
)
RETURNS SETOF public.lesson_schedule_blocks
LANGUAGE sql
AS $$
  SELECT *
  FROM public.lesson_schedule_blocks
  WHERE id_lesson_schedule_block = p_id_lesson_schedule_block;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_schedule_blocks_insert(
  p_id_lesson uuid,
  p_id_schedule_block uuid,
  p_id_block_part uuid,
  p_start_time timestamp,
  p_end_time timestamp
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.lesson_schedule_blocks (
    id_lesson,
    id_schedule_block,
    id_block_part,
    start_time,
    end_time
  )
  VALUES (
    p_id_lesson,
    p_id_schedule_block,
    p_id_block_part,
    p_start_time,
    p_end_time
  )
  RETURNING id_lesson_schedule_block;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_schedule_blocks_update(
  p_id_lesson_schedule_block uuid,
  p_id_lesson uuid,
  p_id_schedule_block uuid,
  p_id_block_part uuid,
  p_start_time timestamp,
  p_end_time timestamp
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.lesson_schedule_blocks
    SET id_lesson = p_id_lesson,
        id_schedule_block = p_id_schedule_block,
        id_block_part = p_id_block_part,
        start_time = p_start_time,
        end_time = p_end_time
    WHERE id_lesson_schedule_block = p_id_lesson_schedule_block
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

CREATE OR REPLACE FUNCTION public.usp_lesson_schedule_blocks_delete(
  p_id_lesson_schedule_block uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.lesson_schedule_blocks
    WHERE id_lesson_schedule_block = p_id_lesson_schedule_block
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
