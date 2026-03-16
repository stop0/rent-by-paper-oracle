import { headers } from "next/headers";
import Stripe from "stripe";
import { getStripe } from "@/lib/stripe/stripe";

export const runtime = "nodejs";

export async function POST(req: Request) {
  const stripe = getStripe();
  const signature = (await headers()).get("stripe-signature");
  const secret = process.env.STRIPE_WEBHOOK_SECRET;

  if (!signature || !secret) {
    return new Response("Missing webhook signature/secret", { status: 400 });
  }

  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, secret);
  } catch {
    return new Response("Invalid signature", { status: 400 });
  }

  // TODO: update Supabase `payments` row by metadata.payment_id + event type.
  // We intentionally keep it minimal until Supabase service-role is wired in.
  switch (event.type) {
    case "checkout.session.completed":
    case "payment_intent.succeeded":
    case "payment_intent.payment_failed":
      break;
    default:
      break;
  }

  return new Response("ok", { status: 200 });
}

