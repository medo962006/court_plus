# Phase 4 completion checklist — run one-time after getting real Stripe keys

# 1. Set Stripe secrets in Supabase
supabase secrets set STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxxx
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxx

# 2. Verify Edge Functions are reachable
#    → https://fnyekgsajrrihefqyaiq.supabase.co/functions/v1/create-payment-intent
#    → https://fnyekgsajrrihefqyaiq.supabase.co/functions/v1/stripe-webhook

# 3. Configure Stripe webhook endpoint in Stripe Dashboard
#    URL: https://fnyekgsajrrihefqyaiq.supabase.co/functions/v1/stripe-webhook
#    Events: payment_intent.succeeded, payment_intent.payment_failed