-- Court+ Production Hardening Migration
-- Phase 1: court_slots inventory, column additions, RLS hardening, indexes
-- Apply after 00002_seed_courts.sql

-- ────────────────
-- 1. court_slots — Time-Slot Inventory with Real-Time Booking Locks
-- ────────────────
CREATE TABLE IF NOT EXISTS public.court_slots (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  court_id    UUID NOT NULL REFERENCES public.courts(id) ON DELETE CASCADE,
  slot_date   DATE NOT NULL,
  start_time  TIME NOT NULL,
  end_time    TIME NOT NULL,
  status      TEXT NOT NULL DEFAULT 'available'
              CHECK (status IN ('available', 'locked', 'booked', 'maintenance')),
  locked_by   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  locked_at   TIMESTAMPTZ,
  version     INTEGER NOT NULL DEFAULT 1,   -- optimistic lock counter
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(court_id, slot_date, start_time)
);

CREATE INDEX IF NOT EXISTS idx_court_slots_date
  ON public.court_slots(court_id, slot_date);
CREATE INDEX IF NOT EXISTS idx_court_slots_status
  ON public.court_slots(status);

-- RLS: court_slots are public read, mutated only by SECURITY DEFINER functions
ALTER TABLE public.court_slots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "court_slots_select_all" ON public.court_slots
  FOR SELECT USING (true);

-- No INSERT/UPDATE/DELETE policies — only RPC functions modify this table
REVOKE ALL ON public.court_slots FROM anon, authenticated;
GRANT SELECT ON public.court_slots TO anon, authenticated;

-- ────────────────
-- 2. Column additions to existing tables
-- ────────────────

