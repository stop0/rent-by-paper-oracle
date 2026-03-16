import { createSupabaseServerClient } from "@/lib/supabase/server";

export default async function AuthPage() {
  const supabase = createSupabaseServerClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <div className="min-h-screen bg-zinc-50 text-zinc-950 dark:bg-black dark:text-zinc-50">
      <main className="mx-auto flex max-w-xl flex-col gap-6 px-6 py-16">
        <h1 className="text-2xl font-semibold tracking-tight">Auth</h1>

        <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-white/10 dark:bg-white/5">
          {user ? (
            <div className="space-y-3">
              <p className="text-sm text-zinc-600 dark:text-zinc-300">
                Signed in as <span className="font-medium">{user.email}</span>
              </p>
              <form action="/auth/signout" method="post">
                <button
                  type="submit"
                  className="inline-flex items-center justify-center rounded-full bg-zinc-900 px-5 py-2 text-sm font-medium text-white hover:bg-zinc-800 dark:bg-white dark:text-black dark:hover:bg-zinc-200"
                >
                  Sign out
                </button>
              </form>
            </div>
          ) : (
            <div className="space-y-3">
              <p className="text-sm text-zinc-600 dark:text-zinc-300">
                This is a placeholder. Next step is adding email/password and magic-link
                forms using Supabase Auth.
              </p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

