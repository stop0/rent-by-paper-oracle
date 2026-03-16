import { NextResponse } from "next/server";
import { z } from "zod";
import { getStripe } from "@/lib/stripe/stripe";

const BodySchema = z.object({
  paymentId: z.string().uuid(),
  amountCents: z.number().int().positive(),
  currency: z.string().min(3).max(3).default("USD"),
});

export async function POST(req: Request) {
  const body = BodySchema.parse(await req.json());

  const appUrl = process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000";
  const stripe = getStripe();

  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    line_items: [
      {
        quantity: 1,
        price_data: {
          currency: body.currency.toLowerCase(),
          unit_amount: body.amountCents,
          product_data: { name: "Rent payment" },
        },
      },
    ],
    metadata: {
      payment_id: body.paymentId,
    },
    success_url: `${appUrl}/payments/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${appUrl}/payments/cancel?payment_id=${body.paymentId}`,
  });

  return NextResponse.json({ checkoutUrl: session.url });
}

