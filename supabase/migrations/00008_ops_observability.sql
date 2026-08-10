-- Court+ Ops Dashboard — observability, CI/CD tracking & admin foundation
-- Run: supabase db push  (requires project link + DB password)
-- Applies cleanly on empty or existing projects (idempotent).

-- ─── 1. Admin role on profiles ─────────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'user';
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- Helper: is the current caller an admin?
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
$$;

-- ─── 2. system_logs ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.system_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  level       TEXT NOT NULL DEFAULT 'info',
  service     TEXT NOT NULL,
  message     TEXT NOT NULL,
  context     JSONB,
  user_id     UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  app_version TEXT,
  app_env     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_system_logs_level ON public.system_logs(level);
CREATE INDEX IF NOT EXISTS idx_system_logs_created ON public.system_logs(created_at);
ALTER TABLE public.system_logs ENABLE ROW LEVEL SECURITY;
-- Readable for the ops dashboard; writes are performed by Edge Functions via service_role (bypasses RLS).
CREATE POLICY "system_logs_select" ON public.system_logs FOR SELECT TO anon, authenticated USING (true);

-- ─── 3. service_heartbeats ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.service_heartbeats (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  service        TEXT NOT NULL UNIQUE,
  status         TEXT NOT NULL DEFAULT 'healthy',
  last_seen_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  error_rate_pct REAL,
  p95_ms         INT,
  uptime_pct     REAL
);
ALTER TABLE public.service_heartbeats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "heartbeats_select" ON public.service_heartbeats FOR SELECT TO anon, authenticated USING (true);

-- ─── 4. pipeline_runs + pipeline_jobs ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pipeline_runs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_number  INT NOT NULL,
  branch      TEXT,
  event       TEXT NOT NULL DEFAULT 'push',      -- push | pull_request | release | manual
  commit_sha  TEXT,
  commit_msg  TEXT,
  author      TEXT,
  status      TEXT NOT NULL DEFAULT 'queued',     -- queued | in_progress | success | failure | cancelled
  started_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  duration_ms INT,
  trigger     TEXT
);
ALTER TABLE public.pipeline_runs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pipeline_runs_select" ON public.pipeline_runs FOR SELECT TO anon, authenticated USING (true);

CREATE TABLE IF NOT EXISTS public.pipeline_jobs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id       UUID NOT NULL REFERENCES public.pipeline_runs(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'queued',
  started_at   TIMESTAMPTZ,
  finished_at  TIMESTAMPTZ,
  logs_url     TEXT,
  coverage_pct REAL,
  artifact_url TEXT,
  version      TEXT
);
CREATE INDEX IF NOT EXISTS idx_pipeline_jobs_run ON public.pipeline_jobs(run_id);
ALTER TABLE public.pipeline_jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "pipeline_jobs_select" ON public.pipeline_jobs FOR SELECT TO anon, authenticated USING (true);

-- ─── 5. request_metrics (chart series, appended by edge functions) ─────────
CREATE TABLE IF NOT EXISTS public.request_metrics (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label       TEXT NOT NULL,              -- e.g. "14:00"
  ts          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  requests    INT NOT NULL DEFAULT 0,
  errors      INT NOT NULL DEFAULT 0,
  latency_p95 INT
);
ALTER TABLE public.request_metrics ENABLE ROW LEVEL SECURITY;
CREATE POLICY "request_metrics_select" ON public.request_metrics FOR SELECT TO anon, authenticated USING (true);

-- ─── 6. admin_audit_log ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id     UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  action       TEXT NOT NULL,             -- create | update | delete
  target_table TEXT NOT NULL,
  target_id    UUID,
  before_val   JSONB,
  after_val    JSONB,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "admin_audit_log_select" ON public.admin_audit_log FOR SELECT TO authenticated USING (public.is_admin());

-- ─── 7. system_overview view (single aggregate row for the dashboard) ──────
CREATE OR REPLACE VIEW public.system_overview AS
SELECT
  (SELECT count(*) FROM public.service_heartbeats)                          AS service_count,
  (SELECT count(*) FROM public.service_heartbeats WHERE status = 'down')    AS services_down,
  (SELECT count(*) FROM public.courts    WHERE is_active)                   AS active_courts,
  (SELECT count(*) FROM public.coaches   WHERE is_active)                   AS active_coaches,
  (SELECT count(*) FROM public.profiles)                                    AS users,
  (SELECT count(*) FROM public.bookings
     WHERE created_at >= now() - interval '24 hours')                       AS bookings_today,
  (SELECT round(
       (1 - (COALESCE(sum(errors),0)::decimal / NULLIF(COALESCE(sum(requests),0),0))) * 100, 1)
     FROM public.request_metrics WHERE ts >= now() - interval '24 hours')   AS success_rate_pct,
  (SELECT max(latency_p95) FROM public.request_metrics
     WHERE ts >= now() - interval '24 hours')                               AS p95_latency_ms,
  (SELECT jsonb_build_object(
        'version',
        (SELECT j.version FROM public.pipeline_jobs j
          WHERE j.run_id = pr.id AND j.version IS NOT NULL
          ORDER BY j.finished_at DESC NULLS LAST LIMIT 1),
        'at', pr.finished_at)
      FROM public.pipeline_runs pr
     WHERE pr.event = 'release' AND pr.status = 'success'
     ORDER BY pr.finished_at DESC LIMIT 1)                                    AS last_deploy,
  (SELECT count(*) FROM public.system_logs
     WHERE level = 'error' AND created_at >= now() - interval '24 hours')   AS errors_last_24h;

-- ─── 8. Admin write access on courts & coaches (security-sensitive) ────────
-- Existing public read stays; only admins may create/update.
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'courts' AND policyname = 'courts_admin_write'
  ) THEN
    CREATE POLICY "courts_admin_write" ON public.courts
      FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'coaches' AND policyname = 'coaches_admin_write'
  ) THEN
    CREATE POLICY "coaches_admin_write" ON public.coaches
      FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
  END IF;
END $$;

-- ─── 9. Scheduled maintenance (pg_cron) ────────────────────────────────────
-- Run release_stale_locks every 15 minutes + prune old logs nightly.
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;

SELECT cron.schedule('release-stale-locks', '*/15 * * * *',
  'SELECT public.release_stale_locks()');
SELECT cron.schedule('prune-system-logs', '0 3 * * *',
  $$DELETE FROM public.system_logs WHERE created_at < now() - interval '30 days'$$);