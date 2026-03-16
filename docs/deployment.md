## Deployment (Vercel + Supabase) for Rent by Paper Oracle

### Supabase setup

1. Create a Supabase project.
2. In the Supabase SQL editor, run:
   - `supabase/schema.sql`
   - `supabase/policies.sql`
3. Enable Supabase Auth providers (email/password or magic links).
4. Capture environment values:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY` (server-only)

### Stripe setup

1. Create a Stripe account and get:
   - `STRIPE_SECRET_KEY`
2. Create a webhook endpoint pointing to:
   - `/api/stripe/webhook`
3. Copy the signing secret:
   - `STRIPE_WEBHOOK_SECRET`

### Local development

1. Copy env file:
   - from `web/.env.example` to `web/.env.local`
2. Install dependencies:
   - `cd web`
   - `npm install`
3. Start dev server:
   - `npm run dev`

### Vercel setup

1. Create a new Vercel project from the GitHub repo.
2. Set **Root Directory** to `web`.
3. Add Environment Variables (Preview + Production):
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `STRIPE_SECRET_KEY`
   - `STRIPE_WEBHOOK_SECRET`
   - `NEXT_PUBLIC_APP_URL` (set to your Vercel deployment URL)
4. Deploy.

