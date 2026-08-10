// Court+ ops — create-admin
// Ensures a dedicated ops-admin auth user exists and is promoted to
// `profiles.role = 'admin'`, so the dashboard's "Quick admin sign-in" button
// can authenticate without typing credentials.
//
// Idempotent: if the user already exists it just re-promotes the profile.
// Credentials come from env (mirror the client's VITE_QUICK_ADMIN_*):
//   QUICK_ADMIN_EMAIL, QUICK_ADMIN_PASSWORD, QUICK_ADMIN_NAME (optional)
// Deploy:  supabase functions deploy create-admin --project-ref <ref> --no-verify-jwt
//          supabase secrets set QUICK_ADMIN_EMAIL=<e> QUICK_ADMIN_PASSWORD=<p> --env ...

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const ADMIN_EMAIL = Deno.env.get('QUICK_ADMIN_EMAIL') ?? 'admin@courtplus.app'
const ADMIN_PASSWORD = Deno.env.get('QUICK_ADMIN_PASSWORD') ?? ''
const ADMIN_NAME = Deno.env.get('QUICK_ADMIN_NAME') ?? 'Ops Admin'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })
  if (!ADMIN_PASSWORD) {
    return new Response(JSON.stringify({ error: 'QUICK_ADMIN_PASSWORD not set' }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { autoRefreshToken: false, persistSession: false } }
  )

  let userId: string | undefined
  const { data, error } = await supabase.auth.admin.createUser({
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
    email_confirm: true,
    user_metadata: { full_name: ADMIN_NAME },
  })
  if (data?.user) {
    userId = data.user.id
  } else if (error) {
    // User already exists — look it up and (re)promote it.
    const { data: users } = await supabase.auth.admin.listUsers({ perPage: 1000 })
    userId = users?.users.find((u) => u.email?.toLowerCase() === ADMIN_EMAIL.toLowerCase())?.id
  }

  if (!userId) {
    return new Response(JSON.stringify({ error: error?.message ?? 'could not resolve user' }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }

  // Self-heal: always force the admin's password to the env value so the
  // "Quick admin sign-in" button works even if a stale hash is stored.
  const { error: pwErr } = await supabase.auth.admin.updateUserById(userId, {
    password: ADMIN_PASSWORD,
    email_confirm: true,
  })
  if (pwErr) {
    return new Response(JSON.stringify({ error: pwErr.message }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }

  const { error: upd } = await supabase
    .from('profiles')
    .update({ role: 'admin', full_name: ADMIN_NAME })
    .eq('id', userId)

  if (upd) {
    return new Response(JSON.stringify({ error: upd.message }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    })
  }

  return new Response(JSON.stringify({ ok: true, email: ADMIN_EMAIL }), {
    status: 200,
    headers: { ...cors, 'Content-Type': 'application/json' },
  })
})