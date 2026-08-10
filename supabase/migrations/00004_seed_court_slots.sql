-- Seed court_slots: generate 30 days of hourly time slots for all active courts.
-- Run AFTER 00003_production_hardening.sql and 00002_seed_courts.sql

-- Operating hours: 06:00 to 23:00 (17 one-hour slots per court per day)
DO $$
DECLARE
  v_court RECORD;
  v_date  DATE := CURRENT_DATE;
  v_hour  INT;
  v_count INTEGER := 0;
BEGIN
  FOR v_court IN SELECT id FROM public.courts WHERE is_active = true LOOP
    -- 30 days
    FOR day_offset IN 0..29 LOOP
      v_date := CURRENT_DATE + day_offset;
      -- 17 slots: 06:00 → 22:00 (start times), each 1 hour
      FOR v_hour IN 6..22 LOOP
        INSERT INTO public.court_slots (court_id, slot_date, start_time, end_time, status)
        VALUES (
          v_court.id,
          v_date,
          make_time(v_hour, 0, 0),
          make_time(v_hour + 1, 0, 0),
          'available'
        )
        ON CONFLICT (court_id, slot_date, start_time) DO NOTHING;
        v_count := v_count + 1;
      END LOOP;
    END LOOP;
  END LOOP;

  RAISE NOTICE 'Seeded % court_slot rows for % courts over 30 days',
    v_count, (SELECT COUNT(*) FROM public.courts WHERE is_active = true);
END;
$$;