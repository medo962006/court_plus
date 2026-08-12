#!/usr/bin/env bash
# Build a release Flutter artifact with the real Supabase/Stripe/Sentry config
# embedded via --dart-define. AppConfig reads these from .env in debug but from
# compile-time --dart-define in release, so release builds MUST pass them here.
#
# Usage:
#   tool/build_release.sh            # flutter build apk --release
#   tool/build_release.sh appbundle  # flutter build appbundle --release
#   tool/build_release.sh web        # flutter build web --release
#
# Values are sourced from the local (gitignored) .env. Run from repo root.
set -euo pipefail

cd "$(dirname "$0")/.."
[ -f .env ] || { echo "error: .env not found — copy .env.example and fill in real values" >&2; exit 1; }

set -a
# shellcheck disable=SC1091
. ./.env
set +a

TARGET="apk --release"
[ $# -gt 0 ] && TARGET="$1 --release"

DEFINES=(
  "--dart-define=SUPABASE_URL=${SUPABASE_URL:-}"
  "--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}"
  "--dart-define=APP_ENV=${APP_ENV:-production}"
  "--dart-define=GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY:-}"
  "--dart-define=STRIPE_PUBLISHABLE_KEY=${STRIPE_PUBLISHABLE_KEY:-}"
  "--dart-define=SENTRY_DSN=${SENTRY_DSN:-}"
)

echo ">> flutter build $TARGET"
# shellcheck disable=SC2086
flutter build $TARGET "${DEFINES[@]}"
echo ">> done. Telemetry config embedded from .env."