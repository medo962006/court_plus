import type {
  Coach,
  Court,
  LogEntry,
  MetricPoint,
  PipelineJob,
  PipelineRun,
  ServiceHeartbeat,
  SystemOverview,
} from './types'

const now = Date.now()
const ago = (min: number) => new Date(now - min * 60_000).toISOString()
const sha = (s: string) => '7'.repeat(40 - s.length) + s

/// Stub fixtures used when the real Supabase backend isn't configured.
/// These match what the real tables will return so screens behave identically.

export const stubServices: ServiceHeartbeat[] = [
  { id: 'svc-1', service: 'mobile-app', status: 'healthy', lastSeenAt: ago(1), errorRatePct: 0.4, p95Ms: 310, uptimePct: 99.98 },
  { id: 'svc-2', service: 'supabase-auth', status: 'healthy', lastSeenAt: ago(1), errorRatePct: 0.1, p95Ms: 240, uptimePct: 100 },
  { id: 'svc-3', service: 'postgres-db', status: 'healthy', lastSeenAt: ago(0), errorRatePct: 0.05, p95Ms: 120, uptimePct: 100 },
  { id: 'svc-4', service: 'edge-functions', status: 'healthy', lastSeenAt: ago(3), errorRatePct: 1.2, p95Ms: 480, uptimePct: 99.95 },
  { id: 'svc-5', service: 'push-notifications', status: 'down', lastSeenAt: ago(68), errorRatePct: 0, p95Ms: 0, uptimePct: 87.2 },
]

const stubJobs = (
  runId: string,
  jobs: Array<[string, PipelineJob['status'], number, number | null]>
): PipelineJob[] =>
  jobs.map(([name, status, seq, cov], i) => ({
    id: `${runId}-j${i}`,
    runId,
    name,
    status,
    startedAt: ago(seq + 8),
    finishedAt: status === 'in_progress' || status === 'queued' ? null : ago(seq + 1),
    coveragePct: name === 'test' ? cov : undefined,
    artifactUrl: name.startsWith('build') ? 'https://artifacts.example/aab' : undefined,
  }))

export const stubRuns: PipelineRun[] = [
  {
    id: 'run-104', runNumber: 104, branch: 'main', event: 'push', commitSha: sha('a'), commitMsg: 'feat: release v1.0.0 candidate', author: 'khalid.omar', status: 'in_progress', startedAt: ago(4), durationMs: (now - Date.parse(ago(4))) | 0,
  },
  {
    id: 'run-103', runNumber: 103, branch: 'main', event: 'push', commitSha: sha('b'), commitMsg: 'feat(booking): wire booking lifecycle RPCs', author: 'sarah.ahmed', status: 'success', startedAt: ago(1480), finishedAt: ago(1465), durationMs: 15 * 60 * 1000,
  },
  {
    id: 'run-102', runNumber: 102, branch: 'dev', event: 'pull_request', commitSha: sha('c'), commitMsg: 'fix(auth): OtpType.email for 6-digit codes', author: 'fatima.hassan', status: 'success', startedAt: ago(3120), finishedAt: ago(3100), durationMs: 20 * 60 * 1000,
  },
  {
    id: 'run-101', runNumber: 101, branch: 'dev', event: 'pull_request', commitSha: sha('d'), commitMsg: 'wip: booking flow (simulation)', author: 'mike.johnson', status: 'failure', startedAt: ago(4400), finishedAt: ago(4412), durationMs: 12 * 60 * 1000,
  },
  {
    id: 'run-100', runNumber: 100, branch: 'main', event: 'release', commitSha: sha('e'), commitMsg: 'chore: tag v0.9.0', author: 'cicd-bot', status: 'success', startedAt: ago(8640), finishedAt: ago(8600), durationMs: 40 * 60 * 1000,
  },
  {
    id: 'run-99', runNumber: 99, branch: 'dev', event: 'pull_request', commitSha: sha('f'), commitMsg: 'test(P1): 113 unit tests passing', author: 'sarah.ahmed', status: 'cancelled', startedAt: ago(10080), finishedAt: null, durationMs: null,
  },
]

