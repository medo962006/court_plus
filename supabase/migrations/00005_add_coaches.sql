-- Court+ Coaches table
-- Run: supabase migration new add_coaches

CREATE TABLE IF NOT EXISTS public.coaches (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name       TEXT NOT NULL,
  username        TEXT UNIQUE NOT NULL,
  avatar_url      TEXT,
  sport_type      TEXT NOT NULL,
  rating          REAL DEFAULT 0,
  price_per_session REAL NOT NULL DEFAULT 100,
  bio             TEXT,
  experience      INTEGER DEFAULT 0,
  latitude        DOUBLE PRECISION,
  longitude       DOUBLE PRECISION,
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coaches_sport ON public.coaches(sport_type);
CREATE INDEX IF NOT EXISTS idx_coaches_coords ON public.coaches(latitude, longitude);

ALTER TABLE public.coaches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "coaches_select_all" ON public.coaches FOR SELECT USING (true);

-- Seed sample coaches in Riyadh
INSERT INTO public.coaches (full_name, username, avatar_url, sport_type, rating, price_per_session, bio, experience, latitude, longitude)
VALUES
  ('Donald Khalid', 'donaldkhalid', NULL, 'Tennis', 4.8, 150, 'Professional tennis coach with 10+ years experience', 10, 24.7200, 46.6700),
  ('Sarah Ahmed', 'sarahahmed', NULL, 'Tennis', 4.9, 200, 'Former WTA player, certified coach', 8, 24.7300, 46.6800),
  ('Mohammed Ali', 'mohammedali', NULL, 'Football', 4.7, 120, 'AFC certified football coach', 12, 24.7100, 46.6600),
  ('Fatima Hassan', 'fatimahassan', NULL, 'Padel', 4.6, 130, 'Padel specialist, national team coach', 5, 24.7400, 46.6900),
  ('Khalid Omar', 'khalidomar', NULL, 'Basketball', 4.5, 100, 'Youth basketball development coach', 7, 24.7000, 46.6500)
ON CONFLICT (username) DO NOTHING;

-- Seed sample coaches in NYC area (for demo)
INSERT INTO public.coaches (full_name, username, avatar_url, sport_type, rating, price_per_session, bio, experience, latitude, longitude)
VALUES
  ('Mike Johnson', 'mikejohnson', NULL, 'Tennis', 4.7, 180, 'USPTA certified tennis professional', 15, 40.7128, -73.8100),
  ('Elena Garcia', 'elenagarcia', NULL, 'Tennis', 4.9, 220, 'Former top 100 WTA, specializes in technique', 12, 40.7200, -73.8200)
ON CONFLICT (username) DO NOTHING;