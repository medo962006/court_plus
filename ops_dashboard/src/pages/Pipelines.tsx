import { CaretDown, GitBranch, GitCommit, GitPullRequest, RocketLaunch, UserCircle } from '@phosphor-icons/react'
import { useState } from 'react'
import { Badge, StatusPill } from '../components/ui'
import { api } from '../lib/api'
import { useAsync, usePolling } from '../lib/hooks'
import type { PipelineRun } from '../lib/types'

const eventIcon = (e: PipelineRun['event']) => {
  switch (e) {
    case 'pull_request':
      return GitPullRequest
    case 'release':
      return RocketLaunch
    case 'manual':
      return UserCircle
    default:
      return GitBranch
  }
}

export default function Pipelines() {
  const runs = usePolling(() => api.pipelineRuns(), [], 8000)
  const [openRun, setOpenRun] = useState<string | null>(null)
  const jobs = useAsync(() => api.pipelineJobs(openRun ?? ''), [openRun])

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted">
          Live status of every CI/CD run — analyze, test, build, deploy, publish.
        </p>
        <div className="flex gap-2">
          <Badge tone="brand">main</Badge>
          <Badge tone="sky">dev</Badge>
        </div>
      </div>

      <div className="space-y-3">
        {(runs.data ?? []).map((run) => {
          const EventIcon = eventIcon(run.event)
          const isOpen = openRun === run.id
          return (
            <div key={run.id} className="card overflow-hidden">
              <button
                className="flex w-full items-center gap-4 px-5 py-3.5 text-left hover:bg-slate-50 dark:hover:bg-slate-800/60"
                onClick={() => setOpenRun(isOpen ? null : run.id)}
              >
                <StatusPill status={run.status} />
                <div className="flex items-center gap-2 font-mono text-xs text-muted">
                  <GitCommit size={14} />
                  <span>{run.commitSha.slice(0, 7)}</span>
                </div>
                <div className="min-w-0 flex-1">
                  <div className="truncate text-sm font-semibold text-ink">{run.commitMsg}</div>
                  <div className="text-xs text-muted">
                    run #{run.runNumber} · {run.author} · {run.branch}
                  </div>
                </div>
                <span
                  className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium ${
                    run.event === 'release'
                      ? 'bg-brand-50 text-brand-700 dark:bg-brand-500/15 dark:text-brand-300'
                      : run.event === 'pull_request'
                        ? 'bg-sky-50 text-sky-700 dark:bg-sky-500/15 dark:text-sky-300'
                        : 'bg-slate-100 text-muted dark:bg-slate-800 dark:text-slate-300'
                  }`}
                >
                  <EventIcon size={12} weight="bold" />
                  {run.event === 'pull_request' ? 'PR' : run.event}
                </span>
                <span className="text-xs text-muted">
                  {run.durationMs ? `${Math.round(run.durationMs / 60000)}m` : '–'}
                </span>
                <CaretDown
                  size={16}
                  className={`text-muted transition-transform ${isOpen ? 'rotate-180' : ''}`}
                />
              </button>

              {isOpen && (
                <div className="border-t border-line bg-slate-50/60 px-6 py-4 dark:bg-slate-800/40">
                  <div className="grid max-w-2xl grid-cols-1 gap-2 sm:grid-cols-2">
                    {jobsLoadingRow(jobs.loading)}
                    {(jobs.data ?? []).map((job) => (
                      <div
                        key={job.id}
                        className="flex items-center justify-between rounded-lg border border-line bg-white px-3 py-2 dark:bg-panel"
                      >
                        <div>
                          <div className="text-sm font-medium text-ink">{job.name}</div>
                          {job.coveragePct != null && (
                            <div className="text-xs text-muted">coverage {job.coveragePct}%</div>
                          )}
                        </div>
                        <StatusPill status={job.status} />
                      </div>
                    ))}
                    {(jobs.data ?? []).length === 0 && !jobs.loading && (
                      <div className="text-sm text-muted">No job detail recorded for this run.</div>
                    )}
                  </div>
                </div>
              )}
            </div>
          )
        })}
        {(runs.data ?? []).length === 0 && !runs.loading && (
          <div className="card p-6 text-center text-muted">
            No pipeline runs yet. Once CI reporting is wired, runs appear here live.
          </div>
        )}
      </div>
    </div>
  )
}

function jobsLoadingRow(loading: boolean) {
  if (!loading) return null
  return <div className="text-sm text-muted">Loading jobs…</div>
}