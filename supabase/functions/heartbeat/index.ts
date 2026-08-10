// Court+ ops — heartbeat
// Edge Function that upserts a service_heartbeats row so the dashboard can
// show per-service liveness / uptime.
// Deploy:  supabase functions deploy heartbeat --project-ref <ref> --no-verify-jwt

import { createClient } from 'npm:@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  const client = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  try {
    const body = await req.json()
    if (!body?.service) {
      return new Response(JSON.stringify({ error: 'expected { service, status, ... }' }), {
        status: 400,
        headers: { ...cors, 'Content-Type': 'application/json' },
      })
    }

    const row = {
      service: body.service,
      status: body.status ?? 'healthy',
      last_seen_at: new Date().toISOString(),
      error_rate_pct: body.errorRatePct ?? body.error_rate_pct ?? null,
      p95_ms: body.p95Ms ?? body.p95_ms ?? null,
      uptime_pct: body.uptimePct ?? body.uptime_pct ?? null,
    }

    const { error } = await client
      .from('service_heartbeats')
      .upsert(row, { onConflict: 'service' })

    if (error) throw error
    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: (e as Error).message }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }
})