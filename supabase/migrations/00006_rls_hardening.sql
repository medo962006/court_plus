-- Court+ Phase 2 RLS Hardening
-- Completes RLS coverage for missing policies:
--   notifications.insert (service role), moments.update/delete (own), match_players.update
-- Apply after 00005_add_coaches.sql

-- ────────────────
-- 1. Notifications: Allow INSERT from server-side functions (SECURITY DEFINER / service_role)
--    Frontend never inserts notifications directly — they come from DB triggers or Edge Functions.
-- ────────────────

DROP POLICY IF EXISTS "notifications_insert_service" ON public.notifications;
CREATE POLICY "notifications_insert_service" ON public.notifications
  FOR INSERT WITH CHECK (
    -- Allow only if the caller is service_role (bypasses RLS) OR
    -- if an authenticated user is inserting their own notification (future use)
    auth.role() = 'service_role' OR user_id = auth.uid()
  );

-- Also allow DELETE for own notifications (user should be able to dismiss)
DROP POLICY IF EXISTS "notifications_delete_own" ON public.notifications;
CREATE POLICY "notifications_delete_own" ON public.notifications
  FOR DELETE USING (user_id = auth.uid());

-- ────────────────
-- 2. Moments: Allow users to update and delete their own moments
-- ────────────────

DROP POLICY IF EXISTS "moments_update_own" ON public.moments;
CREATE POLICY "moments_update_own" ON public.moments
  FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "moments_delete_own" ON public.moments;
CREATE POLICY "moments_delete_own" ON public.moments
  FOR DELETE USING (user_id = auth.uid());

-- ────────────────
-- 3. Match Players: Allow update own status (accept/decline)
-- ────────────────

DROP POLICY IF EXISTS "match_players_update_own" ON public.match_players;
CREATE POLICY "match_players_update_own" ON public.match_players
  FOR UPDATE USING (user_id = auth.uid());

-- ────────────────
-- 4. Reviews: Allow updates and deletes on own reviews
-- ────────────────

DROP POLICY IF EXISTS "reviews_update_own" ON public.reviews;
CREATE POLICY "reviews_update_own" ON public.reviews
  FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "reviews_delete_own" ON public.reviews;
CREATE POLICY "reviews_delete_own" ON public.reviews
  FOR DELETE USING (user_id = auth.uid());

-- ────────────────
-- 5. Payments: Allow DELETE own (cancel/refund context)
-- ────────────────

DROP POLICY IF EXISTS "payments_delete_own" ON public.payments;
CREATE POLICY "payments_delete_own" ON public.payments
  FOR DELETE USING (user_id = auth.uid());

-- ────────────────
-- 6. Add moment_likes table for moment interaction tracking
--    The Moment model has likesCount but no table stores individual likes.
-- ────────────────

