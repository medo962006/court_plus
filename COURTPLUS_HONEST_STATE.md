# Court+ — HONEST State Summary (August 2026)
## What I found by actually tracing the code, not just reading file listings

---

## 🚨 AUTH IS BROKEN — Two Critical Bugs

### Bug #1: `verifyOtp` uses wrong `OtpType` (line 128 of `supabase_service.dart`)

```dart
final response = await _auth.verifyOTP(
  email: email,
  token: code,       // ← 6-digit user-entered code
  type: OtpType.magiclink,  // ← WRONG! Should be OtpType.email
);
```

**What the user sees:** They enter the 6-digit code from their email. Verification fails with "Invalid code".

**Why:** In `gotrue 2.26.0`, `OtpType.magiclink` expects a PKCE token hash from a magic link URL (a long random string). For a 6-digit email OTP code, the enum is `OtpType.email`. The GoTrue REST API receives `type=magiclink` instead of `type=email` and can't validate the short numeric token.

**The `OtpType.email` value exists** — it was added to the enum specifically for this use case. The code just never uses it.

### Bug #2: Login Screen Navigates to OTP Without Sending Any OTP

```dart
// login_screen.dart line 132-134
ElevatedButton(
  onPressed: () => Navigator.of(context).pushNamed(Routes.otp),
  child: const Text('Login'),
),
```

**What happens:**
1. Login screen has "Phone number" + "Password" fields (but the phone field has **no controller** — it's `const _PhoneField()` with no way to read the value, and password field also has no controller)
2. User taps "Login" → **blindly navigates to OTP screen** — no OTP is sent, no fields are read
3. OTP screen's `initState` calls `_startResendTimer()` → calls `resendOtp()` → `state.otpSentTo` is `null` → returns "No email or phone to resend to" error
4. User enters code anyway → `_verifyOtp()` checks `email = state.otpSentTo` → `null` → **silently returns without doing anything**

**Login is completely non-functional.** The fields are decorative, the button does nothing useful.

### Bug #3 (compounding): OTP Screen Resends OTP Immediately on Load

```dart
// otp_screen.dart initState
@override
void initState() {
    super.initState();
    _startResendTimer();  // ← immediately sends a NEW OTP, invalidating the one
                          //   that was just sent by the signup flow
```

Even in the signup flow (which does send an OTP before navigating), the OTP screen immediately sends another one, consuming rate limits and potentially invalidating the first code. The resend should only happen on user action, not on screen load.

---

## 🚨 PAYMENT IS A SIMULATION

The Stripe integration **does not work**. Both the code AND the config are broken:

1. **No Stripe publishable key in `.env`** — `.env` only has `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_MAPS_API_KEY`. No `STRIPE_PUBLISHABLE_KEY` is set.
2. `PaymentService.init()` will set `Stripe.publishableKey = ''` (empty string), which will fail silently.
3. The `PaymentGatewayScreen` has a yellow warning box saying *"Stripe payment integration is coming soon"* and calls `processPayment()` which just inserts a fake record directly into the `payments` table.
4. The `confirm_booking_payment` RPC is **never called** — bookings stay in `pending` status permanently.

---

## 🚨 DARK THEME FORCED

`main.dart` line 70: `themeMode: ThemeMode.dark`. This makes the app render with a dark color scheme. The signup and login screens use `AppColors.darkBg` (#0D1117). But newer screens (Activity, Profile, BookingStep1) use white backgrounds with `AppColors.lightBg`, creating an inconsistent mix.

---

## 🚨 NO L10N ON MOST SCREENS

Despite having `AppStrings.of(context).t('key')` infrastructure with 220+ Arabic/English keys, the following screens use **hardcoded English strings**:
- All 4 booking step screens, Payment Gateway, Booking Success/Ticket
- Activity screen, Booking card, Profile, Review bottom sheets, Explore
- Settings, Notifications, Invitations, Coaches, Moments, Create Match

Arabic users see English on every feature screen.

---

## 🚨 LOGIN SCREEN FIELDS HAVE NO CONTROLLERS

```dart
// login_screen.dart line 108-115
const _FieldLabel('Phone number'),
const _PhoneField(),              // ← const, no controller!
const _FieldLabel('Password'),
const _DarkField(                 // ← const, no controller!
    hint: 'Enter your password',
```

The phone and password fields can't be read — `const` constructors without controller parameters. The data the user types is discarded.

---

## 🚨 SIGNUP HAS DEAD FIELDS

The signup collects phone, date of birth, and gender — but `_onSignUp()` only uses name, email, and username. The phone, DOB, and gender are collected by the UI and then **never sent to the backend**.

---

## OTHER BREAKING ISSUES

### 🛑 `Forgot Password?` Does Nothing
```dart
// login_screen.dart line 120
onTap: () {},  // ← empty callback
```

### 🛑 `Join as Guest` Does Nothing
```dart
// login_screen.dart line 172
onPressed: () {},  // ← empty callback
```

### 🛑 Google OAuth and Apple OAuth Buttons Are Decorative
Both login and signup screens show Google/Apple buttons, but neither has `onPressed` wired:
```dart
// signup_screen.dart
const _SocialButton(child: Image.asset('assets/google_icon.png', height: 24)),
const SizedBox(width: 16),
const _SocialButton(child: Image.asset('assets/apple_icon.png', height: 26)),
```
`_SocialButton` has no `onTap` parameter — it's just a styled container. No authentication is triggered.

### 🛑 OTP Screen Shows `player.png` as Decorative Background
Uses `assets/images/player.png` as a background image overlay on the OTP screen. This is a static asset with no relation to the user.

### 🛑 No Stripe Key in `.env`
The PaymentGateway and create-payment-intent Edge Function require `STRIPE_PUBLISHABLE_KEY` and `STRIPE_SECRET_KEY` respectively. Neither is configured.

### 🛑 `release_stale_locks` Cron Never Runs
The RPC exists in the SQL migration to release stale booking locks after 15 minutes, but there's no `pg_cron` setup or scheduled task to actually execute it.

### 🛑 `confirm_booking_payment` RPC Never Called
Even if payment worked, the booking flow never calls this RPC to transition the booking from `pending` to `confirmed`.

---

## WHAT ACTUALLY WORKS

Despite the auth and payment being broken, the following works if you skip auth:
- Displaying courts, coaches, moments from Supabase data (read-only queries work)
- The booking wizard UI flow (no actual booking happens)
- Google Maps explore screen (API key permitting)
- Notifications list, settings, language switching (UI only)
- Deep link service structure (untested)
- Image upload service structure (untested — needs Storage bucket)
- Profile display UI (reads from auth state, which is broken)
- Backend SQL schema is solid with proper RLS, locking, triggers (needs migration 00007 deployed)