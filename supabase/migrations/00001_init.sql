-- Court+ Database Schema
-- Run: supabase migration new court_plus_init
-- Then paste this into the generated migration file.

-- ─── Extensions ───
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ─── Profiles (extends auth.users) ───
CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL DEFAULT '',
  username      TEXT UNIQUE NOT NULL,
  bio           TEXT DEFAULT '',
  phone         TEXT,
  email         TEXT,
  avatar_url    TEXT,
  header_url    TEXT,
  date_of_birth TEXT,
  gender        TEXT,
  matches_count INTEGER DEFAULT 0,
  courts_count  INTEGER DEFAULT 0,
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_username ON public.profiles(username);
CREATE INDEX idx_profiles_full_name_trgm ON public.profiles USING GIN (full_name gin_trgm_ops);

-- ─── Courts ───
CREATE TABLE public.courts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  center          TEXT NOT NULL,
  sport_type      TEXT NOT NULL,
  location        TEXT NOT NULL,
  address         TEXT,
  image_url       TEXT,
  rating          REAL DEFAULT 0,
  reviews_count   INTEGER DEFAULT 0,
  likes_count     INTEGER DEFAULT 0,
  price_per_hour  REAL NOT NULL DEFAULT 100,
  latitude        DOUBLE PRECISION,
  longitude       DOUBLE PRECISION,
  is_active       BOOLEAN DEFAULT true,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_courts_sport_type ON public.courts(sport_type);
CREATE INDEX idx_courts_location ON public.courts USING GIN (location gin_trgm_ops);
CREATE INDEX idx_courts_coords ON public.courts(latitude, longitude);

-- ─── Bookings ───
CREATE TABLE public.bookings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  court_id        UUID NOT NULL REFERENCES public.courts(id) ON DELETE CASCADE,
  court_name      TEXT NOT NULL,
  date            DATE NOT NULL,
  time_slot       TEXT NOT NULL,
  duration        REAL NOT NULL DEFAULT 1,
  total_amount    REAL NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','confirmed','cancelled','completed')),
  payment_method  TEXT,
  add_ons         JSONB DEFAULT '[]',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bookings_user ON public.bookings(user_id);
CREATE INDEX idx_bookings_court ON public.bookings(court_id);
CREATE INDEX idx_bookings_date ON public.bookings(date);
CREATE INDEX idx_bookings_status ON public.bookings(status);

-- ─── Matches ───
CREATE TABLE public.matches (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id        UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  court_id          UUID NOT NULL REFERENCES public.courts(id) ON DELETE CASCADE,
  court_name        TEXT NOT NULL,
  date              DATE NOT NULL,
  time_slot         TEXT NOT NULL,
  level             TEXT NOT NULL DEFAULT 'beginner',
  gender            TEXT NOT NULL DEFAULT 'any',
  location          TEXT NOT NULL,
  max_players       INTEGER NOT NULL DEFAULT 4,
  current_players   INTEGER NOT NULL DEFAULT 1,
  price_per_person  REAL DEFAULT 0,
  status            TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming','live','completed','cancelled')),
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_matches_date ON public.matches(date);
CREATE INDEX idx_matches_status ON public.matches(status);

-- ─── Match Players ───
CREATE TABLE public.match_players (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id  UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status    TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','declined')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(match_id, user_id)
);

-- ─── Invitations ───
CREATE TABLE public.invitations (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  match_id    UUID REFERENCES public.matches(id) ON DELETE SET NULL,
  court_name  TEXT,
  date        DATE,
  time_slot   TEXT,
  status      TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','declined')),
  message     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_invitations_receiver ON public.invitations(receiver_id);
CREATE INDEX idx_invitations_status ON public.invitations(status);

-- ─── Reviews ───
CREATE TABLE public.reviews (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  court_id  UUID NOT NULL REFERENCES public.courts(id) ON DELETE CASCADE,
  rating    INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment   TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reviews_court ON public.reviews(court_id);

-- ─── Moments ───
CREATE TABLE public.moments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  image_url   TEXT NOT NULL,
  caption     TEXT,
  likes_count INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Payments ───
CREATE TABLE public.payments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id  UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount      REAL NOT NULL,
  method      TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending','completed','failed','refunded')),
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Notifications ───
CREATE TABLE public.notifications (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type      TEXT NOT NULL,
  title     TEXT NOT NULL,
  body      TEXT,
  data      JSONB DEFAULT '{}',
  is_read   BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON public.notifications(user_id, is_read);

-- ─── Row-Level Security ───
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read all, update own
CREATE POLICY "profiles_select_all" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (id = auth.uid());

-- Courts: public read, admin write
CREATE POLICY "courts_select_all" ON public.courts FOR SELECT USING (true);

-- Bookings: users see own, admins see all
CREATE POLICY "bookings_select_own" ON public.bookings FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "bookings_insert_own" ON public.bookings FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "bookings_update_own" ON public.bookings FOR UPDATE USING (user_id = auth.uid());

-- Matches: users see own + public, creators update
CREATE POLICY "matches_select_all" ON public.matches FOR SELECT USING (true);
CREATE POLICY "matches_insert_auth" ON public.matches FOR INSERT WITH CHECK (creator_id = auth.uid());
CREATE POLICY "matches_update_own" ON public.matches FOR UPDATE USING (creator_id = auth.uid());

-- Match Players: users see own
CREATE POLICY "match_players_select_own" ON public.match_players FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "match_players_insert" ON public.match_players FOR INSERT WITH CHECK (user_id = auth.uid());

-- Invitations: see own (sender or receiver)
CREATE POLICY "invitations_select_own" ON public.invitations
  FOR SELECT USING (sender_id = auth.uid() OR receiver_id = auth.uid());
CREATE POLICY "invitations_insert" ON public.invitations FOR INSERT WITH CHECK (sender_id = auth.uid());
CREATE POLICY "invitations_update_receiver" ON public.invitations
  FOR UPDATE USING (receiver_id = auth.uid());

-- Reviews: public read, authenticated insert
CREATE POLICY "reviews_select_all" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "reviews_insert_auth" ON public.reviews FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Moments: public read, own insert
CREATE POLICY "moments_select_all" ON public.moments FOR SELECT USING (true);
CREATE POLICY "moments_insert_own" ON public.moments FOR INSERT WITH CHECK (user_id = auth.uid());

-- Payments: own only
CREATE POLICY "payments_select_own" ON public.payments FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "payments_insert" ON public.payments FOR INSERT WITH CHECK (user_id = auth.uid());

-- Notifications: own only
CREATE POLICY "notifications_select_own" ON public.notifications FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "notifications_update_own" ON public.notifications FOR UPDATE USING (user_id = auth.uid());

-- ─── Functions ───

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, username, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || substr(NEW.id::text, 1, 8)),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: on auth.user create → insert profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update updated_at on profile changes
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();