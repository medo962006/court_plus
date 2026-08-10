/// Domain types for the Court+ ops dashboard.
/// Mirrors the Supabase schema defined in migration 00008 (plus existing
/// `courts` / `coaches` tables).

export type LogLevel = 'debug' | 'info' | 'warn' | 'error'

export interface LogEntry {
  id: string
  level: LogLevel
  service: string
  message: string
  context?: Record<string, unknown>
  userId?: string | null
  appVersion?: string | null
  appEnv?: string | null
  createdAt: string
}

export type PipelineStatus = 'queued' | 'in_progress' | 'success' | 'failure' | 'cancelled'
export type PipelineEvent = 'push' | 'pull_request' | 'release' | 'manual'

export interface PipelineRun {
  id: string
  runNumber: number
  branch: string
  event: PipelineEvent
  commitSha: string
  commitMsg: string
  author: string
  status: PipelineStatus
  startedAt: string
  finishedAt?: string | null
  durationMs?: number | null
}

export interface PipelineJob {
  id: string
  runId: string
  name: string
  status: PipelineStatus
  startedAt?: string | null
  finishedAt?: string | null
  logsUrl?: string | null
  coveragePct?: number | null
  artifactUrl?: string | null
  version?: string | null
}

export interface ServiceHeartbeat {
  id: string
  service: string
  status: 'healthy' | 'degraded' | 'down'
  lastSeenAt: string
  errorRatePct?: number
  p95Ms?: number
  uptimePct?: number
}

export type Court = {
  id: string
  name: string
  center: string
  sport_type: string
  location: string
  address: string | null
  image_url: string | null
  rating: number
  reviews_count: number
  likes_count: number
  price_per_hour: number
  latitude: number | null
  longitude: number | null
  is_active: boolean
  created_at: string
  bookings_count?: number
}

export type Coach = {
  id: string
  full_name: string
  username: string
  avatar_url: string | null
  sport_type: string
  rating: number
  price_per_session: number
  bio: string | null
  experience: number
  latitude: number | null
  longitude: number | null
  is_active: boolean
  created_at: string
}

export interface MetricPoint {
  label: string
  requests: number
  errors: number
  latencyP95: number
}

export interface Profile {
  id: string
  email: string | null
  username: string | null
  full_name: string
  role: 'user' | 'admin' | 'staff'
}

export interface SystemOverview {
  serviceCount: number
  servicesDown: number
  activeCourts: number
  activeCoaches: number
  users: number
  bookingsToday: number
  successRatePct: number | null
  p95LatencyMs: number | null
  lastDeploy: { version: string; at: string } | null
  errorsLast24h: number
}