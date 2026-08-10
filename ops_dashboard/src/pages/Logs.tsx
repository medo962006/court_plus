import { FunnelSimple, MagnifyingGlass, Stack } from '@phosphor-icons/react'
import { useMemo, useState } from 'react'
import { StatusPill } from '../components/ui'
import { api } from '../lib/api'
import { useAsync } from '../lib/hooks'
import type { LogLevel } from '../lib/types'

const levels: Array<LogLevel | 'all'> = ['all', 'error', 'warn', 'info', 'debug']

export default function Logs() {
  const logs = useAsync(() => api.logs(300))
  const [filter, setFilter] = useState<LogLevel | 'all'>('all')
  const [q, setQ] = useState('')

  const rows = useMemo(
    () =>
      (logs.data ?? []).filter((l) => {
        const lv = filter === 'all' || l.level === filter
        const text = q.toLowerCase()
        const hasQ = text === '' || l.message.toLowerCase().includes(text) || l.service.toLowerCase().includes(text)
        return lv && hasQ
      }),
    [logs.data, filter, q]
  )

  const counts = useMemo(() => {
    const c: Record<LogLevel, number> = { error: 0, warn: 0, info: 0, debug: 0 }
    for (const l of logs.data ?? []) c[l.level]++
    return c
  }, [logs.data])

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-3">
        <div className="relative min-w-64">
          <MagnifyingGlass size={15} className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-muted" />
          <input
            className="input pl-9"
            placeholder="Search message or service…"
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
        </div>
        <div className="flex items-center gap-1 rounded-lg border border-line bg-white p-0.5">
          <FunnelSimple size={15} className="ml-2 text-muted" />
          {levels.map((lv) => (
            <button
              key={lv}
              onClick={() => setFilter(lv)}
              className={`rounded-md px-2.5 py-1.5 text-xs font-semibold capitalize transition-colors ${
                filter === lv ? 'bg-brand-600 text-white' : 'text-muted hover:bg-slate-100'
              }`}
            >
              {lv}
              {lv !== 'all' && <span className="ml-1 opacity-70">{counts[lv as LogLevel]}</span>}
            </button>
          ))}
        </div>
      </div>

      <div className="card overflow-hidden">
        <div className="border-b border-line px-5 py-3 text-xs font-semibold text-muted">
          {rows.length} entries
        </div>
        <div className="max-h-[calc(100vh-220px)] overflow-y-auto">
          <table className="w-full">
            <thead className="sticky top-0 bg-panel">
              <tr className="border-b border-line">
                <th className="th w-20">Level</th>
                <th className="th w-40">Service</th>
                <th className="th">Message</th>
                <th className="th w-40">Env</th>
                <th className="th w-32 text-right">When</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((l) => (
                <tr key={l.id} className="border-b border-line/60 last:border-0 hover:bg-slate-50">
                  <td className="td">
                    <StatusPill status={l.level} />
                  </td>
                  <td className="td font-medium text-ink">{l.service}</td>
                  <td className="td">
                    <div className="max-w-xl truncate">{l.message}</div>
                    {l.context && (
                      <div className="mt-0.5 truncate font-mono text-[11px] text-muted">
                        {JSON.stringify(l.context)}
                      </div>
                    )}
                  </td>
                  <td className="td">
                    <span className="inline-flex items-center gap-1 text-xs text-muted">
                      <Stack size={13} /> {l.appEnv ?? '–'}
                    </span>
                  </td>
                  <td className="td text-right text-xs text-muted">
                    {new Date(l.createdAt).toLocaleString()}
                  </td>
                </tr>
              ))}
              {rows.length === 0 && (
                <tr>
                  <td className="td py-10 text-center text-muted" colSpan={5}>
                    No log entries match.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}