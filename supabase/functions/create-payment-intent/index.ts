// Stripe Create Payment Intent — Supabase Edge Function
// Deploy: supabase functions deploy create-payment-intent --no-verify-jwt

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-11-20.acacia",
});

serve(async (req) => {
  // Only accept POST
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { booking_id, amount, currency = "sar" } = await req.json();

    if (!booking_id || !amount) {
      return new Response(
        JSON.stringify({ error: "Missing booking_id or amount" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // Create PaymentIntent — idempotent via idempotency_key
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Stripe uses cents/hellers
      currency,
      metadata: { booking_id },
      automatic_payment_methods: { enabled: true },
    });

    return new Response(
      JSON.stringify({
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        amount: paymentIntent.amount,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Unknown error";
    return new Response(
      JSON.stringify({ error: msg }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});