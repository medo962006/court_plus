// Court+ ops — ingest-events
// Edge Function that buffers granular interaction events from every court+
// app instance into `app_events`. Uses the auto-injected service_role key
// (bypasses RLS for writes).
// Deploy:  supabase functions deploy ingest-events --project-ref <ref> --no-verify-jwt

import { createClient } from 'npm:@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  const url = Deno.env.get('SUPABASE_URL')!
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  const client = createClient(url, serviceKey)

  try {
    const body = await req.json()
    if (!Array.isArray(body?.events) || body.events.length === 0) {
      return new Response(JSON.stringify({ error: 'expected { events: [...] }' }), {
        status: 400,
        headers: { ...cors, 'Content-Type': 'application/json' },
      })
    }

    const rows = body.events.map((e: Record<string, unknown>) => ({
      app_id: String(e.appId ?? 'court+'),
      event: String(e.event ?? 'unknown'),
      props: (e.props ?? {}) as Record<string, unknown>,
      user_id: e.userId ?? null,
      device: e.device ?? null,
      platform: e.platform ?? null,
      app_version: e.appVersion ?? null,
      app_env: e.appEnv ?? null,
    }))

    const { data, error } = await client.from('app_events').insert(rows).select('id')
    if (error) throw error

    return new Response(JSON.stringify({ ok: true, inserted: data?.length ?? rows.length }), {
      status: 201,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: (e as Error).message }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }
})