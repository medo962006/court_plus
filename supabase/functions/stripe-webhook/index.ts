// Stripe Webhook Handler — Supabase Edge Function
// Deploy: supabase functions deploy stripe-webhook --no-verify-jwt

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-11-20.acacia",
});

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response("Missing stripe-signature header", { status: 400 });
  }

  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      Deno.env.get("STRIPE_WEBHOOK_SECRET")!,
    );
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Signature verification failed";
    return new Response(msg, { status: 400 });
  }

  switch (event.type) {
    case "payment_intent.succeeded": {
      const pi = event.data.object as Stripe.PaymentIntent;
      const bookingId = pi.metadata.booking_id;
      if (!bookingId) break;

      const { error } = await supabase.rpc("confirm_booking_payment", {
        p_booking_id: bookingId,
        p_payment_intent_id: pi.id,
        p_amount: (pi.amount_received ?? pi.amount) / 100,
      });
      if (error) {
        console.error("confirm_booking_payment failed:", error);
        return new Response(error.message, { status: 500 });
      }
      break;
    }

    case "payment_intent.payment_failed": {
      const pi = event.data.object as Stripe.PaymentIntent;
      const bookingId = pi.metadata.booking_id;
      if (!bookingId) break;

      const { error } = await supabase.rpc("release_slot_lock", {
        p_booking_id: bookingId,
      });
      if (error) {
        console.error("release_slot_lock failed:", error);
      }
      break;
    }
  }

  return new Response("OK", { status: 200 });
});