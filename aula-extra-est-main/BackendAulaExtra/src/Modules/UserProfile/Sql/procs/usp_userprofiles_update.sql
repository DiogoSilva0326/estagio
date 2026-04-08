-- Update UserProfile
CREATE OR REPLACE FUNCTION public.usp_userprofiles_update(
    p_user_id UUID,
    p_total_spent DECIMAL(18,2) DEFAULT NULL,
    p_reset_password_token TEXT DEFAULT NULL,
    p_reset_password_token_expiry TIMESTAMP DEFAULT NULL,
    p_email_verification_token TEXT DEFAULT NULL,
    p_email_verified_at TIMESTAMP DEFAULT NULL,
    p_prefered_language VARCHAR(10) DEFAULT NULL,
    p_status VARCHAR(50) DEFAULT NULL,
    p_phone VARCHAR(20) DEFAULT NULL,
    p_profile_image_url TEXT DEFAULT NULL,
    p_profile_image_thumbnail_url TEXT DEFAULT NULL,
    p_profile_image_cloudflare_id TEXT DEFAULT NULL,
    p_profile_image_provider VARCHAR(50) DEFAULT NULL,
    p_profile_image_source VARCHAR(50) DEFAULT NULL,
    p_clear_profile_image BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT;
BEGIN
    UPDATE public.userprofiles
    SET
        total_spent = COALESCE(p_total_spent, total_spent),
        reset_password_token = CASE 
            WHEN p_reset_password_token IS NOT NULL THEN p_reset_password_token 
            ELSE reset_password_token 
        END,
        reset_password_token_expiry = CASE 
            WHEN p_reset_password_token_expiry IS NOT NULL THEN p_reset_password_token_expiry 
            ELSE reset_password_token_expiry 
        END,
        email_verification_token = CASE 
            WHEN p_email_verification_token IS NOT NULL THEN p_email_verification_token 
            ELSE email_verification_token 
        END,
        email_verified_at = CASE 
            WHEN p_email_verified_at IS NOT NULL THEN p_email_verified_at 
            ELSE email_verified_at 
        END,
        prefered_language = COALESCE(p_prefered_language, prefered_language),
        status = COALESCE(p_status, status),
        phone = CASE 
            WHEN p_phone IS NOT NULL THEN p_phone 
            ELSE phone 
        END,
        profile_image_url = CASE
            WHEN p_clear_profile_image THEN NULL
            WHEN p_profile_image_url IS NOT NULL THEN p_profile_image_url
            ELSE profile_image_url
        END,
        profile_image_thumbnail_url = CASE
            WHEN p_clear_profile_image THEN NULL
            WHEN p_profile_image_thumbnail_url IS NOT NULL THEN p_profile_image_thumbnail_url
            ELSE profile_image_thumbnail_url
        END,
        profile_image_cloudflare_id = CASE
            WHEN p_clear_profile_image THEN NULL
            WHEN p_profile_image_cloudflare_id IS NOT NULL THEN p_profile_image_cloudflare_id
            ELSE profile_image_cloudflare_id
        END,
        profile_image_provider = CASE
            WHEN p_clear_profile_image THEN NULL
            WHEN p_profile_image_provider IS NOT NULL THEN p_profile_image_provider
            ELSE profile_image_provider
        END,
        profile_image_source = CASE
            WHEN p_clear_profile_image THEN NULL
            WHEN p_profile_image_source IS NOT NULL THEN p_profile_image_source
            ELSE profile_image_source
        END,
        last_update = NOW()
    WHERE user_id = p_user_id;
    
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END;
$$;
