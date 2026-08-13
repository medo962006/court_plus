import { ChartLine, LockKey, ShieldCheck, SignOut, Sparkle } from '@phosphor-icons/react'
import { useState } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from '../lib/auth'
import { hasSupabase } from '../lib/supabase'

export default function Login() {
  const { session, loading, signIn, signOut } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  const quickEmail = import.meta.env.VITE_QUICK_ADMIN_EMAIL as string | undefined
  const quickPass = import.meta.env.VITE_QUICK_ADMIN_PASSWORD as string | undefined
  const quickReady = Boolean(quickEmail && quickPass)

  if (loading) {
    return (
      <div className="grid h-full w-full place-items-center text-sm text-muted">Loading…</div>
    )
  }
  if (!hasSupabase || (hasSupabase && session && session.user)) {
    return <Navigate to="/overview" replace />
  }

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    setBusy(true)
    setError(null)
    const err = await signIn(email, password)
    setBusy(false)
    if (err) setError(err)
  }

  const clear = async () => {
    await signOut()
  }

  const quickSignIn = async () => {
    if (!quickEmail || !quickPass) return
    setBusy(true)
    setError(null)
    const err = await signIn(quickEmail, quickPass)
    setBusy(false)
    if (err) setError(err)
  }

  return (
    <div className="grid min-h-full place-items-center bg-surface p-6">
      <div className="w-full max-w-sm rounded-xl border border-line bg-panel p-6 shadow-sm">
        <div className="mb-6 flex items-center gap-2.5">
          <div className="grid h-9 w-9 place-items-center rounded-lg bg-brand-600 text-white">
            <ChartLine size={20} weight="bold" />
          </div>
          <div className="text-lg font-bold text-ink">Court+ Ops</div>
        </div>
        <p className="mb-4 inline-flex items-center gap-2 text-xs font-medium text-muted">
          <ShieldCheck size={15} /> Admin sign-in
        </p>
        <form onSubmit={submit}>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Email</span>
            <input
              className="input"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@courtplus.app"
              required
            />
          </label>
          <label className="mt-4 block">
            <span className="mb-1 block text-xs font-semibold text-muted">Password</span>
            <div className="relative">
              <input
                className="input pr-10"
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
              />
              <LockKey size={16} className="absolute top-1/2 right-3 -translate-y-1/2 text-muted" />
            </div>
          </label>
          {error && (
            <div className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-xs font-medium text-red-600">
              {error}
            </div>
          )}
          <button className="btn-primary mt-5 w-full" type="submit" disabled={busy}>
            {busy ? 'Signing in…' : 'Sign in'}
          </button>
        </form>
        {quickReady && (
          <>
            <div className="my-4 flex items-center gap-3 text-[11px] font-medium text-muted">
              <span className="h-px flex-1 bg-line" /> or{' '}
              <span className="h-px flex-1 bg-line" />
            </div>
            <button
              type="button"
              onClick={quickSignIn}
              disabled={busy}
              className="btn-ghost w-full"
            >
              <Sparkle size={16} weight="bold" /> Quick admin sign-in
            </button>
          </>
        )}
        {hasSupabase && session && (
          <button onClick={clear} className="btn-ghost mt-3 w-full">
            <SignOut size={16} /> Sign out
          </button>
        )}
        <div className="mt-5 border-t border-line pt-3 text-center text-[11px] text-muted">
          Court+ Ops Dashboard · v1.0 · Protected admin area
        </div>
      </div>
    </div>
  )
}