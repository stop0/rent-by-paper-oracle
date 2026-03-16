import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export default async function OwnerDashboard() {
  const supabase = createSupabaseServerClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <div className="min-h-screen bg-zinc-50 text-zinc-950 dark:bg-black dark:text-zinc-50">
      <main className="mx-auto flex max-w-5xl flex-col gap-6 px-6 py-16">
        <header className="flex items-start justify-between gap-4">
          <div>
            <p className="text-sm text-zinc-600 dark:text-zinc-400">Owner</p>
            <h1 className="text-3xl font-semibold tracking-tight">
              Organization dashboard
            </h1>
          </div>
          <Link
            href="/"
            className="text-sm font-medium text-zinc-700 hover:text-zinc-950 dark:text-zinc-300 dark:hover:text-white"
          >
            Home
          </Link>
        </header>

        <section className="grid gap-4 sm:grid-cols-3">
          {[
            { label: "Properties", value: "—" },
            { label: "Units", value: "—" },
            { label: "Outstanding", value: "—" },
          ].map((kpi) => (
            <div
              key={kpi.label}
              className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-white/10 dark:bg-white/5"
            >
              <p className="text-sm text-zinc-600 dark:text-zinc-400">{kpi.label}</p>
              <p className="mt-2 text-2xl font-semibold">{kpi.value}</p>
            </div>
          ))}
        </section>

        <section className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-white/10 dark:bg-white/5">
          <h2 className="text-lg font-semibold">Session</h2>
          <p className="mt-2 text-sm text-zinc-600 dark:text-zinc-300">
            {user ? `Signed in as ${user.email}` : "Not signed in"}
          </p>
          <p className="mt-3 text-sm text-zinc-600 dark:text-zinc-300">
            Next: load KPIs and lists from Supabase tables with RLS enforcement.
          </p>
        </section>
      </main>
    </div>
  );
}

