-- OpenWave TV: Global Favourites - run in Supabase SQL Editor
-- Create your admin user in Authentication > Users before granting admin below.
create table if not exists public.openwave_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.openwave_global_channels (
  id uuid primary key default gen_random_uuid(),
  channel_key text not null unique,
  name text not null check (char_length(name) between 1 and 200),
  stream_url text not null check (stream_url ~* '^https?://'),
  stream_urls jsonb not null default '[]'::jsonb check (jsonb_typeof(stream_urls) = 'array'),
  logo text not null default '',
  category text not null default 'Global',
  country text not null default '',
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
create index if not exists openwave_global_channels_created_at_idx
  on public.openwave_global_channels (created_at desc);
alter table public.openwave_admins enable row level security;
alter table public.openwave_global_channels enable row level security;
revoke all on public.openwave_admins from anon, authenticated;
revoke all on public.openwave_global_channels from anon, authenticated;
grant select on public.openwave_admins to authenticated;
grant select on public.openwave_global_channels to anon, authenticated;
grant insert, update, delete on public.openwave_global_channels to authenticated;

drop policy if exists "admins read their own membership" on public.openwave_admins;
create policy "admins read their own membership" on public.openwave_admins
for select to authenticated using (user_id = (select auth.uid()));

drop policy if exists "global channels are public" on public.openwave_global_channels;
create policy "global channels are public" on public.openwave_global_channels
for select to anon, authenticated using (true);

drop policy if exists "only admins can publish" on public.openwave_global_channels;
create policy "only admins can publish" on public.openwave_global_channels
for insert to authenticated with check (
  created_by = (select auth.uid())
  and exists (select 1 from public.openwave_admins a where a.user_id = (select auth.uid()))
);
drop policy if exists "only admins can edit" on public.openwave_global_channels;
create policy "only admins can edit" on public.openwave_global_channels
for update to authenticated using (
  exists (select 1 from public.openwave_admins a where a.user_id = (select auth.uid()))
) with check (
  exists (select 1 from public.openwave_admins a where a.user_id = (select auth.uid()))
);
drop policy if exists "only admins can remove" on public.openwave_global_channels;
create policy "only admins can remove" on public.openwave_global_channels
for delete to authenticated using (
  exists (select 1 from public.openwave_admins a where a.user_id = (select auth.uid()))
);

-- After creating your account, run this separately with the real Auth user UUID:
-- insert into public.openwave_admins(user_id) values ('YOUR_AUTH_USER_UUID');
