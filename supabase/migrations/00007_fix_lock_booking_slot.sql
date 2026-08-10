-- Fix lock_booking_slot RPC: include court_name in booking insert
-- The bookings.court_name column is NOT NULL but the original RPC omitted it.
-- Apply after 00003_production_hardening.sql

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
  v_court_name TEXT;
BEGIN
  v_end_time := p_start_time::TIME + (p_duration * INTERVAL '1 hour');

  -- 1. Check overlapping bookings
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

  -- 2. Get court price and name
  SELECT price_per_hour, COALESCE(name, 'Court')
  INTO v_price, v_court_name
  FROM public.courts WHERE id = p_court_id;

  -- 3. Lock the court_slot row (SELECT FOR UPDATE)
  SELECT * INTO v_slot
  FROM public.court_slots
  WHERE court_id = p_court_id
    AND slot_date = p_date
    AND start_time = p_start_time::TIME
  FOR UPDATE;

  IF NOT FOUND THEN
    INSERT INTO public.court_slots
      (court_id, slot_date, start_time, end_time, status, locked_by, locked_at)
    VALUES (p_court_id, p_date, p_start_time::TIME, v_end_time, 'locked', p_user_id, NOW())
    RETURNING * INTO v_slot;
  ELSIF v_slot.status = 'available' THEN
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
    RETURN jsonb_build_object(
      'success', false,
      'error', 'Slot is currently ' || v_slot.status,
      'code', 'SLOT_UNAVAILABLE'
    );
  END IF;

  -- 4. Create booking record with court_name (was missing, causing NOT NULL violation)
  INSERT INTO public.bookings (
    user_id, court_id, court_name, date, time_slot, duration, status, total_amount
  ) VALUES (
    p_user_id,
    p_court_id,
    v_court_name,
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