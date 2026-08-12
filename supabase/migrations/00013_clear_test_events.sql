-- One-time cleanup: clear the ad-hoc telemetry test events fired by the
-- EventTracker integration probe so the dashboard feed reflects only real
-- app usage. No real users exist yet.

delete from public.app_events;