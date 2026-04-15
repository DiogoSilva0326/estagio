CREATE TABLE IF NOT EXISTS complaints (
  id_complaint UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  receiver_user_id UUID REFERENCES users(id_user),
  complaint_type VARCHAR(100),
  complaint_subject VARCHAR(160),
  complaint_message VARCHAR(1000),
  status VARCHAR(30),
  is_read BOOLEAN DEFAULT false,
  sender_display_name VARCHAR(160),
  receiver_display_name VARCHAR(160),
  sender_role VARCHAR(30),
  receiver_role VARCHAR(30),
  relationship_context VARCHAR(30),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

ALTER TABLE complaints ADD COLUMN IF NOT EXISTS complaint_subject VARCHAR(160);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS sender_display_name VARCHAR(160);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS receiver_display_name VARCHAR(160);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS sender_role VARCHAR(30);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS receiver_role VARCHAR(30);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS relationship_context VARCHAR(30);

CREATE TABLE IF NOT EXISTS complaint_resolutions (
  id_complaint_resolution UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  complaint_id UUID NOT NULL REFERENCES complaints(id_complaint) ON DELETE CASCADE,
  admin_user_id UUID NOT NULL REFERENCES users(id_user),
  resolution_status VARCHAR(50),
  resolution_notes TEXT,
  resolved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);