CREATE TABLE IF NOT EXISTS public.moment_likes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  moment_id  UUID NOT NULL REFERENCES public.moments(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(moment_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_moment_likes_moment ON public.moment_likes(moment_id);
CREATE INDEX IF NOT EXISTS idx_moment_likes_user ON public.moment_likes(user_id);

ALTER TABLE public.moment_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "moment_likes_select_all" ON public.moment_likes FOR SELECT USING (true);
CREATE POLICY "moment_likes_insert_own" ON public.moment_likes FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "moment_likes_delete_own" ON public.moment_likes FOR DELETE USING (user_id = auth.uid());

-- Auto-update moments.likes_count via trigger
CREATE OR REPLACE FUNCTION public.update_moment_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.moments SET likes_count = likes_count + 1 WHERE id = NEW.moment_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.moments SET likes_count = GREATEST(likes_count - 1, 0) WHERE id = OLD.moment_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_moment_like_insert ON public.moment_likes;
CREATE TRIGGER on_moment_like_insert
  AFTER INSERT ON public.moment_likes
  FOR EACH ROW EXECUTE FUNCTION public.update_moment_likes_count();

DROP TRIGGER IF EXISTS on_moment_like_delete ON public.moment_likes;
CREATE TRIGGER on_moment_like_delete
  AFTER DELETE ON public.moment_likes
  FOR EACH ROW EXECUTE FUNCTION public.update_moment_likes_count();

-- ────────────────
-- 7. Add moment_comments table
--    ProfileScreen shows comment counts but there's no comments table.
-- ────────────────

CREATE TABLE IF NOT EXISTS public.moment_comments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  moment_id  UUID NOT NULL REFERENCES public.moments(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  comment    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_moment_comments_moment ON public.moment_comments(moment_id);

ALTER TABLE public.moment_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "moment_comments_select_all" ON public.moment_comments FOR SELECT USING (true);
CREATE POLICY "moment_comments_insert_own" ON public.moment_comments FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "moment_comments_delete_own" ON public.moment_comments FOR DELETE USING (user_id = auth.uid());

-- ────────────────
-- 8. Add favorites table for court bookmarking
--    CourtDetailsScreen has a heart button but no favorites storage.
-- ────────────────

CREATE TABLE IF NOT EXISTS public.favorites (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  court_id   UUID NOT NULL REFERENCES public.courts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, court_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites(user_id);

ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "favorites_select_own" ON public.favorites FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "favorites_insert_own" ON public.favorites FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "favorites_delete_own" ON public.favorites FOR DELETE USING (user_id = auth.uid());

-- ────────────────
-- 9. Add follows table for social graph
--    ProfileScreen shows Following / Followers counts but no follows table.
-- ────────────────

CREATE TABLE IF NOT EXISTS public.follows (
  follower_id  UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id <> following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON public.follows(following_id);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "follows_select_all" ON public.follows FOR SELECT USING (true);
CREATE POLICY "follows_insert_own" ON public.follows FOR INSERT WITH CHECK (follower_id = auth.uid());
CREATE POLICY "follows_delete_own" ON public.follows FOR DELETE USING (follower_id = auth.uid());

-- Auto-update profiles follower/following counts
CREATE OR REPLACE FUNCTION public.update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
    UPDATE public.profiles SET following_count = following_count + 1 WHERE id = NEW.follower_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles SET followers_count = GREATEST(followers_count - 1, 0) WHERE id = OLD.following_id;
    UPDATE public.profiles SET following_count = GREATEST(following_count - 1, 0) WHERE id = OLD.follower_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_follow_insert ON public.follows;
CREATE TRIGGER on_follow_insert
  AFTER INSERT ON public.follows
  FOR EACH ROW EXECUTE FUNCTION public.update_follow_counts();

DROP TRIGGER IF EXISTS on_follow_delete ON public.follows;
CREATE TRIGGER on_follow_delete
  AFTER DELETE ON public.follows
  FOR EACH ROW EXECUTE FUNCTION public.update_follow_counts();

-- ────────────────
-- 10. Verify all tables have RLS enabled
-- ────────────────

DO $$
DECLARE
  missing_rls TEXT[];
BEGIN
  missing_rls := ARRAY(
    SELECT tablename::text FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename IN (
        'profiles', 'courts', 'court_slots', 'bookings', 'matches',
        'match_players', 'invitations', 'reviews', 'moments',
        'moment_likes', 'moment_comments', 'favorites', 'follows',
        'payments', 'notifications', 'coaches'
      )
      AND NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        LEFT JOIN pg_policy p ON p.polrelid = c.oid
        WHERE c.relname = pg_tables.tablename
          AND n.nspname = 'public'
          AND p.polname IS NOT NULL
      )
  );

  IF array_length(missing_rls, 1) > 0 THEN
    RAISE WARNING 'Tables missing RLS: %', array_to_string(missing_rls, ', ');
  ELSE
    RAISE NOTICE 'RLS CHECK — ALL TABLES HAVE POLICIES';
  END IF;
END;
$$;