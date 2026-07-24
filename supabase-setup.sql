create table if not exists public.kkdoremi_daily_work (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.kkdoremi_daily_work enable row level security;

drop policy if exists "Users can read their own daily work" on public.kkdoremi_daily_work;
drop policy if exists "Users can insert their own daily work" on public.kkdoremi_daily_work;
drop policy if exists "Users can update their own daily work" on public.kkdoremi_daily_work;
drop policy if exists "Allow public read kkdoremi daily work" on public.kkdoremi_daily_work;
drop policy if exists "Allow public insert kkdoremi daily work" on public.kkdoremi_daily_work;
drop policy if exists "Allow public update kkdoremi daily work" on public.kkdoremi_daily_work;

create policy "Users can read their own daily work"
on public.kkdoremi_daily_work
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own daily work"
on public.kkdoremi_daily_work
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own daily work"
on public.kkdoremi_daily_work
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
