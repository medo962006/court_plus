// Court+ ops — ingest-logs
// Edge Function that buffers client/app log batches into `system_logs`.
// Uses the auto-injected service_role key (bypasses RLS for writes).
// Deploy:  supabase functions deploy ingest-logs --project-ref <ref> --no-verify-jwt

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
    if (!Array.isArray(body?.logs) || body.logs.length === 0) {
      return new Response(JSON.stringify({ error: 'expected { logs: [...] }' }), {
        status: 400,
        headers: { ...cors, 'Content-Type': 'application/json' },
      })
    }

    const rows = body.logs.map((l: Record<string, unknown>) => ({
      level: l.level ?? 'info',
      service: l.service ?? 'unknown',
      message: String(l.message ?? ''),
      context: l.context ?? null,
      user_id: l.userId ?? null,
      app_version: l.appVersion ?? null,
      app_env: l.appEnv ?? null,
    }))

    const { data, error } = await client.from('system_logs').insert(rows).select('id')
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