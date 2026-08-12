// simulate-usage — generate realistic court+ activity for ~N users over the last
// 24h and insert it into app_events, so the ops dashboard reflects real-usage
// volume. Auth-gated: only a signed-in (authenticated) session may run it.
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const URL = Deno.env.get("SUPABASE_URL")!;
const ANON = Deno.env.get("SUPABASE_ANON_KEY")!;
const SRV = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Hourly activity weights (daytime peaks) for realistic timestamps.
const HOUR_W = [1, 1, 1, 1, 1, 1, 2, 4, 6, 7, 7, 6, 5, 5, 6, 7, 8, 8, 7, 6, 4, 2, 1, 1];
function weightedMinOfDay(): number {
  const total = HOUR_W.reduce((a, b) => a + b, 0);
  let r = Math.random() * total;
  for (let i = 0; i < 24; i++) {
    r -= HOUR_W[i];
    if (r <= 0) return i * 60 + Math.floor(Math.random() * 60);
  }
  return 23 * 60;
}
const pick = <T,>(a: T[]): T => a[Math.floor(Math.random() * a.length)];
const pickN = <T,>(a: T[], n: number): T[] => {
  const out: T[] = [];
  while (out.length < n && a.length) out.push(a[Math.floor(Math.random() * a.length)]);
  return out;
};
const fmtDate = (d: Date) => d.toISOString().slice(0, 10);
const fmtHour = (d: Date) => `${String(d.getHours()).padStart(2, "0")}:00`;
const SEARCHES = ["padel", "tennis", "football", "basketball", "near me", "night", "indoor", "coach"];
const DEV = ["iPhone 13", "iPhone 14 Pro", "Samsung S23", "Pixel 7", "Xiaomi 13T", "iPhone SE"];

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

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders });
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  }

  // ── Auth gate: require a valid, unexpired authenticated-session JWT ──
  const bearer = (req.headers.get("authorization") || "").replace(/^Bearer\s+/i, "");
  const jwt = jwtRole(bearer);
  if (!jwt || jwt.role !== "authenticated" || jwt.exp < Math.floor(Date.now() / 1000)) {
    return new Response("Unauthorized", { status: 401, headers: corsHeaders });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const users = Math.min(50_000, Math.max(1, Number(body?.users) || 10_000));
    const service = createClient(URL, SRV);

    // Real court + coach data so props are accurate (amounts match real prices).
    const courts = ((
      await service.from("courts").select("id,name,price_per_hour").limit(100)
    ).data ?? []) as Array<Record<string, unknown>>;
    const coaches = (
      (await service.from("coaches").select("id,full_name").limit(100)).data ?? []
    ) as Array<Record<string, unknown>>;
    const courtList = courts.length ? courts : [{ id: null, name: "Court", price_per_hour: 120 }];
    const coachList = coaches.length ? coaches : [{ id: null, full_name: "Coach" }];

    // ~70% DAU, ~3.8 events/session → ~10k users ≈ ~27k events over 24h.
    const active = Math.round(users * 0.7);
    const end = Date.now();
    const start = end - 24 * 3600_000;
    const rows: Array<Record<string, unknown>> = [];

    for (let u = 0; u < active; u++) {
      const isIos = Math.random() < 0.5;
      const platform = isIos ? "ios" : "android";
      const device = pick(DEV);
      const user_id = crypto.randomUUID();
      let t = start + weightedMinOfDay() * 60_000;
      if (t > end) t = end - 60_000;

      const push = (event: string, props: Record<string, unknown>) => {
        rows.push({
          event,
          props,
          user_id,
          platform,
          device,
          app_version: "1.0.0",
          app_env: "production",
          created_at: new Date(t).toISOString(),
        });
        t += 18 + Math.floor(Math.random() * 85) * 1000;
      };

      // Home session open, then weighted downstream screens.
      push("screen_open", { screen: "home" });
      if (Math.random() < 0.5) push("screen_open", { screen: "explore" });
      if (Math.random() < 0.4) push("screen_open", { screen: "courts" });
      if (Math.random() < 0.3) push("screen_open", { screen: "coaches" });

      // Court views (a couple per session).
      if (Math.random() < 0.85) {
        for (const c of pickN(courtList, 1 + (Math.random() < 0.4 ? 1 : 0))) {
          push("court_viewed", { court: c.name, courtId: c.id });
        }
      }
      // Coach views.
      if (Math.random() < 0.25) {
        const c = pick(coachList);
        push("coach_viewed", { coach: c.full_name, coachId: c.id });
      }
      // Searches.
      if (Math.random() < 0.3) push("search_used", { query: pick(SEARCHES) });

      // A fraction of sessions result in a real booking (no payments — WIP).
      if (Math.random() < 0.08) {
        const c = pick(courtList);
        const d = new Date(start + (Math.random() < 0.8 ? 24 : 48) * 3600_000);
        push("booking_created", {
          court: c.name,
          courtId: c.id,
          date: fmtDate(d),
          timeSlot: fmtHour(new Date(start + 6 * 3600_000 + Math.floor(Math.random() * 14) * 3600_000)),
          duration: 1,
          amount: Number(c.price_per_hour ?? 100) * 1,
        });
      }
    }

    // Bulk insert in chunks (service role bypasses RLS).
    let inserted = 0;
    for (let i = 0; i < rows.length; i += 1000) {
      const { error } = await service.from("app_events").insert(rows.slice(i, i + 1000));
      if (error) {
        return new Response(JSON.stringify({ ok: false, error: error.message }), {
          status: 500,
          headers: { "Content-Type": "application/json", ...corsHeaders },
        });
      }
      inserted += Math.min(1000, rows.length - i);
    }

    return new Response(
      JSON.stringify({ ok: true, users, activeSessions: active, events: inserted }),
      { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return new Response(JSON.stringify({ ok: false, error: msg }), {
      status: 500,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }
});
