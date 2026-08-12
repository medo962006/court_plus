-- Court+ ops — app_events
-- Granular interaction telemetry from every court+ app instance in the
-- userbase (screen views, bookings, payments, auth, etc.), so the ops
-- dashboard can show near-real-time activity.

create table if not exists public.app_events (
  id uuid primary key default gen_random_uuid(),
  app_id text not null default 'court+',
  event text not null,
  props jsonb not null default '{}'::jsonb,
  user_id uuid null,
  device text null,
  platform text null,
  app_version text null,
  app_env text null,
  created_at timestamptz not null default now()
);

create index if not exists app_events_created_at_idx on public.app_events (created_at desc);
create index if not exists app_events_event_idx on public.app_events (event);

alter table public.app_events enable row level security;

-- Writes go through the ingest-events Edge Function (service_role, bypasses
-- RLS). Signed-in ops users may read the feed.
create policy "authenticated read app_events"
  on public.app_events for select
  using (auth.role() = 'authenticated');