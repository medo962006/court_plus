import type { Icon, IconWeight } from '@phosphor-icons/react'
import type { ReactNode } from 'react'

export function StatCard({
  label,
  value,
  icon,
  tint = 'bg-brand-50 text-brand-700',
  sub,
}: {
  label: string
  value: string | number
  icon: Icon
  tint?: string
  sub?: ReactNode
}) {
  const IconComponent = icon
  return (
    <div className="card p-4">
      <div className="flex items-start justify-between">
        <div>
          <div className="text-xs font-semibold uppercase tracking-wide text-muted">{label}</div>
          <div className="mt-1.5 text-2xl font-bold text-ink">{value}</div>
          {sub && <div className="mt-1 text-xs text-muted">{sub}</div>}
        </div>
        <div className={`grid h-10 w-10 place-items-center rounded-lg ${tint}`}>
          <IconComponent size={22} weight="bold" />
        </div>
      </div>
    </div>
  )
}

const statusStyles: Record<string, string> = {
  success: 'bg-brand-50 text-brand-700 dark:bg-brand-500/15 dark:text-brand-300',
  failure: 'bg-red-50 text-red-600 dark:bg-red-500/15 dark:text-red-300',
  in_progress: 'bg-sky-50 text-sky-700 dark:bg-sky-500/15 dark:text-sky-300',
  queued: 'bg-slate-100 text-muted dark:bg-slate-800 dark:text-slate-300',
  cancelled: 'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400',
  healthy: 'bg-brand-50 text-brand-700 dark:bg-brand-500/15 dark:text-brand-300',
  degraded: 'bg-amber-50 text-amber-700 dark:bg-amber-500/15 dark:text-amber-300',
  down: 'bg-red-50 text-red-600 dark:bg-red-500/15 dark:text-red-300',
  error: 'bg-red-50 text-red-600 dark:bg-red-500/15 dark:text-red-300',
  warn: 'bg-amber-50 text-amber-700 dark:bg-amber-500/15 dark:text-amber-300',
  info: 'bg-sky-50 text-sky-700 dark:bg-sky-500/15 dark:text-sky-300',
  debug: 'bg-slate-100 text-slate-500 dark:bg-slate-800 dark:text-slate-400',
}

export function StatusPill({ status }: { status: string }) {
  const label = status.replace('_', ' ').replace(/^\w/, (c) => c.toUpperCase())
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold capitalize ${
        statusStyles[status] ?? 'bg-slate-100 text-muted dark:bg-slate-800 dark:text-slate-300'
      }`}
    >
      {label}
    </span>
  )
}

export function Badge({
  children,
  tone = 'slate',
}: {
  children: ReactNode
  tone?: 'slate' | 'brand' | 'amber' | 'sky'
}) {
  const tones: Record<string, string> = {
    slate: 'bg-slate-100 text-muted dark:bg-slate-800 dark:text-slate-300',
    brand: 'bg-brand-50 text-brand-700 dark:bg-brand-500/15 dark:text-brand-300',
    amber: 'bg-amber-50 text-amber-700 dark:bg-amber-500/15 dark:text-amber-300',
    sky: 'bg-sky-50 text-sky-700 dark:bg-sky-500/15 dark:text-sky-300',
  }
  return (
    <span className={`inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold ${tones[tone]}`}>
      {children}
    </span>
  )
}

export const weight: IconWeight = 'bold'