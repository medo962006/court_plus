// simulate-usage — toggleable realistic usage for the ops dashboard.
//
// Modes (auth-gated to a signed-in admin session; CORS-enabled):
//   {mode:'start'}  backfill 24h of metrics + a batch of activity (+ bookings)
//   {mode:'tick'}   stream a live burst of activity / metrics for "now"
//   {mode:'stop'}   delete every simulated row (sim=true) → back to accurate data
//
// All generated rows carry sim=true so toggle-OFF restores only real data.
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const URL = Deno.env.get("SUPABASE_URL")!;
const SRV = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const HOUR_W = [1, 2, 3, 4, 2, 2, 4, 8, 14, 18, 17, 15, 12, 12, 14, 18, 22, 24, 20, 14, 9, 5, 3, 2];
const SEARCHES = ["padel", "tennis", "football", "basketball", "near me", "night", "indoor", "coach", "clay"];
const DEV = ["iPhone 13", "iPhone 14 Pro", "Samsung S23", "Pixel 7", "Xiaomi 13T", "iPhone SE"];
const SCREENS = ["home", "explore", "courts", "coaches", "search"];
const SLOTS = ["08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"];

const rand = (n: number) => Math.floor(Math.random() * n);
const pick = <T,>(a: T[]): T => a[rand(a.length)];

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jwtRole(token: string): { role: string; exp: number } | null {
  try {
    const payload = token.split(".")[1];
    const b64 = payload.replace(/-/g, "+").replace(/_/g, "/")
      .padEnd(Math.ceil(payload.length / 4) * 4, "=");
    const json = JSON.parse(atob(b64));
    return { role: String(json.role ?? ""), exp: Number(json.exp ?? 0) };
  } catch {
    return null;
  }
}

function chunk<T>(a: T[], n: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < a.length; i += n) out.push(a.slice(i, i + n));
  return out;
}

async function insertAll(service: ReturnType<typeof createClient>, table: string, rows: unknown[]): Promise<number> {
  let n = 0;
  for (const c of chunk(rows, 800)) {
    const { error } = await service.from(table).insert(c as never);
    if (error) throw new Error(`${table}: ${error.message}`);
    n += c.length;
  }
  return n;
}

interface Court { id: string; name: string; price_per_hour?: number }
interface Coach { id: string; full_name: string; name?: string }

