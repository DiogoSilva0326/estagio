DROP FUNCTION IF EXISTS public.usp_users_update_roles(int, int[]);

CREATE OR REPLACE FUNCTION public.usp_users_update_roles(
    p_userid uuid,
    p_roleids int[]
)
RETURNS int
LANGUAGE plpgsql
AS $$
BEGIN
    -- Apaga todas as roles atuais
    DELETE FROM public.user_role WHERE user_id = p_userid;

    -- Insere apenas se houver elementos no array
    IF p_roleids IS NOT NULL AND array_length(p_roleids, 1) > 0 THEN
        INSERT INTO public.user_role (user_id, role_id)
        SELECT p_userid, rid
        FROM unnest(p_roleids) AS rid;
    END IF;

    RETURN 1;
END;
$$;
