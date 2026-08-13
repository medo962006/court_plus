-- Court+ Ops — simulate-usage toggle support.
-- Tag generated rows so the dashboard can stream realistic 10k-user activity
-- while the simulate toggle is ON, then delete exactly those rows on toggle-OFF,
-- falling back to only accurate (real) data.
-- Apply:  supabase db push

ALTER TABLE public.app_events      ADD COLUMN IF NOT EXISTS sim BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.request_metrics ADD COLUMN IF NOT EXISTS sim BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.system_logs     ADD COLUMN IF NOT EXISTS sim BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.bookings        ADD COLUMN IF NOT EXISTS sim BOOLEAN NOT NULL DEFAULT false;

-- Clean slate: the existing app_events rows are 100% simulation/test noise from
-- earlier testing (no real users yet), and request_metrics is empty. Drop both so
-- the "accurate" baseline truly starts at zero.
DELETE FROM public.app_events;
DELETE FROM public.request_metrics;

CREATE INDEX IF NOT EXISTS idx_app_events_created_at ON public.app_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_request_metrics_ts    ON public.request_metrics(ts);
