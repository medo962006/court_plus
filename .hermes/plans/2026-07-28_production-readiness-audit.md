# Production Readiness — Court+ Architectural Audit

**Date:** 2026-07-28  
**Codebase:** 41 Dart files, 34 screens, ~10,700 LOC  
**Target:** Enterprise-grade sports court booking platform

---

## 1. Security & Authentication

| Concern | Current State | Risk | Required Action |
|---------|--------------|------|-----------------|
| **Auth Provider** | Supabase stubs only — no real auth flow | 🔴 CRITICAL | Wire Supabase Auth with email/phone + OTP |
| **RBAC** | None — all users treated identically | 🔴 HIGH | Define roles: Player, Coach, Admin, SuperAdmin |
| **Token Rotation** | No session management | 🔴 HIGH | Implement token refresh via Supabase `onAuthStateChange` |
| **Input Sanitization** | None — raw TextField values passed through | 🔴 HIGH | Add input validation on all forms (XSS, injection) |
| **OTP Rate Limiting** | 30s timer is client-side only | 🔴 HIGH | Server-side rate limiting + exponential backoff |
| **API Key Storage** | Hardcoded placeholder in `models.dart` | 🔴 CRITICAL | Move to `.env` + flutter_dotenv + build-time injection |
| **Payment Data** | No PCI compliance | 🔴 HIGH | Use Stripe/Moyasar SDK — never touch raw card data |
| **Deep Link Spoofing** | No deep link validation | 🟡 MEDIUM | Validate incoming deeplink signatures |

### Auth Architecture (Target)

```
Supabase Auth (OTP/Email)
  → AuthService (singleton, reactive)
    → onAuthStateChange stream
      → AuthGuard (route-level middleware)
        → UserProvider (Riverpod)
```

---

## 2. Database & Storage

| Concern | Current State | Risk | Required Action |
|---------|--------------|------|-----------------|
| **Schema** | None defined | 🔴 CRITICAL | Design full Supabase schema with RLS policies |
| **Migrations** | None | 🔴 CRITICAL | Set up `supabase migration` versioned files |
| **Connection Pooling** | Not configured | 🟡 MEDIUM | Supabase handles this, but tune pool size |
| **Indexing** | None | 🔴 HIGH | Add indexes on: user_id, court_id, date, status |
| **RLS Policies** | None (using anon key) | 🔴 CRITICAL | Row-level security per table |
| **Full-Text Search** | Not implemented | 🟡 MEDIUM | Add `tsvector` on courts.name + courts.location |
| **Asset Storage** | Local `assets/images/` only | 🟡 MEDIUM | Migrate to Supabase Storage (S3-compatible) |
| **Offline Support** | None | 🟡 MEDIUM | Add sqlite/Isar local cache with sync |

### Supabase Schema (Required Tables)

```
profiles        — extends auth.users
courts          — with coordinates, images, hours
bookings        — with payment status, timestamps
matches         — open match listings
match_players   — join table: matches × profiles
invitations     — match invites
reviews         — court reviews with ratings
moments         — user photo posts
notifications   — push notification queue
```

---

## 3. Performance & Scalability

| Concern | Current State | Risk | Required Action |
|---------|--------------|------|-----------------|
| **State Management** | `setState()` everywhere | 🔴 HIGH | Adopt Riverpod 2.x with code generation |
| **Caching** | None — every screen re-fetches | 🔴 HIGH | Riverpod `family` providers + `keepAlive` |
| **Image Optimization** | Raw PNGs (190MB debug APK) | 🔴 HIGH | Add `cached_network_image` + progressive JPEG |
| **List Performance** | No pagination | 🔴 HIGH | Add cursor-based pagination to all list queries |
| **Lazy Loading** | Not implemented | 🟡 MEDIUM | Lazy load screens, images, map tiles |
| **Bundle Size** | 190MB debug APK | 🟡 MEDIUM | Enable code shrinking, R8, asset compression |
| **Payload Size** | Full model serialization | 🟡 MEDIUM | Add `toJson` with selective field projection |
| **Cold Start** | No splash preloading | 🟡 MEDIUM | Pre-warm auth + location + home data on splash |

### State Architecture (Target)

```
Riverpod 2.x
  ├── AuthNotifier (AsyncNotifier) — login/logout/refresh
  ├── CourtProvider (FutureProvider.family) — by id
  ├── CourtsListProvider (AsyncNotifier) — with pagination
  ├── BookingProvider (StateNotifier) — multi-step form
  ├── MatchProvider (AsyncNotifier) — with filters
  ├── NotificationProvider (StreamProvider) — real-time
  └── ThemeProvider (StateProvider) — dark/light
```

---

## 4. Infrastructure & DevOps

| Concern | Current State | Risk | Required Action |
|---------|--------------|------|-----------------|
| **CI/CD** | None | 🔴 CRITICAL | GitHub Actions: lint → test → build → deploy |
| **Docker** | No containerization | 🟡 MEDIUM | Dockerfile for Flutter web + backend |
| **APK Distribution** | Manual build only | 🔴 HIGH | Add Fastlane + Firebase App Distribution |
| **Environment Config** | Hardcoded values | 🔴 HIGH | `.env` → BuildConfig → compile-time injection |
| **Logging** | No structured logging | 🔴 HIGH | Add `logging` package + crashlytics |
| **Error Tracking** | No crash reporting | 🔴 HIGH | Add Sentry/Firebase Crashlytics |
| **APM** | None | 🟡 MEDIUM | Add Firebase Performance monitoring |
| **Feature Flags** | None | 🟡 LOW | Add `launchdarkly_flutter` for phased rollouts |
| **Code Signing** | Debug keystore only | 🔴 HIGH | Generate release keystore + upload to Play Console |

