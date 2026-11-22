# SWIPEVAULT — Backend standard (Supabase)

This folder holds the **repeatable** backend setup so we never re-debug the same
issues. Follow this order whenever standing up a new Supabase project.

## New-project checklist
1. Create the project (free tier is fine to start). Save the DB password.
2. **SQL Editor → run `setup.sql`** — creates the table, **grants**, RLS policies,
   and the image storage bucket.
   - The **GRANTS** step is non-negotiable. Without it the site throws
     `permission denied for table swipes`, even though the data is there.
3. *(optional)* Run `seed.sql` to load the 18 sample swipes.
4. **Settings → API** → copy the **Project URL** and the **publishable/anon key**
   into `index.html` (`SUPABASE_URL` / `SUPABASE_KEY`).

## Two gatekeepers (why "permission denied" vs "empty" differ)
- **GRANTS** decide whether a role may touch the table *at all*. Missing grant =
  hard error `permission denied for table`.
- **RLS policies** decide *which rows* a role sees. A missing/!matching policy =
  empty result, not an error.
`setup.sql` configures both.

## Keep-alive (free tier anti-pause)
Free Supabase projects **auto-pause after ~7 days idle**, and a stuck restore can
take the site down (it happened twice). `.github/workflows/supabase-keepalive.yml`
pings the REST API daily so the project never idles out.

- **It only runs if it lives on the repo's DEFAULT branch (`main`).** A workflow on
  a feature branch will not fire on schedule.
- GitHub disables scheduled workflows after ~60 days with no repo commits — not a
  concern on an active project, but worth knowing.
- Uses the public anon key (safe to commit; RLS protects the data).

## When this goes to real users
A keep-alive is a free stopgap. For a production audience, move to **Supabase Pro
($25/mo)** — no auto-pausing and no stuck restores.
