import { Bell, Moon, Rocket, SignOut, SpinnerGap, Wrench } from '@phosphor-icons/react'
import { useState } from 'react'
import { useAuth } from '../lib/auth'
import { hasSupabase } from '../lib/supabase'
import { api } from '../lib/api'

export default function Topbar({ title }: { title: string }) {
  const { profile, isAdmin, signOut } = useAuth()
  const [simulating, setSimulating] = useState(false)
  const [simNote, setSimNote] = useState<string | null>(null)

  async function runSimulation() {
    if (simulating) return
    setSimulating(true)
    setSimNote(null)
    const res = await api.simulateUsage(10000)
    setSimulating(false)
    setSimNote(res.ok ? `+${(res.events ?? 0).toLocaleString()} events` : 'sim failed')
    setTimeout(() => setSimNote(null), 4000)
  }

  return (
    <header className="flex h-16 shrink-0 items-center justify-between border-b border-line bg-panel px-6">
      <div className="flex items-center gap-3">
        <h1 className="text-lg font-bold text-ink">{title}</h1>
      </div>
      <div className="flex items-center gap-4">
        <span
          className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ${
            hasSupabase ? 'bg-brand-50 text-brand-700' : 'bg-amber-50 text-amber-700'
          }`}
        >
          <span className={`h-1.5 w-1.5 rounded-full ${hasSupabase ? 'bg-brand-500' : 'bg-amber-500'}`} />
          {hasSupabase ? 'Live' : 'Stub data'}
        </span>
        <button className="rounded-lg p-2 text-muted transition-colors hover:bg-slate-100">
          <Bell size={20} weight="bold" />
        </button>
        <button className="rounded-lg p-2 text-muted transition-colors hover:bg-slate-100">
          <Wrench size={20} weight="bold" />
        </button>
        {simNote && (
          <span className="rounded-md bg-emerald-50 px-2 py-1 text-[11px] font-semibold text-emerald-700">
            {simNote}
          </span>
        )}
        <button
          onClick={runSimulation}
          disabled={simulating}
          title="Simulate 10,000 users' activity over the last 24h"
          className="rounded-lg p-2 text-muted transition-colors hover:bg-slate-100 disabled:opacity-60"
        >
          {simulating ? <SpinnerGap className="animate-spin" size={20} weight="bold" /> : <Rocket size={20} weight="bold" />}
        </button>
        <button className="rounded-lg p-2 text-muted transition-colors hover:bg-slate-100">
          <Moon size={20} weight="bold" />
        </button>
        {hasSupabase && profile && (
          <div className="flex items-center gap-2 border-l border-line pl-4">
            <div className="text-right leading-tight">
              <div className="max-w-40 truncate text-xs font-semibold text-ink">
                {profile.username ?? profile.email}
              </div>
              <div className="text-[11px] text-muted">{isAdmin ? 'Admin' : 'Staff'}</div>
            </div>
            <button
              onClick={() => signOut()}
              title="Sign out"
              className="rounded-lg p-2 text-muted transition-colors hover:bg-slate-100"
            >
              <SignOut size={18} />
            </button>
          </div>
        )}
      </div>
    </header>
  )
}