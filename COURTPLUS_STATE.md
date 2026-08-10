# Court+ — Current State Summary (August 2026)

**Framework:** Flutter 3.10+ | **Backend:** Supabase (Postgres + Edge Functions) | **dart analyze:** 0 errors, 14 infos (clean compile)

---

## ✅ WHAT EXISTS & WORKS

### Backend (Supabase)
- **15 database tables** fully defined with RLS: `profiles`, `courts`, `court_slots`, `bookings`, `matches`, `match_players`, `invitations`, `reviews`, `moments`, `moment_likes`, `moment_comments`, `favorites`, `follows`, `payments`, `notifications`, `coaches`
- **7 migrations** applied covering schema, seed data, production hardening, RLS hardening, and slot-locking fixes
- **5 RPC functions:** `lock_booking_slot`, `confirm_booking_payment`, `release_slot_lock`, `search_courts` (full-text + geo-radius), `get_available_slots`, `release_stale_locks`
- **3 Supabase Edge Functions:** `create-payment-intent` (Stripe), `stripe-webhook`, `create-test-user`
- **Triggers:** auto-profile creation on auth signup, `update_updated_at`, `update_moment_likes_count`, `update_follow_counts`
- **Seed data:** 6 courts in Riyadh, 7 coaches (5 Riyadh + 2 NYC), 30 days × 17 hourly slots per court
- **`lock_booking_slot` fix applied** (migration 00007) — the `court_name` NOT NULL bug that broke booking inserts is fixed in SQL

### Frontend (Flutter) — Auth Flow
- ✅ **Splash → Language → Onboarding → Signup → OTP → Profile Setup → Home** pipeline is fully built
- ✅ **Auth methods:** email OTP, phone OTP, Google OAuth, Apple OAuth — all wired through `SupabaseService` + `AuthNotifier`
- ✅ **Rate-limiting** on OTP sends (60s cooldown)
- ✅ **Persistent sessions** via Supabase auth, auto-login on restart

### Frontend — Core Screens
- ✅ **Home screen** — location bar, search bar, category chips, horizontal court cards, quick-action cards, bottom nav
- ✅ **Courts list** — fetches from Supabase via `courtsProvider`, filters by sport type
- ✅ **Court Details** — 4 tabs (Details, Availability, Specs, Moments)
- ✅ **Booking flow** — 4-step wizard (Date/Time → Duration → Add-ons → Review) with real slot data from `get_available_slots` RPC
- ✅ **Activity screen** — tabs for current bookings + booking history, countdown timers, review flow
- ✅ **Explore** — Google Maps with courts/coaches markers from backend
- ✅ **Profile** — cover photo, avatar, stats, moments grid
- ✅ **Coaches list + detail** — real data from Supabase
- ✅ **Moments list + creation** — real data from Supabase
- ✅ **Notifications screen** — real data from `notifications` table
- ✅ **Settings** — language toggle, notification prefs, logout
- ✅ **Invitations** — list, accept/decline, send
- ✅ **Create Match** — court selection, date/time, level, gender, privacy, player count
- ✅ **Invite Players** — search, suggested, send invitations
- ✅ **Deep link service** — `courtplus://invite?match_id=xxx` cold + warm handling
- ✅ **Image service** — pick from gallery → upload to Supabase Storage
- ✅ **Localization** — full EN + AR (220+ keys each), `AppStrings.of(context).t('key')` pattern available

### Architecture
- ✅ Riverpod state management (8+ providers: auth, courts, booking, match, reviews, settings, invitations, coaches, moments)
- ✅ Result monad pattern for error handling
- ✅ Logger service
- ✅ Validators (email, username, OTP, etc.)
- ✅ `.env` + `--dart-define` config strategy
- ✅ `flutter analyze` passes with 0 errors

---

## ❌ WHAT IS BROKEN / BLOCKING

### 1. 🚨 Dark Theme Forced — User Wants Light
`main.dart` line 70: `themeMode: ThemeMode.dark`. The user has repeatedly said light theme. And it's **inconsistent** — auth screens use `AppColors.darkBg` (#0D1117), newer screens like Activity use `AppColors.lightBg` (white), while booking step 2/4 use `darkField`/`darkBorder` on a light scaffold. It looks like a half-finished migration from dark to light. Some screens are white, some are dark, some mix both.

### 2. 🚨 Payment is a Simulation, Not Real Stripe
The `PaymentGatewayScreen` literally has a yellow warning box saying *"Stripe payment integration is coming soon. Your booking will be recorded and payment will be processed when the gateway goes live."* The Edge Functions (`create-payment-intent`, `stripe-webhook`) exist server-side but the Flutter app never calls them. Instead it calls `processPayment()` which just inserts a record directly into the `payments` table. The `confirm_booking_payment` RPC is **never invoked** — bookings stay in `pending` status forever.