function genEvents(count: number, minutesBack: number, courts: Court[], coaches: Coach[]): Record<string, unknown>[] {
  const rows: Record<string, unknown>[] = [];
  const now = Date.now();
  for (let i = 0; i < count; i++) {
    const t = new Date(now - Math.random() * minutesBack * 60e3).toISOString();
    const platform = Math.random() < 0.5 ? "ios" : "android";
    const r = Math.random();
    let event: string, props: Record<string, unknown>;
    if (r < 0.4) {
      event = "screen_open"; props = { screen: pick(SCREENS) };
    } else if (r < 0.72 && courts.length) {
      const c = pick(courts); event = "court_viewed"; props = { court: c.name, courtId: c.id };
    } else if (r < 0.82 && coaches.length) {
      const ch = pick(coaches); event = "coach_viewed"; props = { coach: ch.full_name ?? ch.name, coachId: ch.id };
    } else if (r < 0.93) {
      event = "search_used"; props = { query: pick(SEARCHES) };
    } else if (courts.length) {
      const c = pick(courts); event = "booking_created";
      props = { court: c.name, courtId: c.id, date: t.slice(0, 10), timeSlot: pick(SLOTS), duration: 1, amount: Math.round((c.price_per_hour || 150) * 1) };
    } else {
      event = "screen_open"; props = { screen: "home" };
    }
    rows.push({ event, props, user_id: crypto.randomUUID(), device: pick(DEV), platform, app_version: "1.0.0", app_env: "production", created_at: t, sim: true });
  }
  return rows;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: corsHeaders });

  const bearer = (req.headers.get("authorization") || "").replace(/^Bearer\s+/i, "");
  const jwt = jwtRole(bearer);
  if (!jwt || jwt.role !== "authenticated" || jwt.exp < Math.floor(Date.now() / 1000)) {
    return new Response("Unauthorized", { status: 401, headers: corsHeaders });
  }

  try {
    const { mode } = await req.json().catch(() => ({} as { mode?: string }));
    const service = createClient(URL, SRV);
    const now = Date.now();
    const out: Record<string, unknown> = { ok: true, mode };

    if (mode === "stop") {
      const dels: Record<string, number> = {};
      for (const table of ["app_events", "request_metrics", "system_logs", "bookings"]) {
        const { count, error } = await service.from(table)
          .delete({ count: "exact" }).eq("sim", true);
        if (error) throw new Error(`${table}: ${error.message}`);
        dels[table] = Number(count ?? 0);
      }
      out.deleted = dels;
      return new Response(JSON.stringify(out), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });
    }

    const [courtsR, coachesR, profsR] = await Promise.all([
      service.from("courts").select("id,name,price_per_hour"),
      service.from("coaches").select("id,full_name,name"),
      service.from("profiles").select("id").limit(5),
    ]);
    const courts = (courtsR.data ?? []) as Court[];
    const coaches = (coachesR.data ?? []) as Coach[];
    const profs = (profsR.data ?? []) as { id: string }[];

    if (mode === "start") {
      // 24h metrics backfill → chart shape + success rate / p95
      const metrics: Record<string, unknown>[] = [];
      for (let h = 23; h >= 0; h--) {
        const t = new Date(now - h * 3600e3);
        const hh = t.getHours();
        const requests = Math.round((HOUR_W[hh] ?? 4) * 620 + Math.random() * 2200);
        const errors = Math.round(requests * (0.004 + Math.random() * 0.02));
        metrics.push({ label: `${String(hh).padStart(2, "0")}:00`, ts: t.toISOString(), requests, errors, latency_p95: 120 + rand(400), sim: true });
      }
      const m = await insertAll(service, "request_metrics", metrics);

      const events = genEvents(560, 90, courts, coaches);
      const e = await insertAll(service, "app_events", events);

      // a few simulated logs (a couple of errors so ERRORS(24h) is non-zero)
      const logs = [
        { level: "info", service: "edge-functions", message: "heartbeat ok", context: { ok: true }, created_at: new Date(now - 60e3).toISOString(), sim: true },
        { level: "info", service: "mobile-app", message: "session refresh", created_at: new Date(now - 30e3).toISOString(), sim: true },
        { level: "warn", service: "mobile-app", message: "slow sync (1.2s) on 3% of requests", context: { p95: 1180 }, created_at: new Date(now - 20e3).toISOString(), sim: true },
        { level: "error", service: "edge-functions", message: "timeout calling rate-limiter", context: { fn: "ingest-events" }, created_at: new Date(now - 15e3).toISOString(), sim: true },
        { level: "error", service: "push-notifications", message: "APNs delivery rejected (device token)", created_at: new Date(now - 8e3).toISOString(), sim: true },
      ];
      const l = await insertAll(service, "system_logs", logs);

      // a few bookings so bookings_today ticks
      let b = 0;
      if (courts.length && profs.length) {
        const rows: Record<string, unknown>[] = [];
        for (let i = 0; i < 11; i++) {
          const c = pick(courts); const p = pick(profs);
          const t = new Date(now - Math.random() * 20 * 3600e3);
          rows.push({ user_id: p.id, court_id: c.id, court_name: c.name, date: t.toISOString().slice(0, 10), time_slot: pick(SLOTS), duration: 1, total_amount: Math.round((c.price_per_hour || 150) * 1), status: "pending", created_at: t.toISOString(), sim: true });
        }
        b = await insertAll(service, "bookings", rows);
      }

      Object.assign(out, { users: 10000, requestMetrics: m, events: e, logs: l, bookings: b });
    } else if (mode === "tick") {
      const burst = 70 + rand(60);
      const requests = 260 + rand(540);
      const errors = Math.round(requests * (0.004 + Math.random() * 0.02));
      const t = new Date().toISOString();
      const mm = await insertAll(service, "request_metrics",
        [{ ts: t, label: t.slice(11, 16), requests, errors, latency_p95: 110 + rand(390), sim: true }]);

      const ee = await insertAll(service, "app_events", genEvents(burst, 0.6, courts, coaches));

      const logs = [
        { level: Math.random() < 0.08 ? "error" : "info", service: "mobile-app", message: "live sync", context: { n: burst }, created_at: t, sim: true },
      ];
      const ll = await insertAll(service, "system_logs", logs);

      let b = 0;
      if (Math.random() < 0.5 && courts.length && profs.length) {
        const c = pick(courts); const p = pick(profs);
        b = await insertAll(service, "bookings", [{ user_id: p.id, court_id: c.id, court_name: c.name, date: t.slice(0, 10), time_slot: pick(SLOTS), duration: 1, total_amount: Math.round((c.price_per_hour || 150) * 1), status: "pending", created_at: t, sim: true }]);
      }

      Object.assign(out, { events: ee, requestMetrics: mm, logs: ll, bookings: b, activeUsers: Math.round(7000 * (0.9 + Math.random() * 0.2)) });
    } else {
      out.ok = false; out.error = `unknown mode: ${mode}`;
      return new Response(JSON.stringify(out), { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } });
    }

    return new Response(JSON.stringify(out), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ ok: false, error: msg }), { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } });
  }
});
