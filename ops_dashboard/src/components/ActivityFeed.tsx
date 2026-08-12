import {
  CalendarCheck,
  Eye,
  Pulse,
  XCircle,
} from '@phosphor-icons/react'
import { api } from '../lib/api'
import { usePolling } from '../lib/hooks'

/** Pretty-print snake_case event names: "booking_created" -> "Booking created". */
const pretty = (e: string) =>
  e
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ')

const humanTime = (iso: string) => {
  const s = Math.max(0, Math.floor((Date.now() - new Date(iso).getTime()) / 1000))
  if (s < 3) return 'just now'
  if (s < 60) return `${s}s ago`
  const m = Math.floor(s / 60)
  if (m < 60) return `${m}m ago`
  const h = Math.floor(m / 60)
  return `${h}h ago`
}

const tone = (e: string): string => {
  if (e.includes('booking')) return 'bg-sky-500'
  if (e.includes('failed')) return 'bg-red-500'
  if (e.includes('screen') || e.includes('viewed')) return 'bg-slate-400'
  return 'bg-brand-500'
}

const Icon = ({ event }: { event: string }) => {
  if (event.includes('failed')) return <XCircle size={13} weight="bold" />
  if (event.includes('booking')) return <CalendarCheck size={13} weight="bold" />
  if (event.includes('screen') || event.includes('viewed')) return <Eye size={13} weight="bold" />
  return <Pulse size={13} weight="bold" />
}

function propsSnippet(p: Record<string, unknown>): string {
  const parts: string[] = []
  for (const [k, v] of Object.entries(p)) {
    if (typeof v === 'string' || typeof v === 'number') parts.push(`${k}=${v}`)
  }
  return parts.slice(0, 3).join(' ')
}

/** Exclude payment telemetry — the payment workflow isn't implemented yet (WIP). */
const isVisible = (e: { event?: string }) => !e.event?.includes('payment')

export default function ActivityFeed() {
  const { data, loading } = usePolling(() => api.events(40), [], 5000)
  const events = (data ?? []).filter(isVisible)

  const counts = new Map<string, number>()
  for (const e of events) counts.set(e.event, (counts.get(e.event) ?? 0) + 1)
  const top = [...counts.entries()].slice(0, 4)

  return (
    <div className="card p-5">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="flex items-center gap-2 text-sm font-bold text-ink">
          <Pulse size={16} weight="bold" className="text-brand-600" /> Live user activity
        </h2>
        <span className="inline-flex items-center gap-1.5 text-xs font-medium text-muted">
          <span className="relative flex h-2 w-2">
            <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75" />
            <span className="relative inline-flex h-2 w-2 rounded-full bg-emerald-500" />
          </span>
          {loading && events.length === 0 ? 'loading…' : `LIVE · ${events.length} recent`}
        </span>
      </div>

      {/* Event-type breakdown */}
      <div className="mb-4 flex flex-wrap gap-2">
        {top.map(([ev, n]) => (
          <span
            key={ev}
            className="inline-flex items-center gap-1.5 rounded-full border border-line bg-slate-50 px-2.5 py-1 text-[11px] font-medium text-ink"
          >
            <span className={`h-1.5 w-1.5 rounded-full ${tone(ev)}`} />
            {pretty(ev)}
            <span className="text-brand-600">{n}</span>
          </span>
        ))}
      </div>

      {events.length === 0 ? (
        <p className="py-8 text-center text-sm text-muted">
          No events yet — they'll stream in here live as court+ apps in the wild take actions.
        </p>
      ) : (
        <ul className="divide-y divide-line/60">
          {events.map((e) => (
            <li key={e.id} className="flex items-center gap-3 py-2">
              <span className={`mt-0.5 flex h-6 w-6 items-center justify-center rounded-full ${tone(e.event)} text-white`}>
                <Icon event={e.event} />
              </span>
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <span className="truncate text-[13px] font-medium text-ink">{pretty(e.event)}</span>
                  {e.platform && (
                    <span className="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] uppercase tracking-wide text-muted">
                      {e.platform}
                    </span>
                  )}
                </div>
                {propsSnippet(e.props) && (
                  <div className="truncate font-mono text-[11px] text-muted">{propsSnippet(e.props)}</div>
                )}
              </div>
              <span className="shrink-0 text-[11px] text-muted">{humanTime(e.createdAt)}</span>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
