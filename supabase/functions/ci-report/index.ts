// Court+ ops — ci-report
// Receives GitHub Actions run status and records it into pipeline_runs / pipeline_jobs
// so the dashboard can track the full CI/CD pipeline live.
//
// Optional shared-secret auth: run  supabase secrets set CI_REPORT_SECRET=<token>  to
// require it. While unset, the function accepts requests so CI wiring can land first.
//
// Deploy:  supabase functions deploy ci-report --project-ref <ref> --no-verify-jwt

import { createClient } from 'npm:@supabase/supabase-js@2'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

interface JobInput {
  name: string
  status: string
  coveragePct?: number
  artifactUrl?: string
  logsUrl?: string
  version?: string
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  // Shared-secret guard (degraded to open if not configured yet).
  const secret = Deno.env.get('CI_REPORT_SECRET')
  if (secret) {
    const provided = req.headers.get('authorization')?.replace(/^Bearer\s+/i, '')
    if (provided !== secret) {
      return new Response(JSON.stringify({ error: 'unauthorized' }), {
        status: 401,
        headers: { ...cors, 'Content-Type': 'application/json' },
      })
    }
  }

  const client = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  try {
    const body = await req.json()

    // ── Run upsert ─────────────────────────────────────────────────────────
    const runId = body?.runId ?? crypto.randomUUID()
    const run = {
      id: runId,
      run_number: body.runNumber ?? 0,
      branch: body.branch ?? 'main',
      event: body.event ?? 'push',
      commit_sha: body.commitSha ?? null,
      commit_msg: body.commitMsg ?? null,
      author: body.author ?? null,
      status: body.status ?? 'queued',
      started_at: body.startedAt ?? new Date().toISOString(),
      finished_at: body.finishedAt ?? (body.status ? new Date().toISOString() : null),
      duration_ms: body.durationMs ?? null,
    }

    const { error: runErr } = await client.from('pipeline_runs').upsert(run, { onConflict: 'id' })
    if (runErr) throw runErr

    // ── Jobs ───────────────────────────────────────────────────────────────
    if (Array.isArray(body.jobs)) {
      const jobs = (body.jobs as JobInput[])
        .filter((j) => j?.name)
        .map((j) => ({
          run_id: runId,
          name: j.name,
          status: j.status ?? 'success',
          coverage_pct: j.coveragePct ?? null,
          artifact_url: j.artifactUrl ?? null,
          logs_url: j.logsUrl ?? null,
          version: j.version ?? null,
        }))
      if (jobs.length > 0) {
        const { error: jobsErr } = await client.from('pipeline_jobs').upsert(
          jobs.map((j) => ({ ...j, id: crypto.randomUUID() })),
          { onConflict: 'id' }
        )
        if (jobsErr) throw jobsErr
      }
    }

    return new Response(JSON.stringify({ ok: true, runId }), {
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