### CI/CD Pipeline (Target)

```
Git Push → GitHub Actions
  ├── analyze (dart analyze, flutter analyze)
  ├── test (unit + widget + integration)
  ├── build_apk (flutter build apk --release)
  ├── build_appbundle (flutter build appbundle)
  └── deploy (Firebase App Distribution — alpha testers)
```

---

## 5. Testing & Quality Assurance

| Concern | Current State | Risk | Required Action |
|---------|--------------|------|-----------------|
| **Unit Tests** | 0 tests | 🔴 CRITICAL | Test all services, models, validators |
| **Widget Tests** | 1 default file | 🔴 CRITICAL | Test every screen (smoke + interaction) |
| **Integration Tests** | 0 tests | 🔴 HIGH | Test critical flows (auth → book → pay) |
| **Golden Tests** | 0 tests | 🟡 MEDIUM | Pixel-match screenshots per screen |
| **Load Tests** | 0 tests | 🟡 MEDIUM | k6 script for booking API endpoints |
| **Test Coverage Gate** | Not configured | 🟡 MEDIUM | Enforce ≥80% in CI |
| **Mocks** | None | 🔴 HIGH | Add `mockito` for Supabase client mocking |

### Test Categories (Target)

```
test/
  ├── unit/
  │   ├── services/
  │   │   ├── auth_service_test.dart
  │   │   ├── booking_service_test.dart
  │   │   └── payment_service_test.dart
  │   ├── models/
  │   │   └── models_test.dart
  │   └── validators/
  │       └── form_validators_test.dart
  ├── widget/
  │   ├── screens/
  │   │   ├── login_screen_test.dart
  │   │   ├── booking_flow_test.dart
  │   │   └── profile_screen_test.dart
  │   └── widgets/
  │       └── court_card_test.dart
  └── integration/
      └── auth_flow_test.dart
```

---

## 6. Code Quality & Architecture

| Concern | Current State | Risk | Required Action |
|---------|--------------|------|-----------------|
| **Architecture Pattern** | Monolithic screen files | 🔴 HIGH | Extract business logic into services/repos |
| **Error Handling** | No try/catch anywhere | 🔴 CRITICAL | Add Result<T> pattern + global error handler |
| **Loading States** | Not implemented | 🔴 HIGH | Add Shimmer/skeleton loading on all async screens |
| **Empty States** | Not implemented | 🟡 MEDIUM | Add empty state illustrations |
| **Form Validation** | Duplicated per screen | 🟡 MEDIUM | Create `Validators` mixin class |
| **Dependency Injection** | Manual singletons | 🟡 MEDIUM | Add `get_it` service locator |
| **Localization** | English only (onboarding mentions Arabic) | 🟡 MEDIUM | Add `flutter_localizations` + ARB files |
| **Accessibility** | No semantic labels | 🟡 MEDIUM | Add `Semantics` widgets |
| **Dark Mode** | Theme defined but inconsistent | 🟡 MEDIUM | Audit all screens for dark mode compliance |

### Clean Architecture (Target)

```
lib/
  ├── core/          — constants, network, errors, theme
  ├── data/          — repositories, datasources, DTOs
  │   ├── datasources/
  │   ├── models/
  │   └── repositories/
  ├── domain/        — entities, use cases, repository interfaces
  │   ├── entities/
  │   └── usecases/
  └── presentation/  — screens, providers, widgets
      ├── providers/
      ├── screens/
      └── widgets/
```

---

## Priority Matrix

| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| 🔴 P0 | Auth (Supabase OTP + JWT) | 2d | Blocks all features |
| 🔴 P0 | Supabase schema + RLS | 1d | Blocks data layer |
| 🔴 P0 | Error handling + loading states | 1d | UX necessity |
| 🔴 P1 | Riverpod state management | 2d | Architecture foundation |
| 🔴 P1 | Testing (unit + widget) | 3d | Quality gate |
| 🔴 P1 | CI/CD pipeline | 1d | Release automation |
| 🟡 P2 | Pagination + caching | 1d | Performance |
| 🟡 P2 | Environment config (.env) | 0.5d | Security |
| 🟡 P2 | Image optimization | 0.5d | Bundle size |
| 🟡 P2 | Logging + crash reporting | 1d | Observability |
| 🟢 P3 | L10n/i18n | 2d | Market expansion |
| 🟢 P3 | Dark mode audit | 1d | UX polish |
| 🟢 P3 | Accessibility | 1d | Compliance |

---

**Total estimated effort:** ~16 days for P0+P1, +6 days for P2+P3 = ~22 days production readiness.

**Next goal (Turn 2):** `/goal` Implement P0 items: Supabase Auth wiring, Schema/RLS design, and Error handling infrastructure.