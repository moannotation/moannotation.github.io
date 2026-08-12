-- =====================================================================
-- MO AI — contributor accounts table
-- Run this once in Supabase → SQL Editor → New query → Run
-- =====================================================================

create table if not exists contributors (
  id          uuid primary key references auth.users on delete cascade,
  name        text,
  email       text,
  city        text,
  skill       text,
  device      text,
  hours       text,
  experience  text,
  stage       text default 'Applied',
  notes       text,
  created_at  timestamptz default now()
);

-- Row Level Security: each contributor can only ever see their own record.
alter table contributors enable row level security;

drop policy if exists "own row read"   on contributors;
drop policy if exists "own row insert" on contributors;
drop policy if exists "own row update" on contributors;

create policy "own row read"
  on contributors for select
  using (auth.uid() = id);

create policy "own row insert"
  on contributors for insert
  with check (auth.uid() = id);

create policy "own row update"
  on contributors for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Note: you (as project owner) can still see and edit every row from the
-- Supabase Table Editor. RLS only restricts what the website can read.
--
-- To move someone along the pipeline, open Table Editor → contributors
-- and change their `stage` to one of:
--   Applied · Screened · Verified · Assessed · Signed · Active
-- They see the new stage next time they sign in.