### 3. 🚨 Missing l10n on Most Screens
Despite having a full 220+ key Arabic/English localization system, most screens use **hardcoded English strings**. Screens that skip localization:
- `BookingStep1Screen` — title 'Booking', 'Select Date', 'Select Time', 'Next', 'No available slots'
- `BookingStep2Screen` — title 'Add-ons', 'Rate per hour', 'Select Duration', 'Total', step labels
- `BookingStep4Screen` — 'Review Booking', 'Booking Summary', 'Court', 'Center', 'Duration', 'Court Fee', 'Add-ons', 'Total', 'Pay Your Part', 'Pay Everything', 'Book Summary', etc.
- `PaymentGatewayScreen` — 'Payment', 'Order Summary', 'Court Fee', 'Select Payment Method', 'Apple Pay', etc.
- `ActivityScreen` — 'Activity', 'Current bookings', 'Booking History', 'No bookings yet', etc.
- `BookingCard` — 'FRIENDS', 'COACH', 'Enter Court', 'Capture a Court+ Moment', 'Reviewed', 'Add Review'
- `ProfileScreen` — 'Following', 'Follower', 'My Profile', 'Update', 'My Moments', 'No moments yet', 'Share your first moment!', 'courts played', 'court times', 'sessions'
- `ExploreScreen` — partially uses `AppStrings` but has inline strings

This means **Arabic users get English UI** on every booking and profile screen.

### 4. 🔶 `court_name` Null Bug Was in Production
The original `lock_booking_slot` RPC (migration 00003) inserted into `bookings` without setting `court_name` — which is `NOT NULL`. This caused every booking attempt to fail with a Postgres error. Migration 00007 fixed this. **The question is: was 00007 ever deployed?** The fix exists in the migration file but may not be applied on the live Supabase project.

### 5. 🔶 Two Parallel Screen Directories
There are **two versions** of several screens:
- `lib/screens/` (older) — `invitation_details_screen.dart`
- `lib/presentation/screens/match/` (newer) — `invitation_details_screen.dart`
- `lib/presentation/screens/activity/` (newer, in use) vs older activity screens

This suggests a partial refactor. Some old and new files coexist, which is confusing and risks stale imports.

### 6. 🔶 Activity Screen Has Its Own Booking Model
The activity screen defines its own `BookingStatus` enum (`beforeMatch`, `duringMatch`, `afterMatch`) and `BookingItem` class that don't exist in the canonical `models.dart`. It converts backend `Booking` objects but uses hardcoded assets (`assets/images/court1.jpg`) and empty friend/coach data since the backend doesn't store those details per booking.

### 7. 🔶 Home Screen Has Duplicate Notification Icon
The AppBar has both a `leading` and an `actions` element showing the same notification bell icon — looks like a leftover from copy-paste.

---

## ⚠️ WHAT IS MISSING / NOT BUILT

### Frontend
- **❌ No push notifications** — `notifications` table exists but the app has no Supabase Realtime subscription, no FCM/APNs setup, no notification service
- **❌ No Supabase Storage buckets** — `ImageService.pickAndUploadImage` expects `bucket` parameter but no migration creates the buckets
- **❌ No `moment_likes` / `moment_comments` / `favorites` / `follows` frontend** — tables exist in SQL with triggers, but the Flutter app has no UI for liking moments, commenting, favoriting courts, or the follow/unfollow social graph
- **❌ No Sentry/crash reporting** — `AppConfig.sentryDsn` is configured but `sentry_flutter` isn't in pubspec.yaml
- **❌ No unit/widget tests** — `test/` directory exists but coverage is minimal or nonexistent
- **❌ `MockDataService` is a dead stub** — removed its data but not its references, `TESTING_GUIDE.md` still claims mock data is the default
- **❌ No real-time court slot updates** — `get_available_slots` is polled, not subscribed via Realtime

### Backend
- **❌ No cron job for `release_stale_locks`** — the RPC exists but there's no `pg_cron` setup or scheduled task to actually run it
- **❌ No notification triggers** — tables for notifications exist but there are no DB triggers that auto-create notifications on booking confirmation, match invites, etc.
- **❌ `create-test-user` edge function exists but is not wired** — the Flutter app has no "test user" button to call it

### Known Tech Debt
- `flutter_lints: ^6.0.0` but no `dart format` consistency enforced
- `flutter_svg: ^2.3.0` dependency but SVG usage appears minimal
- No `build_runner` usage despite having `mockito` + `build_runner` in dev_dependencies
- `Deprecated: anonKey` warning — should be updated to `publishableKey`

---

## BOTTOM LINE

**The app compiles cleanly and the auth → booking → payment flow works end-to-end as a simulation.** The backend schema is comprehensive and well-designed with proper RLS, atomic slot locking, and Stripe edge functions ready to go.

**But it has two real blockers:** (1) dark theme is forced when the user wants light, and (2) payment does a fake insert instead of calling Stripe — bookings are created but never confirmed. And most screens aren't localized despite having the infrastructure in place.