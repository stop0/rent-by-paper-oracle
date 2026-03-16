import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-zinc-50 text-zinc-950 dark:bg-black dark:text-zinc-50">
      <main className="mx-auto flex max-w-5xl flex-col gap-10 px-6 py-16">
        <header className="flex flex-col gap-4">
          <p className="text-sm font-medium text-zinc-600 dark:text-zinc-400">
            Rent by Paper Oracle
          </p>
          <h1 className="text-4xl font-semibold tracking-tight">
            Rental management for owners and managers.
          </h1>
          <p className="max-w-2xl text-lg leading-8 text-zinc-700 dark:text-zinc-300">
            Supabase-backed data + auth, role-based access via RLS, and Stripe-powered
            rent payments.
          </p>
        </header>

        <section className="grid gap-4 sm:grid-cols-2">
          <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-white/10 dark:bg-white/5">
            <h2 className="text-lg font-semibold">Sign in</h2>
            <p className="mt-2 text-sm text-zinc-600 dark:text-zinc-300">
              Connect your Supabase project and start using the app.
            </p>
            <div className="mt-4">
              <Link
                href="/auth"
                className="inline-flex items-center justify-center rounded-full bg-zinc-900 px-5 py-2 text-sm font-medium text-white hover:bg-zinc-800 dark:bg-white dark:text-black dark:hover:bg-zinc-200"
              >
                Go to Auth
              </Link>
            </div>
          </div>
          <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-white/10 dark:bg-white/5">
            <h2 className="text-lg font-semibold">Dashboards</h2>
            <p className="mt-2 text-sm text-zinc-600 dark:text-zinc-300">
              Owners see org-wide finances. Managers see assigned properties.
            </p>
            <div className="mt-4 flex gap-3">
              <Link
                href="/owner"
                className="inline-flex items-center justify-center rounded-full border border-zinc-300 bg-transparent px-5 py-2 text-sm font-medium hover:bg-zinc-100 dark:border-white/15 dark:hover:bg-white/10"
              >
                Owner
              </Link>
              <Link
                href="/manager"
                className="inline-flex items-center justify-center rounded-full border border-zinc-300 bg-transparent px-5 py-2 text-sm font-medium hover:bg-zinc-100 dark:border-white/15 dark:hover:bg-white/10"
              >
                Manager
              </Link>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
}
