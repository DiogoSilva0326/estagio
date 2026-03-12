CREATE TABLE IF NOT EXISTS public.user_role (
    role_id INTEGER NOT NULL,
    user_id UUID NOT NULL,

    -- PRIMARY KEY
    CONSTRAINT pk_user_role PRIMARY KEY (role_id, user_id),

    -- FOREIGN KEYS
    CONSTRAINT fk_user_role_role
        FOREIGN KEY (role_id)
        REFERENCES public.role (id),

    CONSTRAINT fk_user_role_user
        FOREIGN KEY (user_id)
        REFERENCES public.users (id_user)
);
