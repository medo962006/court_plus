import {
  Bell,
  Moon,
  Rocket,
  SignOut,
  SpinnerGap,
  Sun,
  Warning,
  Wrench,
} from '@phosphor-icons/react'
import { useEffect, useRef, useState } from 'react'
import { useAuth } from '../lib/auth'
import { hasSupabase } from '../lib/supabase'
import { api } from '../lib/api'
import type { LogEntry } from '../lib/types'

const SIM_TICK_MS = 4000

function LevelDot({ level }: { level: string }) {
  const c = level === 'error' ? 'bg-red-500' : level === 'warn' ? 'bg-amber-500' : 'bg-slate-300'
  return <span className={`mt-1.5 h-2 w-2 shrink-0 rounded-full ${c}`} />
}

export default function Topbar({ title }: { title: string }) {
  const { profile, isAdmin, signOut } = useAuth()

  const [dark, setDark] = useState(() => localStorage.getItem('ops-dark') === '1')
  const [simOn, setSimOn] = useState(false)
  const [simBusy, setSimBusy] = useState(false)
  const [simNote, setSimNote] = useState<string | null>(null)
  const [settingsOpen, setSettingsOpen] = useState(false)
  const [notifOpen, setNotifOpen] = useState(false)
  const [alerts, setAlerts] = useState<LogEntry[]>([])
  const tickRef = useRef<number | null>(null)

  useEffect(() => {
    document.documentElement.classList.toggle('dark', dark)
    localStorage.setItem('ops-dark', dark ? '1' : '0')
  }, [dark])

  useEffect(() => {
    const load = async () => {
      const logs = await api.logs(40)
      setAlerts(logs.filter((l) => l.level === 'error' || l.level === 'warn').slice(0, 8))
    }
    load()
    const id = setInterval(load, 8000)
    return () => clearInterval(id)
  }, [])

  useEffect(() => () => { if (tickRef.current) window.clearInterval(tickRef.current) }, [])

  const toggleSim = async () => {
    if (simBusy) return
    setSimBusy(true)
    try {
      if (!simOn) {
        const res = await api.simulate('start')
        if (res.ok) {
          setSimOn(true)
          setSimNote(res.events ? `live · +${res.events.toLocaleString()} events` : 'live · 10k users')
          tickRef.current = window.setInterval(() => api.simulate('tick').catch(() => {}), SIM_TICK_MS)
        }
      } else {
        if (tickRef.current) { window.clearInterval(tickRef.current); tickRef.current = null }
        const res = await api.simulate('stop')
        const n = res.deleted ? Object.values(res.deleted).reduce((a, b) => a + b, 0) : 0
        setSimNote(n ? `cleared ${n.toLocaleString()} sim events` : 'sim stopped')
        setSimOn(false)
      }
    } finally {
      setSimBusy(false)
    }
    setTimeout(() => setSimNote(null), 4000)
  }

  const errorCount = alerts.filter((a) => a.level === 'error').length
  const iconHover = 'hover:bg-slate-100 dark:hover:bg-slate-800'

  return (
    <header className="flex h-16 shrink-0 items-center justify-between border-b border-line bg-panel px-6">
      <h1 className="text-lg font-bold text-ink">{title}</h1>

      <div className="flex items-center gap-2">
        <span
          className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ${
            hasSupabase ? 'bg-brand-50 text-brand-700' : 'bg-amber-50 text-amber-700'
          }`}
        >
          <span className={`h-1.5 w-1.5 rounded-full ${hasSupabase ? 'bg-brand-500' : 'bg-amber-500'}`} />
          {hasSupabase ? 'Live' : 'Stub data'}
        </span>

        {simNote && (
          <span className="rounded-md bg-brand-50 px-2 py-1 text-[11px] font-semibold text-brand-700 ring-1 ring-brand-500/20">
            {simNote}
          </span>
        )}

        {/* Notifications */}
        <div className="relative">
          <button
            onClick={() => { setNotifOpen((o) => !o); setSettingsOpen(false) }}
            className={`relative rounded-lg p-2 text-muted transition-colors ${iconHover}`}
          >
            <Bell size={20} weight="bold" />
            {errorCount > 0 && <span className="absolute right-1.5 top-1.5 h-2 w-2 rounded-full bg-red-500" />}
          </button>
          {notifOpen && (
            <div className="card absolute right-0 top-full z-30 mt-2 w-80 p-3">
              <div className="mb-2 text-xs font-bold uppercase tracking-wide text-muted">
                Alerts {errorCount > 0 && <span className="ml-1 rounded bg-red-50 px-1.5 text-xs text-red-600">{errorCount} error</span>}
              </div>
              {alerts.length === 0 ? (
                <div className="flex items-center gap-2 py-2 text-sm text-muted">
                  <Warning size={16} className="text-brand-500" /> No alerts — all green.
                </div>
              ) : (
                <ul className="max-h-72 space-y-2 overflow-auto">
                  {alerts.map((a) => (
                    <li key={a.id} className="flex items-start gap-2 text-sm">
                      <LevelDot level={a.level} />
                      <div className="min-w-0">
                        <div className="truncate font-medium text-ink">{a.message}</div>
                        <div className="text-[11px] text-muted">
                          {a.service} · {new Date(a.createdAt).toLocaleTimeString()}
                        </div>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          )}
        </div>

        {/* Settings */}
        <div className="relative">
          <button
            onClick={() => { setSettingsOpen((o) => !o); setNotifOpen(false) }}
            className={`rounded-lg p-2 text-muted transition-colors ${iconHover}`}
          >
            <Wrench size={20} weight="bold" />
          </button>
          {settingsOpen && (
            <div className="card absolute right-0 top-full z-30 mt-2 w-72 p-3">
              <div className="mb-2 text-xs font-bold uppercase tracking-wide text-muted">Settings</div>
              {!hasSupabase && (
                <p className="mb-2 rounded-md bg-red-50 px-2 py-1.5 text-xs text-red-600">
                  Supabase not configured — showing seeded stub data.
                </p>
              )}
              <button
                onClick={() => setDark((d) => !d)}
                className="flex w-full items-center justify-between rounded-lg px-2 py-2 text-sm font-medium text-ink hover:bg-slate-100 dark:hover:bg-slate-800"
              >
                Dark mode
                <span className={`flex h-5 w-9 items-center rounded-full p-0.5 transition-colors ${dark ? 'justify-end bg-brand-600' : 'justify-start bg-slate-300'}`}>
                  <span className="h-4 w-4 rounded-full bg-white shadow" />
                </span>
              </button>
              <p className="px-2 pt-1 text-[11px] leading-relaxed text-muted">
                Simulate streams ~10k users; press the rocket to stop and clear simulated data.
              </p>
            </div>
          )}
        </div>

        {/* Simulate live toggle */}
        <button
          onClick={toggleSim}
          disabled={simBusy}
          title={simOn ? 'Stop — clear simulated activity' : 'Simulate 10,000 users live'}
          className={`rounded-lg p-2 transition-colors disabled:opacity-60 ${
            simOn ? 'bg-brand-600 text-white' : `text-muted ${iconHover}`
          }`}
        >
          {simBusy ? <SpinnerGap size={20} className="animate-spin" weight="bold" /> : <Rocket size={20} weight={simOn ? 'fill' : 'bold'} />}
        </button>

        {/* Dark mode */}
        <button
          onClick={() => setDark((d) => !d)}
          title="Toggle dark mode"
          className={`rounded-lg p-2 text-muted transition-colors ${iconHover}`}
        >
          {dark ? <Sun size={20} weight="bold" /> : <Moon size={20} weight="bold" />}
        </button>

        {hasSupabase && profile && (
          <div className="flex items-center gap-2 border-l border-line pl-4">
            <div className="text-right leading-tight">
              <div className="max-w-40 truncate text-xs font-semibold text-ink">{profile.username ?? profile.email}</div>
              <div className="text-[11px] text-muted">{isAdmin ? 'Admin' : 'Staff'}</div>
            </div>
            <button onClick={() => signOut()} title="Sign out" className={`rounded-lg p-2 text-muted transition-colors ${iconHover}`}>
              <SignOut size={18} />
            </button>
          </div>
        )}
      </div>
    </header>
  )
}