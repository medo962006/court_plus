import {
  Buildings,
  CalendarCheck,
  Gauge,
  Scroll,
  TrendUp,
  UserList,
  Users,
  Warning,
} from '@phosphor-icons/react'
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { StatusPill, StatCard } from '../components/ui'
import ActivityFeed from '../components/ActivityFeed'
import { api } from '../lib/api'
import { usePolling } from '../lib/hooks'
import { useDark } from '../lib/theme'

const POLL = 4000

export default function Overview() {
  const [dark] = useDark()
  const overview = usePolling(() => api.systemOverview(), [], POLL)
  const services = usePolling(() => api.services(), [], POLL)
  const metrics = usePolling(() => api.metrics(), [], POLL)
  const errors = usePolling(() => api.errors(5), [], POLL)

  const grid = dark ? '#1e2a44' : '#e2e8f0'
  const tick = dark ? '#8ea0bb' : '#64748b'
  const tooltip = dark ? { backgroundColor: '#111a2e', border: '1px solid #1e2a44' } : { backgroundColor: '#fff', border: '1px solid #e2e8f0' }

  return (
    <div className="space-y-6">
      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 xl:grid-cols-4">
        <StatCard
          label="Services online"
          value={`${(overview.data?.serviceCount ?? 0) - (overview.data?.servicesDown ?? 0)}/${overview.data?.serviceCount ?? 0}`}
          icon={Gauge}
          sub={
            (overview.data?.servicesDown ?? 0) > 0 ? (
              <span className="text-red-600">{overview.data?.servicesDown} down</span>
            ) : (
              <span className="text-brand-600">All healthy</span>
            )
          }
        />
        <StatCard label="Active courts" value={overview.data?.activeCourts ?? '–'} icon={Buildings} />
        <StatCard label="Active coaches" value={overview.data?.activeCoaches ?? '–'} icon={UserList} />
        <StatCard
          label="Bookings today"
          value={overview.data?.bookingsToday ?? '–'}
          icon={CalendarCheck}
          tint="bg-sky-50 text-sky-700 dark:bg-sky-500/15 dark:text-sky-300"
        />
      </div>

      <div className="grid grid-cols-2 gap-4 xl:grid-cols-4">
        <StatCard label="Total users" value={overview.data?.users ?? '–'} icon={Users} />
        <StatCard
          label="Success rate (24h)"
          value={`${overview.data?.successRatePct ?? '–'}%`}
          icon={TrendUp}
        />
        <StatCard label="P95 latency" value={`${overview.data?.p95LatencyMs ?? '–'} ms`} icon={Gauge} tint="bg-purple-50 text-purple-700 dark:bg-purple-500/20 dark:text-purple-300" />
        <StatCard
          label="Errors (24h)"
          value={overview.data?.errorsLast24h ?? '–'}
          icon={Warning}
          tint="bg-red-50 text-red-600 dark:bg-red-500/15 dark:text-red-300"
        />
      </div>

      <ActivityFeed />

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
        {/* Traffic chart */}
        <div className="card p-5 xl:col-span-2">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-sm font-bold text-ink">Request volume & errors</h2>
            <span className="text-xs text-muted">Last 24h</span>
          </div>
          <ResponsiveContainer width="100%" height={260}>
            <AreaChart data={metrics.data ?? []} margin={{ top: 5, right: 8, left: -18, bottom: 0 }}>
              <defs>
                <linearGradient id="req" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#10b981" stopOpacity={0.35} />
                  <stop offset="100%" stopColor="#10b981" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke={grid} vertical={false} />
              <XAxis dataKey="label" tick={{ fontSize: 11, fill: tick }} axisLine={false} tickLine={false} minTickGap={32} />
              <YAxis tick={{ fontSize: 11, fill: tick }} axisLine={false} tickLine={false} />
              <Tooltip
                contentStyle={{ borderRadius: 10, fontSize: 12, ...tooltip }}
              />
              <Area type="monotone" dataKey="requests" stroke="#10b981" strokeWidth={2} fill="url(#req)" name="Requests" />
              <Area type="monotone" dataKey="errors" stroke="#ef4444" strokeWidth={2} fill="none" name="Errors" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Service health */}
        <div className="card p-5">
          <h2 className="mb-4 text-sm font-bold text-ink">Service health</h2>
          <div className="space-y-3">
            {(services.data ?? []).map((s) => (
              <div key={s.id} className="flex items-center justify-between">
                <div>
                  <div className="text-sm font-medium text-ink">{s.service}</div>
                  <div className="text-xs text-muted">
                    {s.errorRatePct !== undefined ? `err ${s.errorRatePct}%` : ''}
                    {s.p95Ms ? ` · p95 ${s.p95Ms}ms` : ''}
                  </div>
                </div>
                <StatusPill status={s.status} />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recent errors */}
      <div className="card">
        <div className="flex items-center justify-between px-5 pt-4">
          <h2 className="text-sm font-bold text-ink">Recent errors</h2>
          <span className="inline-flex items-center gap-1 text-xs font-medium text-muted">
            <Scroll size={14} /> live tail
          </span>
        </div>
        <table className="mt-2 w-full">
          <thead>
            <tr className="border-b border-line">
              <th className="th">Level</th>
              <th className="th">Service</th>
              <th className="th">Message</th>
              <th className="th text-right">When</th>
            </tr>
          </thead>
          <tbody>
            {(errors.data ?? []).map((l) => (
                <tr key={l.id} className="border-b border-line/60 last:border-0 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                  <td className="td">
                    <StatusPill status={l.level} />
                  </td>
                  <td className="td text-muted">{l.service}</td>
                  <td className="td max-w-md truncate">{l.message}</td>
                  <td className="td text-right text-xs text-muted">
                    {new Date(l.createdAt).toLocaleTimeString()}
                  </td>
                </tr>
              ))}
            {(errors.data ?? []).length === 0 && (
              <tr>
                <td className="td" colSpan={4}>
                  <span className="text-muted">No errors — all green.</span>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}