# court+ Release Build Guide

## Prerequisites

1. **Supabase project** configured with tables: profiles, courts, bookings, matches, reviews, payments, notifications, moments
2. **Google Maps API key** (for Explore screen)
3. **Android signing key** (generate once, keep forever)

## Step 1: Generate Signing Key (one time)

```bash
cd android/app
keytool -genkey -v -keystore court-plus-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias court-plus-key -storetype JKS
# Enter passwords and info when prompted
```

## Step 2: Configure Signing

```bash
# Copy the template and fill in your passwords
cp android/key.properties.template android/key.properties
# Edit android/key.properties with your store/key passwords
```

## Step 3: Set Environment Variables

```bash
# For development (uses .env file)
cp .env.example.release .env
# Edit .env with your Supabase URL and anon key

# For release builds, pass via --dart-define:
# flutter build appbundle --dart-define=SUPABASE_URL=https://xx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## Step 4: Build

### Android App Bundle (Play Store)
```bash
flutter build appbundle \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Android APK (direct install)
```bash
flutter build apk --split-per-abi \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```
Output: `build/app/outputs/flutter-apk/app-{armeabi-v7a,arm64-v8a,x86_64}-release.apk`

### iOS (macOS only)
```bash
flutter build ipa \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```
Output: `build/ios/ipa/court_plus.ipa`

## Step 5: Post-Build Verification

- [ ] App launches without crash
- [ ] Auth flow works (signup/login/OTP)
- [ ] Courts list loads from Supabase
- [ ] Booking flow completes end-to-end
- [ ] Payment processes successfully
- [ ] Match creation and invitation works
- [ ] Review submission persists
- [ ] Settings: language toggle, notifications, logout
- [ ] Google Maps renders on Explore screen

## Architecture Summary

```
lib/
├── core/                    # Infrastructure
│   ├── result.dart          # Result<T> monad for error handling
│   ├── logger.dart          # AppLogger (structured logging)
│   ├── config.dart          # AppConfig (env-aware)
│   ├── validators.dart      # Form validators
│   └── widgets/
│       └── async_widget.dart # Loading/error/data widget
├── services/
│   ├── supabase_service.dart # Supabase client (singleton)
│   └── models.dart           # Data models (UserProfile, Court, Booking, Match, Review)
├── presentation/
│   └── providers/
│       ├── supabase_provider.dart  # DI provider
│       ├── auth_provider.dart      # Auth state machine
│       ├── courts_provider.dart    # Courts list
│       ├── booking_provider.dart   # Booking flow
│       ├── match_provider.dart     # Match creation
│       ├── review_provider.dart    # Review submission
│       └── settings_provider.dart  # Language + notifications
├── screens/                 # UI screens (all wired to providers)
├── presentation/screens/    # Newer screens (activity, match)
├── theme/                   # AppColors + AppTheme
└── widgets/                 # Shared widgets
```

## Key Commands

```bash
# Development
flutter run                          # Run on connected device
flutter run --release                # Run release mode

# Analysis
flutter analyze                      # Check for issues
dart format lib/                     # Format all Dart code

# Testing
flutter test                         # Run unit/widget tests
flutter test --coverage              # With coverage

# Clean
flutter clean                        # Clean build artifacts
flutter pub cache repair             # Fix dependency issues