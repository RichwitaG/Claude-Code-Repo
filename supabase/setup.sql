-- ============================================================
-- SWIPEVAULT — STANDARD Supabase backend setup (reusable template)
-- Run on a NEW project: Supabase → SQL Editor → New query → paste → Run.
-- Safe to run more than once.
--
-- Step 2 (GRANTS) is the piece that, when missing, causes the
-- "permission denied for table swipes" error on a fresh project.
-- It is now part of the standard so that never happens again.
-- ============================================================

-- 1) TABLE (directory + submission queue, image_url built in)
create table if not exists public.swipes (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  brand       text not null,
  asset_type  text not null,
  category    text not null,
  hue         int  not null default 200,
  note        text not null,
  why         text,
  hook        text,
  steal       text,
  link        text,
  submitter   text,
  image_url   text,
  status      text not null default 'pending'
);

-- 2) GRANTS — let the API roles use the table (RLS still controls WHICH rows).
--    *** Do not skip this. Missing grants = "permission denied for table". ***
grant usage on schema public to anon, authenticated;
grant select, insert on public.swipes to anon, authenticated;

-- 3) ROW-LEVEL SECURITY — which rows each role may see / add
alter table public.swipes enable row level security;

drop policy if exists "public reads approved" on public.swipes;
create policy "public reads approved"
  on public.swipes for select to anon, authenticated
  using (status = 'approved');

drop policy if exists "anyone can submit as pending" on public.swipes;
create policy "anyone can submit as pending"
  on public.swipes for insert to anon, authenticated
  with check (status = 'pending');

-- 4) IMAGE STORAGE — public bucket + upload permission
insert into storage.buckets (id, name, public)
values ('swipe-images', 'swipe-images', true)
on conflict (id) do nothing;

drop policy if exists "anyone can upload swipe images" on storage.objects;
create policy "anyone can upload swipe images"
  on storage.objects for insert to anon, authenticated
  with check (bucket_id = 'swipe-images');

-- 5) (optional) Seed sample data — run supabase/seed.sql separately if you want
--    the starter swipes. A brand-new live project usually starts empty.