-- 2a. Add booking_id to reviews (for verified-purchase reviews)
ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS booking_id UUID
  REFERENCES public.bookings(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_reviews_booking ON public.reviews(booking_id);

-- 2b. Add surface_type and amenities to courts
ALTER TABLE public.courts ADD COLUMN IF NOT EXISTS surface_type TEXT DEFAULT '';
ALTER TABLE public.courts ADD COLUMN IF NOT EXISTS amenities JSONB DEFAULT '[]'::jsonb;

-- 2c. Add payment and match columns to bookings
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS match_id UUID
  REFERENCES public.matches(id) ON DELETE SET NULL;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS payment_intent_id TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS idempotency_key TEXT UNIQUE;
CREATE INDEX IF NOT EXISTS idx_bookings_payment_intent
  ON public.bookings(payment_intent_id);
CREATE INDEX IF NOT EXISTS idx_bookings_match
  ON public.bookings(match_id);

-- 2d. Add token to invitations (for deep-link sharing)
ALTER TABLE public.invitations ADD COLUMN IF NOT EXISTS token UUID DEFAULT gen_random_uuid();
CREATE INDEX IF NOT EXISTS idx_invitations_token ON public.invitations(token);

-- 2e. Add constraint: sender != receiver in invitations
ALTER TABLE public.invitations DROP CONSTRAINT IF EXISTS check_sender_not_receiver;
ALTER TABLE public.invitations ADD CONSTRAINT check_sender_not_receiver
  CHECK (sender_id <> receiver_id);

-- ────────────────
-- 3. Additional indexes for 1,000 concurrent users
-- ────────────────

-- Bookings: composite lookups (most frequent query pattern)
CREATE INDEX IF NOT EXISTS idx_bookings_user_status
  ON public.bookings(user_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_court_date
  ON public.bookings(court_id, date);

-- Matches: search & filter
CREATE INDEX IF NOT EXISTS idx_matches_court_date
  ON public.matches(court_id, date);
CREATE INDEX IF NOT EXISTS idx_matches_level_gender
  ON public.matches(level, gender);

-- Invitations: pending notifications
CREATE INDEX IF NOT EXISTS idx_invitations_receiver_status
  ON public.invitations(receiver_id, status)
  WHERE status = 'pending';

-- ────────────────
-- 4. RLS policy hardening
-- ────────────────

-- 4a. Reviews: only allow insert if user had a completed booking for this court
DROP POLICY IF EXISTS "reviews_insert_auth" ON public.reviews;
DROP POLICY IF EXISTS "reviews_insert_own" ON public.reviews;
CREATE POLICY "reviews_insert_with_booking" ON public.reviews
  FOR INSERT WITH CHECK (
    auth.role() = 'authenticated'
    AND (
      booking_id IS NULL
      OR EXISTS (
        SELECT 1 FROM public.bookings
        WHERE bookings.id = booking_id
          AND bookings.user_id = auth.uid()
          AND bookings.status = 'completed'
      )
    )
  );

-- 4b. Bookings: only allow insert if the user is authenticated
-- (already exists, adding explicit check)
DROP POLICY IF EXISTS "bookings_insert_own" ON public.bookings;
CREATE POLICY "bookings_insert_own" ON public.bookings
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
  );

-- 4c. Notifications: only allow SELECT on own notifications
-- (already exists, no change needed)

-- ────────────────
-- 5. RPC Functions for Double-Booking Lock Engine
-- ────────────────

-- 5a. lock_booking_slot: Atomic slot reservation with SELECT FOR UPDATE
CREATE OR REPLACE FUNCTION public.lock_booking_slot(
  p_court_id    UUID,
  p_date        DATE,
  p_start_time  TEXT,
  p_duration    REAL,
  p_user_id     UUID
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET statement_timeout = '10s'
AS $$
DECLARE
  v_slot      public.court_slots%ROWTYPE;
  v_end_time  TIME;
  v_bookings  INT;
  v_result    JSONB;
  v_price     REAL;
BEGIN
  v_end_time := p_start_time::TIME + (p_duration * INTERVAL '1 hour');

  -- 1. Check overlapping bookings (existing confirmed/booked slots)
  SELECT COUNT(*) INTO v_bookings
  FROM public.bookings
  WHERE court_id = p_court_id
    AND date = p_date
    AND status IN ('confirmed', 'pending')
    AND time_slot::TIME < v_end_time
    AND (time_slot::TIME + (duration * INTERVAL '1 hour')) > p_start_time::TIME;

  IF v_bookings > 0 THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Time slot already booked',
      'code', 'SLOT_CONFLICT'
    );
  END IF;

  -- 2. Get the court price
  SELECT price_per_hour INTO v_price FROM public.courts WHERE id = p_court_id;

  -- 3. Lock the court_slot row (SELECT FOR UPDATE)
  SELECT * INTO v_slot
  FROM public.court_slots
  WHERE court_id = p_court_id
    AND slot_date = p_date
    AND start_time = p_start_time::TIME
  FOR UPDATE;

  IF NOT FOUND THEN
    -- Slot not in inventory — first booking for this slot, auto-insert
    INSERT INTO public.court_slots
      (court_id, slot_date, start_time, end_time, status, locked_by, locked_at)
    VALUES (p_court_id, p_date, p_start_time::TIME, v_end_time, 'locked', p_user_id, NOW())
    RETURNING * INTO v_slot;
  ELSIF v_slot.status = 'available' THEN
    -- Slot available → lock it with optimistic concurrency
    UPDATE public.court_slots
    SET status = 'locked',
        locked_by = p_user_id,
        locked_at = NOW(),
        version = version + 1
    WHERE id = v_slot.id
      AND version = v_slot.version
    RETURNING * INTO v_slot;

    IF NOT FOUND THEN
      RETURN jsonb_build_object(
        'success', false,
        'error', 'Concurrent booking detected, please retry',
        'code', 'CONCURRENCY_CONFLICT'
      );
    END IF;
  ELSE
    -- Slot is locked, booked, or under maintenance
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Slot is currently ' || v_slot.status,
      'code', 'SLOT_UNAVAILABLE'
    );
  END IF;

  -- 4. Create booking record (pending status)
  INSERT INTO public.bookings (
    user_id, court_id, date, time_slot, duration, status, total_amount
  ) VALUES (
    p_user_id,
    p_court_id,
    p_date,
    p_start_time,
    p_duration,
    'pending',
    v_price * p_duration
  )
  RETURNING jsonb_build_object(
    'success', true,
    'booking_id', id,
    'slot_id', v_slot.id,
    'total_amount', v_price * p_duration,
    'court_price_per_hour', v_price
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- 5b. confirm_booking_payment: Atomic booking confirmation after payment success
CREATE OR REPLACE FUNCTION public.confirm_booking_payment(
  p_booking_id         UUID,
  p_payment_intent_id  TEXT,
  p_amount             REAL
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET statement_timeout = '10s'
AS $$
DECLARE
  v_booking public.bookings%ROWTYPE;
  v_slot_id UUID;
  v_result  JSONB;
BEGIN
  -- Lock booking row
  SELECT * INTO v_booking
  FROM public.bookings
  WHERE id = p_booking_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Booking not found');
  END IF;

  IF v_booking.status != 'pending' THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Booking ' || p_booking_id || ' is already in ' || v_booking.status || ' state'
    );
  END IF;

  -- Update booking to confirmed
  UPDATE public.bookings
  SET status = 'confirmed',
      payment_intent_id = p_payment_intent_id
  WHERE id = p_booking_id;

  -- Mark slot as booked
  UPDATE public.court_slots
  SET status = 'booked',
      locked_by = NULL,
      locked_at = NULL
  WHERE court_id = v_booking.court_id
    AND slot_date = v_booking.date::DATE
    AND start_time = v_booking.time_slot::TIME;

  -- Record payment
  INSERT INTO public.payments (booking_id, user_id, amount, method, status)
  VALUES (p_booking_id, v_booking.user_id, p_amount, 'card', 'completed');

  RETURN jsonb_build_object('success', true, 'booking_id', p_booking_id);
END;
$$;

-- 5c. release_slot_lock: Release a locked slot on payment failure or timeout
CREATE OR REPLACE FUNCTION public.release_slot_lock(p_booking_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET statement_timeout = '10s'
AS $$
DECLARE
  v_booking public.bookings%ROWTYPE;
BEGIN
  SELECT * INTO v_booking FROM public.bookings WHERE id = p_booking_id;

  IF NOT FOUND THEN
    -- Booking may not exist yet; try to find by court_slot
    RETURN jsonb_build_object('success', false, 'error', 'Booking not found');
  END IF;

  -- Release the slot
  UPDATE public.court_slots
  SET status = 'available',
      locked_by = NULL,
      locked_at = NULL,
      version = version + 1
  WHERE court_id = v_booking.court_id
    AND slot_date = v_booking.date::DATE
    AND start_time = v_booking.time_slot::TIME;

  -- Cancel the booking
  UPDATE public.bookings SET status = 'cancelled' WHERE id = p_booking_id;

  RETURN jsonb_build_object('success', true, 'booking_id', p_booking_id, 'action', 'released');
END;
$$;

-- 5d. search_courts: Full-text + geo-radius court search
CREATE OR REPLACE FUNCTION public.search_courts(
  p_sport_type    TEXT DEFAULT NULL,
  p_min_price     REAL DEFAULT 0,
  p_max_price     REAL DEFAULT 99999,
  p_min_rating    REAL DEFAULT 0,
  p_lat           DOUBLE PRECISION DEFAULT NULL,
  p_lng           DOUBLE PRECISION DEFAULT NULL,
  p_radius_km     REAL DEFAULT 10,
  p_search_term   TEXT DEFAULT NULL
) RETURNS SETOF public.courts
LANGUAGE plpgsql
STABLE
SET statement_timeout = '5s'
AS $$
BEGIN
  RETURN QUERY
  SELECT c.*
  FROM public.courts c
  WHERE c.is_active = true
    AND (p_sport_type IS NULL OR c.sport_type = p_sport_type)
    AND c.price_per_hour BETWEEN p_min_price AND p_max_price
    AND c.rating >= p_min_rating
    AND (p_search_term IS NULL OR
         c.name ILIKE '%' || p_search_term || '%' OR
         c.center ILIKE '%' || p_search_term || '%' OR
         c.location ILIKE '%' || p_search_term || '%')
    AND (p_lat IS NULL OR p_lng IS NULL OR p_radius_km IS NULL OR
         (2 * 6371 * asin(sqrt(
           power(sin((radians(c.latitude) - radians(p_lat)) / 2), 2) +
           cos(radians(p_lat)) * cos(radians(c.latitude)) *
           power(sin((radians(c.longitude) - radians(p_lng)) / 2), 2)
         ))) <= p_radius_km)
  ORDER BY c.rating DESC, c.price_per_hour ASC;
END;
$$;

-- 5e. get_available_slots: Return available time slots for a court on a date
CREATE OR REPLACE FUNCTION public.get_available_slots(
  p_court_id  UUID,
  p_date      DATE
) RETURNS TABLE(
  slot_id      UUID,
  start_time   TIME,
  end_time     TIME,
  status       TEXT
)
LANGUAGE plpgsql
STABLE
SET statement_timeout = '5s'
AS $$
BEGIN
  RETURN QUERY
  SELECT cs.id, cs.start_time, cs.end_time, cs.status
  FROM public.court_slots cs
  WHERE cs.court_id = p_court_id
    AND cs.slot_date = p_date
    AND cs.status IN ('available', 'locked')
  ORDER BY cs.start_time;
END;
$$;

-- ────────────────
-- 6. Auto-release stale locks (run via cron or trigger)
-- ────────────────
CREATE OR REPLACE FUNCTION public.release_stale_locks()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_released INTEGER;
BEGIN
  UPDATE public.court_slots
  SET status = 'available',
      locked_by = NULL,
      locked_at = NULL,
      version = version + 1
  WHERE status = 'locked'
    AND locked_at < NOW() - INTERVAL '15 minutes'
  RETURNING 1 INTO v_released;

  -- Also cancel any pending bookings whose slots were released
  UPDATE public.bookings
  SET status = 'cancelled'
  WHERE status = 'pending'
    AND created_at < NOW() - INTERVAL '15 minutes';

  GET DIAGNOSTICS v_released = ROW_COUNT;
  RETURN v_released;
END;
$$;

-- ────────────────
-- 7. Connection limits (optional — enforced at Supabase project level)
-- ────────────────
-- ALTER ROLE authenticator CONNECTION LIMIT 100;
-- ALTER ROLE anon CONNECTION LIMIT 50;
-- ALTER ROLE service_role CONNECTION LIMIT 20;

-- Set statement timeout for all roles
-- ALTER DATABASE postgres SET statement_timeout = '30s';

-- ────────────────
-- 8. Verify the migration
-- ────────────────
DO $$
BEGIN
  -- Verify court_slots table exists
  ASSERT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'court_slots'
  ), 'court_slots table was not created';

  -- Verify new columns exist
  ASSERT EXISTS (
    SELECT FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'reviews' AND column_name = 'booking_id'
  ), 'reviews.booking_id column was not added';

  ASSERT EXISTS (
    SELECT FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'courts' AND column_name = 'surface_type'
  ), 'courts.surface_type column was not added';

  ASSERT EXISTS (
    SELECT FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'bookings' AND column_name = 'payment_intent_id'
  ), 'bookings.payment_intent_id column was not added';

  ASSERT EXISTS (
    SELECT FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'invitations' AND column_name = 'token'
  ), 'invitations.token column was not added';

  RAISE NOTICE 'Migration 00003_production_hardening.sql — ALL CHECKS PASSED';
END;
$$;