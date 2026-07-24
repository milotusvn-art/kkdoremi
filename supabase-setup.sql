create table if not exists public.kkdoremi_allowed_users (
  email text primary key,
  approved boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.kkdoremi_daily_work (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.kkdoremi_allowed_users enable row level security;
alter table public.kkdoremi_daily_work enable row level security;

drop policy if exists "Approved users can confirm their approval" on public.kkdoremi_allowed_users;
drop policy if exists "Users can read their own daily work" on public.kkdoremi_daily_work;
drop policy if exists "Users can insert their own daily work" on public.kkdoremi_daily_work;
drop policy if exists "Users can update their own daily work" on public.kkdoremi_daily_work;
drop policy if exists "Allow public read kkdoremi daily work" on public.kkdoremi_daily_work;
drop policy if exists "Allow public insert kkdoremi daily work" on public.kkdoremi_daily_work;
drop policy if exists "Allow public update kkdoremi daily work" on public.kkdoremi_daily_work;

create policy "Approved users can confirm their approval"
on public.kkdoremi_allowed_users
for select
to authenticated
using (
  approved = true
  and lower(email) = lower(auth.jwt() ->> 'email')
);

create policy "Users can read their own daily work"
on public.kkdoremi_daily_work
for select
to authenticated
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.kkdoremi_allowed_users allowed
    where allowed.approved = true
      and lower(allowed.email) = lower(auth.jwt() ->> 'email')
  )
);

create policy "Users can insert their own daily work"
on public.kkdoremi_daily_work
for insert
to authenticated
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.kkdoremi_allowed_users allowed
    where allowed.approved = true
      and lower(allowed.email) = lower(auth.jwt() ->> 'email')
  )
);

create policy "Users can update their own daily work"
on public.kkdoremi_daily_work
for update
to authenticated
using (
  auth.uid() = user_id
  and exists (
    select 1
    from public.kkdoremi_allowed_users allowed
    where allowed.approved = true
      and lower(allowed.email) = lower(auth.jwt() ->> 'email')
  )
)
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.kkdoremi_allowed_users allowed
    where allowed.approved = true
      and lower(allowed.email) = lower(auth.jwt() ->> 'email')
  )
);

-- Replace this sample with each approved email, then run it once for each user.
-- insert into public.kkdoremi_allowed_users (email, approved)
-- values ('user@example.com', true)
-- on conflict (email) do update set approved = excluded.approved;
