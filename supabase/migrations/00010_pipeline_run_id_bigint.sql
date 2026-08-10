-- Court+ Ops — store GitHub workflow run ids (bigint) as pipeline_runs.id.
-- ci-report sends the GitHub Actions run id (e.g. 31413237604), which is a
-- bigint, but pipeline_runs.id was UUID. Re-type id (and the FK in
-- pipeline_jobs) to bigint so CI reports persist. system_overview references
-- these columns, so it is dropped and recreated around the change.
-- Apply:  supabase db push

DROP VIEW IF EXISTS public.system_overview;

-- Drop the FK so we can safely re-type the referenced column.
ALTER TABLE ONLY public.pipeline_jobs
  DROP CONSTRAINT IF EXISTS pipeline_jobs_run_id_fkey;

-- id becomes the GitHub run id; no generated default (CI supplies it).
ALTER TABLE public.pipeline_runs
  ALTER COLUMN id DROP DEFAULT;

ALTER TABLE public.pipeline_runs
  ALTER COLUMN id TYPE BIGINT
  USING (CASE WHEN id::text ~ '^[0-9]+$' THEN id::text::bigint ELSE NULL END);

ALTER TABLE public.pipeline_jobs
  ALTER COLUMN run_id TYPE BIGINT
  USING (run_id::text::bigint);

-- Recreate the FK on the new bigint types.
ALTER TABLE ONLY public.pipeline_jobs
  ADD CONSTRAINT pipeline_jobs_run_id_fkey
  FOREIGN KEY (run_id) REFERENCES public.pipeline_runs(id) ON DELETE CASCADE;

-- Recreate system_overview (same definition as 00008).
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