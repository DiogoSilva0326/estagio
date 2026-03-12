-- Insert UserProfile
CREATE OR REPLACE FUNCTION public.usp_userprofiles_insert(
    p_user_id UUID,
    p_total_spent DECIMAL(18,2) DEFAULT 0,
    p_prefered_language VARCHAR(10) DEFAULT 'pt-PT',
    p_status VARCHAR(50) DEFAULT 'active',
    p_phone VARCHAR(20) DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
BEGIN
    -- Check if profile already exists
    SELECT id INTO v_id
    FROM public.userprofiles
    WHERE user_id = p_user_id;
    
    IF v_id IS NOT NULL THEN
        -- Profile already exists, return existing ID
        RETURN v_id;
    END IF;
    
    -- Insert new profile
    INSERT INTO public.userprofiles (
        user_id,
        total_spent,
        prefered_language,
        status,
        phone,
        creation_date,
        last_update,
        inactive
    )
    VALUES (
        p_user_id,
        COALESCE(p_total_spent, 0),
        COALESCE(p_prefered_language, 'pt-PT'),
        COALESCE(p_status, 'active'),
        p_phone,
        NOW(),
        NOW(),
        FALSE
    )
    RETURNING id INTO v_id;
    
    RETURN v_id;
END;
$$;
