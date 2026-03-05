CREATE TABLE IF NOT EXISTS notifications (
  id_notification UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_user UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  type VARCHAR(50),
  message VARCHAR(500),
  was_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS messages (
  id_message UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  receiver_user_id UUID NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  message_content TEXT,
  is_read BOOLEAN DEFAULT false,
  sent_at TIMESTAMP DEFAULT now(),
  read_at TIMESTAMP
);

-- SQL initializer: create contacts table for user relationships
-- Stores contact relationships between users (friendship/contact list)

CREATE TABLE IF NOT EXISTS public.contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- The user who owns this contact
  owner_user_id UUID NOT NULL,
  -- The contact user
  contact_user_id UUID NOT NULL,
  -- Display name override (optional, if owner wants custom name for contact)
  display_name_override TEXT NULL,
  -- Contact status: pending, accepted, blocked
  status TEXT NOT NULL DEFAULT 'pending',
  -- Optional notes about the contact
  notes TEXT NULL,
  -- Metadata (JSON for extensibility)
  metadata JSONB NULL,
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  -- Constraints
  CONSTRAINT fk_contacts_owner FOREIGN KEY (owner_user_id)
    REFERENCES public.users (id_user) ON DELETE CASCADE,
  CONSTRAINT fk_contacts_contact FOREIGN KEY (contact_user_id)
    REFERENCES public.users (id_user) ON DELETE CASCADE,
  -- Prevent duplicate contacts
  CONSTRAINT uq_contacts_owner_contact UNIQUE (owner_user_id, contact_user_id),
  -- Prevent self-contact
  CONSTRAINT chk_contacts_no_self CHECK (owner_user_id <> contact_user_id)
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_contacts_owner ON public.contacts (owner_user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_contact ON public.contacts (contact_user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_status ON public.contacts (status);

-- Notes:
-- 1) Contact relationships are directional (A adds B doesn't mean B has A)
-- 2) For mutual friendships, create two records (A->B and B->A)
-- 3) Status values: 'pending' (request sent), 'accepted', 'blocked'


-- SQL initializer: create group rooms and membership tables
-- Stores group chat rooms and their members

-- Group rooms table
CREATE TABLE IF NOT EXISTS public.group_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Unique room identifier (used in SignalR/channel name)
  room_code TEXT NOT NULL UNIQUE,
  -- Human-friendly group name
  name TEXT NOT NULL,
  -- Optional description
  description TEXT NULL,
  -- Room type: 'group' (multi-user), 'direct' (1-to-1)
  room_type TEXT NOT NULL DEFAULT 'group',
  -- Creator/owner of the room
  created_by_user_id UUID NULL,
  -- Whether the room is active
  is_active BOOLEAN NOT NULL DEFAULT true,
  -- Room avatar/image URL
  avatar_url TEXT NULL,
  -- Settings and metadata
  metadata JSONB NULL,
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  
  CONSTRAINT fk_group_rooms_creator FOREIGN KEY (created_by_user_id)
    REFERENCES public.users (id_user) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_group_rooms_room_code ON public.group_rooms (room_code);
CREATE INDEX IF NOT EXISTS idx_group_rooms_created_by ON public.group_rooms (created_by_user_id);
CREATE INDEX IF NOT EXISTS idx_group_rooms_active ON public.group_rooms (is_active);

-- Group room members table
CREATE TABLE IF NOT EXISTS public.group_room_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- The room
  room_id UUID NOT NULL,
  -- The member user
  user_id UUID NOT NULL,
  -- Role in the room: 'owner', 'admin', 'member'
  role TEXT NOT NULL DEFAULT 'member',
  -- Nickname in this room (optional)
  nickname TEXT NULL,
  -- Member status: 'active', 'left', 'kicked', 'banned'
  status TEXT NOT NULL DEFAULT 'active',
  -- Notification settings
  notifications_enabled BOOLEAN NOT NULL DEFAULT true,
  -- When the user joined
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- When the user left (if applicable)
  left_at TIMESTAMPTZ NULL,
  -- Last read message timestamp (for unread count)
  last_read_at TIMESTAMPTZ NULL,
  
  CONSTRAINT fk_room_members_room FOREIGN KEY (room_id)
    REFERENCES public.group_rooms (id) ON DELETE CASCADE,
  CONSTRAINT fk_room_members_user FOREIGN KEY (user_id)
    REFERENCES public.users (id_user) ON DELETE CASCADE,
  -- Prevent duplicate membership
  CONSTRAINT uq_room_members UNIQUE (room_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_room_members_room ON public.group_room_members (room_id);
CREATE INDEX IF NOT EXISTS idx_room_members_user ON public.group_room_members (user_id);
CREATE INDEX IF NOT EXISTS idx_room_members_status ON public.group_room_members (status);

-- Update messages table to optionally link to group_rooms
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS group_room_id UUID NULL;

-- Add FK constraint if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'fk_messages_group_room'
  ) THEN
    ALTER TABLE public.messages
      ADD CONSTRAINT fk_messages_group_room FOREIGN KEY (group_room_id)
        REFERENCES public.group_rooms (id) ON DELETE SET NULL;
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_messages_group_room ON public.messages (group_room_id);

-- Notes:
-- 1) room_code is the unique identifier used for SignalR groups
-- 2) For direct messages, create a room with room_type='direct' and 2 members
-- 3) Messages can be linked via group_room_id OR room_id (legacy text field)
