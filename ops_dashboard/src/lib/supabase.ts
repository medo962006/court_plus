import { createClient, type SupabaseClient } from '@supabase/supabase-js'

/**
 * The dashboard connects to the same Supabase backend as the mobile app.
 * Credentials come from Vite env (VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY).
 * When either is missing we expose a `null` client and the data layer falls
 * back to seeded stub data (see api.ts) so the UI remains fully usable.
 */
const url = import.meta.env.VITE_SUPABASE_URL as string | undefined
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined

export const hasSupabase = Boolean(url && anonKey)

export const supabase: SupabaseClient | null = hasSupabase
  ? createClient(url!, anonKey!)
  : null

export function requireClient(): SupabaseClient {
  if (!supabase) {
    throw new Error(
      'Supabase is not configured. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in ops_dashboard/.env'
    )
  }
  return supabase
}