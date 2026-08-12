import { supabase } from './supabase'
import {
  stubCoaches,
  stubCourts,
  stubLogs,
  stubMetrics,
  stubOverview,
  stubRuns,
  stubRunsJobs,
  stubServices,
} from './stubs'
import type {
  AppEvent,
  Coach,
  Court,
  LogEntry,
  MetricPoint,
  PipelineJob,
  PipelineRun,
  ServiceHeartbeat,
  SystemOverview,
} from './types'

/** Resolves a promise after a short delay so live vs stub behaves uniformly. */
const flake = <T>(data: T, ms = 300): Promise<T> =>
  new Promise((resolve) => setTimeout(() => resolve(data), ms))

/** Best-effort admin audit trail. Non-fatal. */
async function audit(
  action: string,
  targetTable: string,
  targetId?: string | null,
  after?: unknown
) {
  if (!supabase) return
  try {
    await supabase.from('admin_audit_log').insert({
      action,
      target_table: targetTable,
      target_id: targetId ?? null,
      after_val: after ?? null,
    })
  } catch {
    /* audit is non-fatal */
  }
}

export const api = {
  async systemOverview(): Promise<SystemOverview> {
    if (!supabase) return flake(stubOverview)
    const { data, error } = await supabase
      .from('system_overview')
      .select('*')
      .single()
    if (error) return flake(stubOverview)
    const r = data as Record<string, unknown>
    return {
      serviceCount: Number(r.service_count ?? 0),
      servicesDown: Number(r.services_down ?? 0),
      activeCourts: Number(r.active_courts ?? 0),
      activeCoaches: Number(r.active_coaches ?? 0),
      users: Number(r.users ?? 0),
      bookingsToday: Number(r.bookings_today ?? 0),
      successRatePct: r.success_rate_pct == null ? null : Number(r.success_rate_pct),
      p95LatencyMs: r.p95_latency_ms == null ? null : Number(r.p95_latency_ms),
      lastDeploy: (r.last_deploy as SystemOverview['lastDeploy']) ?? null,
      errorsLast24h: Number(r.errors_last_24h ?? 0),
    }
  },

  async services(): Promise<ServiceHeartbeat[]> {
    if (!supabase) return flake(stubServices)
    const { data, error } = await supabase
      .from('service_heartbeats')
      .select('*')
      .order('last_seen_at', { ascending: false })
    if (error) return flake(stubServices)
    return (data as Array<Record<string, unknown>>).map((r) => ({
      id: String(r.id),
      service: String(r.service),
      status: r.status as ServiceHeartbeat['status'],
      lastSeenAt: String(r.last_seen_at),
      errorRatePct: r.error_rate_pct == null ? undefined : Number(r.error_rate_pct),
      p95Ms: r.p95_ms == null ? undefined : Number(r.p95_ms),
      uptimePct: r.uptime_pct == null ? undefined : Number(r.uptime_pct),
    }))
  },

  async metrics(): Promise<MetricPoint[]> {
    if (!supabase) return flake(stubMetrics)
    const { data, error } = await supabase
      .from('request_metrics')
      .select('label, requests, errors, latency_p95')
      .order('ts', { ascending: true })
      .limit(48)
    if (error) return flake(stubMetrics)
    return (data as Array<Record<string, number | string>>).map((r) => ({
      label: String(r.label),
      requests: Number(r.requests),
      errors: Number(r.errors),
      latencyP95: Number(r.latency_p95),
    }))
  },

  async logs(limit = 100): Promise<LogEntry[]> {
    if (!supabase) return flake(stubLogs)
    const { data, error } = await supabase
      .from('system_logs')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit)
    if (error) return flake(stubLogs)
    return (data as Array<Record<string, unknown>>).map((r) => ({
      id: String(r.id),
      level: r.level as LogEntry['level'],
      service: String(r.service),
      message: String(r.message),
      context: (r.context as Record<string, unknown>) ?? undefined,
      userId: (r.user_id as string) ?? null,
      appVersion: (r.app_version as string) ?? null,
      appEnv: (r.app_env as string) ?? null,
      createdAt: String(r.created_at),
    }))
  },

  async pipelineRuns(): Promise<PipelineRun[]> {
    if (!supabase) return flake(stubRuns)
    const { data, error } = await supabase
      .from('pipeline_runs')
      .select('*')
      .order('started_at', { ascending: false })
      .limit(60)
    if (error) return flake(stubRuns)
    return (data as Array<Record<string, unknown>>).map((r) => ({
      id: String(r.id),
      runNumber: Number(r.run_number),
      branch: String(r.branch ?? 'main'),
      event: r.event as PipelineRun['event'],
      commitSha: (r.commit_sha as string) ?? '',
      commitMsg: (r.commit_msg as string) ?? '',
      author: (r.author as string) ?? '',
      status: r.status as PipelineRun['status'],
      startedAt: String(r.started_at),
      finishedAt: (r.finished_at as string) ?? null,
      durationMs: r.duration_ms == null ? null : Number(r.duration_ms),
    }))
  },

  async pipelineJobs(runId: string): Promise<PipelineJob[]> {
    if (!supabase) return flake(stubRunsJobs[runId] ?? [])
    const { data, error } = await supabase
      .from('pipeline_jobs')
      .select('*')
      .eq('run_id', runId)
      .order('started_at', { ascending: true })
    if (error) return flake(stubRunsJobs[runId] ?? [])
    return (data as Array<Record<string, unknown>>).map((r) => ({
      id: String(r.id),
      runId: String(r.run_id),
      name: String(r.name),
      status: r.status as PipelineJob['status'],
      startedAt: (r.started_at as string) ?? null,
      finishedAt: (r.finished_at as string) ?? null,
      logsUrl: (r.logs_url as string) ?? null,
      coveragePct: r.coverage_pct == null ? null : Number(r.coverage_pct),
      artifactUrl: (r.artifact_url as string) ?? null,
      version: (r.version as string) ?? null,
    }))
  },

  async courts(): Promise<Court[]> {
    if (!supabase) return flake(stubCourts)
    const { data, error } = await supabase
      .from('courts')
      .select('*')
      .order('created_at', { ascending: false })
    if (error) return flake(stubCourts)
    return data as Court[]
  },

  async coaches(): Promise<Coach[]> {
    if (!supabase) return flake(stubCoaches)
    const { data, error } = await supabase
      .from('coaches')
      .select('*')
      .order('created_at', { ascending: false })
    if (error) return flake(stubCoaches)
    return data as Coach[]
  },

  async createCourt(court: Partial<Court>): Promise<Court> {
    if (!supabase) {
      return flake({
        id: `c-${Date.now()}`,
        name: 'New court',
        center: '',
        sport_type: court.sport_type ?? 'Tennis',
        location: '',
        address: null,
        image_url: null,
        rating: 0,
        reviews_count: 0,
        likes_count: 0,
        price_per_hour: court.price_per_hour ?? 100,
        latitude: null,
        longitude: null,
        is_active: true,
        created_at: new Date().toISOString(),
        ...court,
      })
    }
    const { data, error } = await supabase.from('courts').insert(court).select().single()
    if (error) throw new Error(error.message)
    await audit('create', 'courts', data.id, data)
    return data as Court
  },

  async updateCourt(id: string, patch: Partial<Court>): Promise<Court> {
    if (!supabase) {
      const base = stubCourts.find((c) => c.id === id)
      return flake({ ...base, ...patch, id } as Court)
    }
    const { data, error } = await supabase.from('courts').update(patch).eq('id', id).select().single()
    if (error) throw new Error(error.message)
    await audit('update', 'courts', id, { ...patch, id })
    return data as Court
  },

  async createCoach(coach: Partial<Coach>): Promise<Coach> {
    if (!supabase) {
      return flake({
        id: `co-${Date.now()}`,
        full_name: coach.full_name ?? 'New coach',
        username: coach.username ?? '',
        avatar_url: null,
        sport_type: coach.sport_type ?? 'Tennis',
        rating: 0,
        price_per_session: coach.price_per_session ?? 100,
        bio: null,
        experience: coach.experience ?? 0,
        latitude: null,
        longitude: null,
        is_active: true,
        created_at: new Date().toISOString(),
        ...coach,
      })
    }
    const { data, error } = await supabase.from('coaches').insert(coach).select().single()
    if (error) throw new Error(error.message)
    await audit('create', 'coaches', data.id, data)
    return data as Coach
  },

  async updateCoach(id: string, patch: Partial<Coach>): Promise<Coach> {
    if (!supabase) {
      const base = stubCoaches.find((c) => c.id === id)
      return flake({ ...base, ...patch, id } as Coach)
    }
    const { data, error } = await supabase.from('coaches').update(patch).eq('id', id).select().single()
    if (error) throw new Error(error.message)
    await audit('update', 'coaches', id, { ...patch, id })
    return data as Coach
  },

  async events(limit = 40): Promise<AppEvent[]> {
    if (!supabase) return flake([])
    const { data, error } = await supabase
      .from('app_events')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit)
    if (error) return flake([])
    return (data as Array<Record<string, unknown>>).map((r) => ({
      id: String(r.id),
      appId: String(r.app_id ?? 'court+'),
      event: String(r.event),
      props: (r.props as Record<string, unknown>) ?? {},
      userId: (r.user_id as string) ?? null,
      platform: (r.platform as string) ?? null,
      appVersion: (r.app_version as string) ?? null,
      appEnv: (r.app_env as string) ?? null,
      createdAt: String(r.created_at),
    }))
  },
}