export const stubRunsJobs: Record<string, PipelineJob[]> = {
  'run-104': stubJobs('run-104', [['analyze', 'success', 0, null], ['test', 'in_progress', 2, 71.4], ['build_release', 'queued', 4, null], ['deploy_backend', 'queued', 5, null]]),
  'run-103': stubJobs('run-103', [['analyze', 'success', 0, null], ['test', 'success', 2, 74.2], ['build_android', 'success', 4, null], ['deploy_backend', 'success', 5, null]]),
  'run-102': stubJobs('run-102', [['analyze', 'success', 0, null], ['test', 'success', 2, 70.8], ['build_android', 'success', 4, null]]),
  'run-101': stubJobs('run-101', [['analyze', 'success', 0, null], ['test', 'failure', 2, 58.1]]),
  'run-100': stubJobs('run-100', [['analyze', 'success', 0, null], ['test', 'success', 2, 72.5], ['build_release', 'success', 4, null], ['deploy_backend', 'success', 5, null], ['publish', 'success', 6, null]]),
  'run-99': stubJobs('run-99', [['analyze', 'cancelled', 0, null]]),
}

const lvl = (L: LogEntry['level']) => L

export const stubLogs: LogEntry[] = [
  { id: 'log-2', level: lvl('warn'), service: 'mobile-app', message: 'verifyOtp rejected: OtpType.magiclink used for 6-digit code', createdAt: ago(28), appEnv: 'production', context: { screen: 'otp', hint: 'expected OtpType.email' } },
  { id: 'log-3', level: lvl('info'), service: 'supabase-auth', message: 'signup succeeded for user +96650****', createdAt: ago(41), appEnv: 'production' },
  { id: 'log-4', level: lvl('error'), service: 'postgres-db', message: 'release_stale_locks has no scheduled runner (pg_cron miss)', createdAt: ago(75), appEnv: 'production', context: { rpc: 'release_stale_locks' } },
  { id: 'log-5', level: lvl('info'), service: 'mobile-app', message: 'booking created (pending)', createdAt: ago(120), appEnv: 'production', context: { bookingStatus: 'pending' } },
  { id: 'log-6', level: lvl('debug'), service: 'mobile-app', message: 'locale switched to ar', createdAt: ago(190) },
  { id: 'log-8', level: lvl('info'), service: 'edge-functions', message: 'ci-report: run #103 finalized (success)', createdAt: ago(1465), appEnv: 'production', context: { run: 103 } },
  { id: 'log-9', level: lvl('debug'), service: 'database', message: 'courts: 6 rows scanned for search "tennis"', createdAt: ago(380) },
  { id: 'log-10', level: lvl('error'), service: 'mobile-app', message: 'Unhandled exception on BookingStep2 add-ons', createdAt: ago(520), appVersion: '1.0.0+1', context: { stackTop: 'late Locale error' } },
  { id: 'log-11', level: lvl('info'), service: 'mobile-app', message: 'session restored for existing user', createdAt: ago(2), appEnv: 'production' },
  { id: 'log-12', level: lvl('debug'), service: 'edge-functions', message: 'heartbeat updated for edge-functions', createdAt: ago(9) },
]

export const stubMetrics: MetricPoint[] = [
  { label: '00:00', requests: 420, errors: 6, latencyP95: 180 },
  { label: '02:00', requests: 310, errors: 4, latencyP95: 160 },
  { label: '04:00', requests: 240, errors: 2, latencyP95: 150 },
  { label: '06:00', requests: 380, errors: 5, latencyP95: 170 },
  { label: '08:00', requests: 820, errors: 12, latencyP95: 260 },
  { label: '10:00', requests: 1040, errors: 15, latencyP95: 310 },
  { label: '12:00', requests: 920, errors: 11, latencyP95: 290 },
  { label: '14:00', requests: 760, errors: 9, latencyP95: 250 },
  { label: '16:00', requests: 680, errors: 8, latencyP95: 230 },
  { label: '18:00', requests: 1120, errors: 14, latencyP95: 320 },
  { label: '20:00', requests: 990, errors: 13, latencyP95: 300 },
  { label: '22:00', requests: 540, errors: 7, latencyP95: 200 },
]

