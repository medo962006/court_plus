# Court+ Operations Dashboard — Phase 1 Discovery Blueprint

> **Status:** Phase 1 — discovery & requirements (this document). No code written yet.
> **Grounded in:** actual code read from `flutter_court_plus` (migrations 00001–00007, `lib/core/logger.dart`, `lib/core/config.dart`, `.github/workflows/ci.yml`, `pubspec.yaml`, state docs).
> **Goal:** Define everything the ops dashboard must contain that the app does NOT have today, plus the gaps that gate release.

---

## 1. What the dashboard is

A **separate web admin panel** (not the mobile app) that gives the Court+ operator three surfaces:

| Pillar | What it shows | What exists today |
|---|---|---|
| **A. Logs · Monitoring · Observability** | Central logs, crash/error aggregation, health/uptime, request telemetry, alerts | ❌ Console-only logger that is **silent in release**; `SENTRY_DSN` config present but unused |
| **B. CI/CD visibility** | Live pipeline runs, per-job status, coverage trend, release candidates, deployed version | ❌ One minimal `ci.yml` (analyze→test→debug APK); nothing reports into any database |
| **C. Courts & Coaches management** | Admin CRUD for courts + coaches | ❌ **No admin/role concept anywhere** (no `role` column, no `is_admin`) |

All three share one backend (Supabase) so a single dashboard can serve all three.

---

## 2. Confirmed findings driving this design (from code)

### A. Observability gap
- `lib/core/logger.dart`: `AppLogger` only prints to console in debug; in release it sets `level = WARNING` and **discards everything**. There is no remote sink.
- `lib/core/config.dart`: `sentryDsn`, `enableCrashReporting`, `enableAnalytics` all exist. `pubspec.yaml` has **no** `sentry_flutter` dependency. So crash reporting is 100% un-wired despite the plumbing.
- No server-side request/error logging. The 3 Edge Functions use default `console.*` logging only.
- No health check / heartbeat / uptime signal exists.

### B. CI/CD gap
- `.github/workflows/ci.yml` runs only on `push` to `main`/`dev` and PRs to `main`: analyze → test (codecov) → `flutter build apk --debug` → upload artifact.
- No release build (AAB), no signing, no Edge Function deploy, no Supabase migration apply, no version bump, no GitHub Release, no store publish.
- Nothing records pipeline status into a database, so there is **nothing for a dashboard to display today**.

### C. Admin gap
- `profiles` (`00001_init.sql:10`) has **no** `role`/`is_admin` column.
- `courts` (`:33`) and `coaches` (`00005_add_coaches.sql:4`) are plain CRUD tables with `is_active` toggles and RLS that only allows public `SELECT`, authenticated `INSERT` (courts), no admin write path.
- Therefore "manage courts and coaches" requires **new admin authorization** before any CRUD screen can be trusted.

### D. Release blockers the dashboard must eventually **track** (from `COURTPLUS_HONEST_STATE.md`)
1. Auth broken: `verifyOtp` uses `OtpType.magiclink` instead of `OtpType.email` (`supabase_service.dart:128`); login fields have **no controllers**; OTP screen resends on load.
2. Payment is a simulation — no real Stripe, `confirm_booking_payment` RPC never called.
3. Dark theme forced (`main.dart:70 themeMode: ThemeMode.dark`) — user wants light.
4. l10n missing on most feature screens (only 220+ keys exist in infra).
5. `release_stale_locks` RPC exists but no `pg_cron` job runs it.
6. No push notifications / Realtime subscriptions wired.

---

## 3. Proposed scope — dashboards to build

### 3A. Observability ("Logs / Monitor")
- **Central log sink:** new table `system_logs` (`id, level, service, message, context jsonb, user_id?, app_version, app_env, created_at`).
  - Ingest path 1: **Flutter client** batches logs and POSTs to an Edge Function (buffered, sampled, offline-safe).
  - Ingest path 2: **Edge Functions** write their own structured logs to the same table (their `console.log` is not queryable outside Supabase).
  - Ingest path 3: **CI** writes build/event logs.
- **Crash/error aggregation:** Adopt **Sentry** (DSN already in `.env.production`, golden path) for the mobile app; dashboard reads Sentry API. Fallback: own `error_reports` table if user wants no third party.
- **Health/uptime:** a `service_heartbeats` table; Edge Functions + app `ping` update last-seen; dashboard shows per-service status, error rate, P95 latency, uptime %. Alerting on missed heartbeat / error-rate spike.
- **Alerting:** thresholds → in-app notification + optional `notifications`/`alerts` row.

