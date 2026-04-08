DROP FUNCTION IF EXISTS public.usp_contacts_select_all01();

CREATE OR REPLACE FUNCTION public.usp_contacts_select_all01()
RETURNS SETOF public.contacts
LANGUAGE sql
AS $$
  SELECT *
  FROM public.contacts
  ORDER BY created_at DESC;
$$;

DROP FUNCTION IF EXISTS public.usp_contacts_select_details01(uuid);

CREATE OR REPLACE FUNCTION public.usp_contacts_select_details01(
  p_id uuid
)
RETURNS SETOF public.contacts
LANGUAGE sql
AS $$
  SELECT *
  FROM public.contacts
  WHERE id = p_id;
$$;

DROP FUNCTION IF EXISTS public.usp_contacts_select_by_owner01(uuid);

CREATE OR REPLACE FUNCTION public.usp_contacts_select_by_owner01(
  p_owner_user_id uuid
)
RETURNS SETOF public.contacts
LANGUAGE sql
AS $$
  SELECT *
  FROM public.contacts
  WHERE owner_user_id = p_owner_user_id
  ORDER BY created_at DESC;
$$;

DROP FUNCTION IF EXISTS public.usp_contacts_select_by_owner_and_contact01(uuid, uuid);

CREATE OR REPLACE FUNCTION public.usp_contacts_select_by_owner_and_contact01(
  p_owner_user_id uuid,
  p_contact_user_id uuid
)
RETURNS SETOF public.contacts
LANGUAGE sql
AS $$
  SELECT *
  FROM public.contacts
  WHERE owner_user_id = p_owner_user_id
    AND contact_user_id = p_contact_user_id
  LIMIT 1;
$$;

DROP FUNCTION IF EXISTS public.usp_contacts_insert(uuid, uuid, text, text, text, jsonb, timestamptz, timestamptz);

CREATE OR REPLACE FUNCTION public.usp_contacts_insert(
  p_owner_user_id uuid,
  p_contact_user_id uuid,
  p_display_name_override text,
  p_status text,
  p_notes text,
  p_metadata jsonb,
  p_created_at timestamptz,
  p_updated_at timestamptz
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.contacts (
    owner_user_id,
    contact_user_id,
    display_name_override,
    status,
    notes,
    metadata,
    created_at,
    updated_at
  )
  VALUES (
    p_owner_user_id,
    p_contact_user_id,
    p_display_name_override,
    COALESCE(p_status, 'pending'),
    p_notes,
    p_metadata,
    COALESCE(p_created_at, now()),
    COALESCE(p_updated_at, now())
  )
  RETURNING id;
$$;

DROP FUNCTION IF EXISTS public.usp_contacts_upsert01(uuid, uuid, text, text, text, jsonb);

CREATE OR REPLACE FUNCTION public.usp_contacts_upsert01(
  p_owner_user_id uuid,
  p_contact_user_id uuid,
  p_display_name_override text,
  p_status text,
  p_notes text,
  p_metadata jsonb
)
RETURNS uuid
LANGUAGE sql
AS $$
  INSERT INTO public.contacts (
    owner_user_id,
    contact_user_id,
    display_name_override,
    status,
    notes,
    metadata,
    created_at,
    updated_at
  )
  VALUES (
    p_owner_user_id,
    p_contact_user_id,
    p_display_name_override,
    COALESCE(p_status, 'pending'),
    p_notes,
    p_metadata,
    now(),
    now()
  )
  ON CONFLICT (owner_user_id, contact_user_id)
  DO UPDATE SET
    display_name_override = COALESCE(EXCLUDED.display_name_override, contacts.display_name_override),
    status = COALESCE(EXCLUDED.status, contacts.status),
    notes = COALESCE(EXCLUDED.notes, contacts.notes),
    metadata = COALESCE(EXCLUDED.metadata, contacts.metadata),
    updated_at = now()
  RETURNING id;
$$;

DROP FUNCTION IF EXISTS public.usp_contacts_update(uuid, uuid, uuid, text, text, text, jsonb);

CREATE OR REPLACE FUNCTION public.usp_contacts_update(
  p_id uuid,
  p_owner_user_id uuid,
  p_contact_user_id uuid,
  p_display_name_override text,
  p_status text,
  p_notes text,
  p_metadata jsonb
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH updated AS (
    UPDATE public.contacts
    SET owner_user_id = p_owner_user_id,
        contact_user_id = p_contact_user_id,
        display_name_override = p_display_name_override,
        status = COALESCE(p_status, status),
        notes = p_notes,
        metadata = p_metadata,
        updated_at = now()
    WHERE id = p_id
    RETURNING 1
  )
  SELECT count(*)::integer FROM updated;
$$;

DROP FUNCTION IF EXISTS public.usp_contacts_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_contacts_delete(
  p_id uuid
)
RETURNS integer
LANGUAGE sql
AS $$
  WITH deleted AS (
    DELETE FROM public.contacts
    WHERE id = p_id
    RETURNING 1
  )
  SELECT count(*)::integer FROM deleted;
$$;
