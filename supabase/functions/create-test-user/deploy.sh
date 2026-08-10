#!/usr/bin/env bash
# Deploy the create-test-user Edge Function to Supabase.
# Run from the project root: bash supabase/functions/create-test-user/deploy.sh
set -euo pipefail

cd "$(dirname "$0")/../../.."

echo "=== Deploying create-test-user Edge Function ==="
echo ""

# Check if supabase CLI is available
if ! command -v supabase &>/dev/null; then
  echo "ERROR: Supabase CLI not found."
  echo "Install it: npm install -g supabase"
  echo "Or: brew install supabase/tap/supabase"
  exit 1
fi

# Check if user is logged in
if ! supabase projects list &>/dev/null; then
  echo "Logging in to Supabase..."
  supabase login
fi

echo "Deploying function..."
supabase functions deploy create-test-user --project-ref "$(supabase status --output json 2>/dev/null | grep -o '"project_id":"[^"]*"' | cut -d'"' -f4 || echo '')"

echo ""
echo "=== Done ==="
echo "The test user can now be created by tapping 'Quick Test Login' in the app."
echo "No email OTP required — the function uses service_role + email_confirm=true."