DROP FUNCTION IF EXISTS public.usp_invoices_select_all01();
DROP FUNCTION IF EXISTS public.usp_invoices_select_details01(uuid);
DROP FUNCTION IF EXISTS public.usp_invoices_select_by_user01(uuid);
DROP FUNCTION IF EXISTS public.usp_invoices_insert(uuid, uuid, character varying, character varying, text, numeric, numeric, timestamp, uuid, character varying);
DROP FUNCTION IF EXISTS public.usp_invoices_update(uuid, character varying, character varying, text, numeric, numeric, timestamp, uuid, character varying);
DROP FUNCTION IF EXISTS public.usp_invoices_delete(uuid);

CREATE OR REPLACE FUNCTION public.usp_invoices_select_all01()
RETURNS SETOF public.invoices
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.invoices
  ORDER BY issued_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_invoices_select_details01(
  p_id_invoice uuid
)
RETURNS SETOF public.invoices
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.invoices
  WHERE id_invoice = p_id_invoice;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_invoices_select_by_user01(
  p_id_user uuid
)
RETURNS SETOF public.invoices
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.invoices
  WHERE id_user = p_id_user
  ORDER BY issued_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_invoices_insert(
  p_id_transaction uuid,
  p_id_user uuid,
  p_invoice_type varchar(50),
  p_document_reference varchar(255),
  p_pdf_url text,
  p_total_amount numeric,
  p_tax_amount numeric,
  p_issued_at timestamp,
  p_related_invoice_id uuid,
  p_at_status varchar(50)
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.invoices (
    id_transaction,
    id_user,
    invoice_type,
    document_reference,
    pdf_url,
    total_amount,
    tax_amount,
    issued_at,
    related_invoice_id,
    at_status
  )
  VALUES (
    p_id_transaction,
    p_id_user,
    p_invoice_type,
    p_document_reference,
    p_pdf_url,
    p_total_amount,
    p_tax_amount,
    COALESCE(p_issued_at, now()),
    p_related_invoice_id,
    p_at_status
  )
  RETURNING id_invoice INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_invoices_update(
  p_id_invoice uuid,
  p_invoice_type varchar(50),
  p_document_reference varchar(255),
  p_pdf_url text,
  p_total_amount numeric,
  p_tax_amount numeric,
  p_issued_at timestamp,
  p_related_invoice_id uuid,
  p_at_status varchar(50)
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  UPDATE public.invoices
  SET invoice_type = p_invoice_type,
      document_reference = p_document_reference,
      pdf_url = p_pdf_url,
      total_amount = p_total_amount,
      tax_amount = p_tax_amount,
      issued_at = COALESCE(p_issued_at, issued_at),
      related_invoice_id = p_related_invoice_id,
      at_status = p_at_status
  WHERE id_invoice = p_id_invoice;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;

CREATE OR REPLACE FUNCTION public.usp_invoices_delete(
  p_id_invoice uuid
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_rowcount integer;
BEGIN
  DELETE FROM public.invoices
  WHERE id_invoice = p_id_invoice;

  GET DIAGNOSTICS v_rowcount = ROW_COUNT;
  RETURN v_rowcount;
END;
$$;