export const stubCourts: Court[] = [
  { id: 'c1', name: 'Riyadh Court 1', center: 'King Abdullah Park', sport_type: 'Tennis', location: 'Riyadh', address: 'Olaya St', image_url: null, rating: 4.8, reviews_count: 214, likes_count: 890, price_per_hour: 120, latitude: 24.72, longitude: 46.67, is_active: true, created_at: ago(100000), bookings_count: 342 },
  { id: 'c2', name: 'North Padel Club', center: 'North Riyadh', sport_type: 'Padel', location: 'Riyadh', address: 'King Fahd Rd', image_url: null, rating: 4.6, reviews_count: 158, likes_count: 420, price_per_hour: 150, latitude: 24.86, longitude: 46.71, is_active: true, created_at: ago(90000), bookings_count: 221 },
  { id: 'c3', name: 'Al Wadi Football Arena', center: 'Al Wadi', sport_type: 'Football', location: 'Riyadh', address: 'Al Wadi District', image_url: null, rating: 4.4, reviews_count: 96, likes_count: 305, price_per_hour: 200, latitude: 24.63, longitude: 46.55, is_active: true, created_at: ago(80000), bookings_count: 187 },
  { id: 'c4', name: 'Downtown Hoops', center: 'Downtown NYC', sport_type: 'Basketball', location: 'New York', address: '5th Ave', image_url: null, rating: 4.7, reviews_count: 302, likes_count: 1200, price_per_hour: 90, latitude: 40.74, longitude: -73.98, is_active: false, created_at: ago(70000), bookings_count: 0 },
]

export const stubCoaches: Coach[] = [
  { id: 'co1', full_name: 'Donald Khalid', username: 'donaldkhalid', avatar_url: null, sport_type: 'Tennis', rating: 4.8, price_per_session: 150, bio: 'Professional tennis coach with 10+ years experience', experience: 10, latitude: 24.72, longitude: 46.67, is_active: true, created_at: ago(60000) },
  { id: 'co2', full_name: 'Sarah Ahmed', username: 'sarahahmed', avatar_url: null, sport_type: 'Tennis', rating: 4.9, price_per_session: 200, bio: 'Former WTA player, certified coach', experience: 8, latitude: 24.73, longitude: 46.68, is_active: true, created_at: ago(59000) },
  { id: 'co3', full_name: 'Mohammed Ali', username: 'mohammedali', avatar_url: null, sport_type: 'Football', rating: 4.7, price_per_session: 120, bio: 'AFC certified football coach', experience: 12, latitude: 24.71, longitude: 46.66, is_active: true, created_at: ago(58000) },
  { id: 'co4', full_name: 'Fatima Hassan', username: 'fatimahassan', avatar_url: null, sport_type: 'Padel', rating: 4.6, price_per_session: 130, bio: 'Padel specialist, national team coach', experience: 5, latitude: 24.74, longitude: 46.69, is_active: false, created_at: ago(57000) },
  { id: 'co5', full_name: 'Khalid Omar', username: 'khalidomar', avatar_url: null, sport_type: 'Basketball', rating: 4.5, price_per_session: 100, bio: 'Youth basketball development coach', experience: 7, latitude: 24.7, longitude: 46.65, is_active: true, created_at: ago(56000) },
]

export const stubOverview: SystemOverview = {
  serviceCount: 5,
  servicesDown: 1,
  activeCourts: stubCourts.filter((c) => c.is_active).length,
  activeCoaches: stubCoaches.filter((c) => c.is_active).length,
  users: 1284,
  bookingsToday: 46,
  successRatePct: 99.2,
  p95LatencyMs: 310,
  lastDeploy: { version: '1.0.0', at: ago(1465) },
  errorsLast24h: 63,
}