### 3B. CI/CD visibility
- New table `pipeline_runs`: `(id, run_number, branch, event, commit_sha, commit_msg, author, status, started_at, finished_at, duration_ms, trigger)`.
- New table `pipeline_jobs`: `(id, run_id, name, status, conclusion, started_at, finished_at, logs_url, coverage_pct, artifact_url, version)`.
- **Reporting path:** GitHub Actions posts to a new `ci-report` Edge Function (service role) at job/run completion. Dashboard reads via Supabase and live-updates via **Realtime**.
- **Complete pipeline** (see §4) produces: release AAB + signed, deployed Edge Functions, applied migrations, GitHub Release, coverage %, deploy commit tag.

### 3C. Courts & Coaches management
- **Admin authorization** (required foundation): add `role` to `profiles` (values `user`|`admin`|`staff`) OR a dedicated `admins` table; admin-only RLS + `SECURITY DEFINER` admin functions; dashboard signs in as an admin user.
- **Courts admin:** list/search, create, edit (name, center, sport, location, address, coords, price, rating, image), toggle `is_active`, delete (soft), see booking/popularity counts per court.
- **Coaches admin:** list/search, create, edit (name, username, avatar, sport, price, rating, bio, experience, coords), toggle `is_active`, approve/verify.
- Every admin action written to an **audit trail** (`admin_audit_log`: admin_id, action, target_table, target_id, before/after jsonb, timestamp).

---

## 4. Full CI/CD pipeline (to be built & tracked)

1. `analyze` — `dart analyze lib/` + `flutter analyze` (gate: 0 errors).
2. `test` — `flutter test --coverage` → coverage %, posts to `pipeline_jobs`.
3. `build_release` — version bump from git tag; `flutter build appbundle --release` (Android) & `.ipa` (iOS via Fastlane/Codemagic).
4. `sign` — Android keystore (secrets), iOS certs.
5. `deploy_backend` — `supabase db push` migrations; `supabase functions deploy` each Edge Function (`--no-verify-jwt` where documented).
6. `publish` — create GitHub Release with AAB/IPA + changelog; optional Play/Firebase App Distribution upload.
7. Every step POSTs status to `ci-report` Edge Function → dashboard.
8. **Rollback plan:** keep last-good migration + previous release artifacts downloadable from dashboard.

---

## 5. New backend objects needed (summary)

- **Tables:** `system_logs`, `service_heartbeats`, `pipeline_runs`, `pipeline_jobs`, `admin_audit_log`; `profiles.role` column (+ migration `00008`).
- **Edge Functions:** `ingest-logs`, `heartbeat`, `ci-report` (all service-role, guarded), plus health endpoint.
- **RPCs:** admin CRUD helpers (SECURITY DEFINER), `get_metrics`, `get_system_overview`.
- **pg_cron:** job to run `release_stale_locks` + prune old logs.
- **Realtime:** enable on `system_logs`, `pipeline_runs`, `service_heartbeats` for live dashboard.

---

## 6. Open decisions (need your call)

1. **Dashboard platform:**
   - (a) **Flutter web** — reuses your existing light theme, Phosphor icons, l10n; heavier to host.
   - (b) **Vite + React/TypeScript + Tailwind** — light, fast, best charting/Realtime story; needs a new stack in the repo.
   - (c) **Single-file HTML + Supabase JS** — fastest to ship, matches your CodiSpark pattern, but charting/live-updates get cramped.
2. **Crash reporting:** Sentry (proven, DSN present) vs fully self-hosted Supabase `error_reports` (no third party).
3. **Mobile release automation:** GitHub Actions only for Android AAB + Expo of release, or also Fastlane/Codemagic for iOS?
4. **Where CI status is stored locally first:** use a stub (`pipeline_runs` seeded manually) to build the dashboard UI before wiring Actions?

---

## 7. Suggested build order (Phase 2+)

1. **Foundations:** `00008` migration (role + 5 tables), admin auth & RLS, dashboard scaffold.
2. **Courts/Coaches admin UI** + audit trail (fast win, uses existing data).
3. **CI/CD reporting contract** + `ci-report` function + full pipeline rewrite + dashboard pipeline view.
4. **Log/observability ingest** + dashboard logs/metrics/health view.
5. **Crash reporting** wire (Sentry) + error view.
6. **Alerting + Realtime** live updates.

Find the git-tracked release blockers list in `COURTPLUS_HONEST_STATE.md`; the dashboard should grow a "Release Readiness" checklist surfacing each item so pushing to release is tracked on the dashboard itself.

---

## 8. Risks / tradeoffs
- **Admin auth must come first** — any court/coach CRUD without role-gating is a security hole.
- **Don't over-build observability** — Sentry covers client errors very well; a full custom metric system is scope creep at phase 1. Start with logs + heartbeats + Sentry and grow.
- **CI reporting adds a dependency on a network call from Actions → Edge Function**; if it fails, pipeline should still pass and mark reporting "degraded".
- **The `pg_cron` + Realtime features** require the Supabase project to have those extensions enabled (confirm on the live project).