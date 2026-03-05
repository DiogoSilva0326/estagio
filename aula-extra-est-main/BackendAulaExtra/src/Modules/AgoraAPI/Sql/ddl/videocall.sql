-- SQL initializer: create video calls and participants tables
-- Stores video call sessions and participant history

-- Video calls table
CREATE TABLE IF NOT EXISTS public.video_calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Unique call identifier (Agora channel name)
  channel_name TEXT NOT NULL,
  -- Optional friendly name for the call
  call_name TEXT NULL,
  -- Call type: 'video', 'audio', 'screen_share'
  call_type TEXT NOT NULL DEFAULT 'video',
  -- Associated group room (if any)
  group_room_id UUID NULL,
  -- User who initiated the call
  initiated_by_user_id UUID NULL,
  -- Call status: 'active', 'ended', 'missed', 'declined'
  status TEXT NOT NULL DEFAULT 'active',
  -- Timestamps
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at TIMESTAMPTZ NULL,
  -- Calculated duration in seconds (updated when call ends)
  duration_seconds INTEGER NULL,
  -- Max concurrent participants during the call
  max_participants INTEGER NOT NULL DEFAULT 0,
  -- Recording info (if call was recorded)
  recording_url TEXT NULL,
  is_recorded BOOLEAN NOT NULL DEFAULT false,
  -- Metadata (Agora app settings, quality info, etc.)
  metadata JSONB NULL,

  CONSTRAINT fk_video_calls_initiator FOREIGN KEY (initiated_by_user_id)
    REFERENCES public.users (id_user) ON DELETE SET NULL
);

-- Add optional FK to group rooms only if the Communication module is installed.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'group_rooms'
  ) AND NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_video_calls_room'
  ) THEN
    ALTER TABLE public.video_calls
      ADD CONSTRAINT fk_video_calls_room
      FOREIGN KEY (group_room_id)
      REFERENCES public.group_rooms (id) ON DELETE SET NULL;
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_video_calls_channel ON public.video_calls (channel_name);
CREATE INDEX IF NOT EXISTS idx_video_calls_room ON public.video_calls (group_room_id);
CREATE INDEX IF NOT EXISTS idx_video_calls_initiator ON public.video_calls (initiated_by_user_id);
CREATE INDEX IF NOT EXISTS idx_video_calls_status ON public.video_calls (status);
CREATE INDEX IF NOT EXISTS idx_video_calls_started ON public.video_calls (started_at);

-- Video call participants table
CREATE TABLE IF NOT EXISTS public.video_call_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- The call
  call_id UUID NOT NULL,
  -- The participant user
  user_id UUID NOT NULL,
  -- Participant role: 'host', 'co-host', 'participant'
  role TEXT NOT NULL DEFAULT 'participant',
  -- Join/leave times for this participant
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  left_at TIMESTAMPTZ NULL,
  -- Duration this participant was in the call (seconds)
  duration_seconds INTEGER NULL,
  -- Connection quality metrics (optional)
  avg_video_quality TEXT NULL,  -- 'high', 'medium', 'low'
  avg_audio_quality TEXT NULL,
  -- Whether user had video/audio enabled
  had_video BOOLEAN NOT NULL DEFAULT true,
  had_audio BOOLEAN NOT NULL DEFAULT true,
  had_screen_share BOOLEAN NOT NULL DEFAULT false,
  -- Device/platform info
  device_type TEXT NULL,  -- 'web', 'ios', 'android', 'desktop'
  -- Metadata (connection stats, etc.)
  metadata JSONB NULL,
  
  CONSTRAINT fk_call_participants_call FOREIGN KEY (call_id)
    REFERENCES public.video_calls (id) ON DELETE CASCADE,
  CONSTRAINT fk_call_participants_user FOREIGN KEY (user_id)
    REFERENCES public.users (id_user) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_call_participants_call ON public.video_call_participants (call_id);
CREATE INDEX IF NOT EXISTS idx_call_participants_user ON public.video_call_participants (user_id);
CREATE INDEX IF NOT EXISTS idx_call_participants_joined ON public.video_call_participants (joined_at);

-- Useful views for querying

-- View: Active calls with participant count
CREATE OR REPLACE VIEW public.v_active_calls AS
SELECT 
  vc.id,
  vc.channel_name,
  vc.call_name,
  vc.call_type,
  vc.started_at,
  vc.initiated_by_user_id,
  u.display_name AS initiated_by_name,
  COUNT(vcp.id) AS current_participants
FROM public.video_calls vc
LEFT JOIN public.users u ON vc.initiated_by_user_id = u.id_user
LEFT JOIN public.video_call_participants vcp 
  ON vc.id = vcp.call_id AND vcp.left_at IS NULL
WHERE vc.status = 'active'
GROUP BY vc.id, u.display_name;

-- View: User call history with duration
CREATE OR REPLACE VIEW public.v_user_call_history AS
SELECT 
  vcp.user_id,
  vc.id AS call_id,
  vc.channel_name,
  vc.call_name,
  vc.call_type,
  vc.status AS call_status,
  vcp.role,
  vcp.joined_at,
  vcp.left_at,
  vcp.duration_seconds,
  vc.started_at AS call_started_at,
  vc.ended_at AS call_ended_at,
  vc.duration_seconds AS total_call_duration
FROM public.video_call_participants vcp
JOIN public.video_calls vc ON vcp.call_id = vc.id
ORDER BY vcp.joined_at DESC;

-- Notes:
-- 1) channel_name corresponds to Agora channel identifier
-- 2) When a call ends, update ended_at and calculate duration_seconds
-- 3) Participants can join/leave multiple times - each is a separate record
-- 4) Use v_active_calls view to find ongoing calls
-- 5) Use v_user_call_history view to show user's call history
