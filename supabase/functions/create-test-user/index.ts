// Court+ Test User Auto-Creation Edge Function
// Always returns 200 — best-effort user creation. If the user already exists
// (e.g. on repeat clicks), the client proceeds to sign-in regardless.
// Deploy: supabase functions deploy create-test-user --no-verify-jwt

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-ops-bootstrap-secret',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const TEST_EMAIL = 'testuser@courtplus.com'
const TEST_PASSWORD = 'TestPassword123!'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })

  // Release hardening: creating auth users is privileged — require the shared
  // bootstrap secret header. 401 unless it matches.
  const secret = Deno.env.get('BOOTSTRAP_SECRET')
  if (secret && req.headers.get('x-ops-bootstrap-secret') !== secret) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { autoRefreshToken: false, persistSession: false } }
  )

  // Best-effort: attempt to create the user, silently handle duplicates
  const { error } = await supabase.auth.admin.createUser({
    email: TEST_EMAIL,
    password: TEST_PASSWORD,
    email_confirm: true,
    user_metadata: { full_name: 'Test User' },
  })

  // Always return 200 — client signs in regardless of create outcome
  return new Response(
    JSON.stringify({
      success: true,
      created: !error,
      message: error ? 'User already exists' : 'User created',
    }),
    { headers: { 'Content-Type': 'application/json', ...cors } }
  )
})
