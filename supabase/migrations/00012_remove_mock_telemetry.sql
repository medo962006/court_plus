-- One-time cleanup: remove all seeded/mock telemetry so the dashboard reflects
-- only real app activity. No real usage exists yet, so every app_event is mock.
-- Writes bypass RLS (migrations run as postgres).

delete from public.app_events;
delete from public.system_logs where message like '%(ops verify)%';