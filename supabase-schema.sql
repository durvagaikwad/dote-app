-- Dote — Supabase schema
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor > New query)

-- Families
create table families (
  id uuid primary key default gen_random_uuid(),
  name text,
  invite_code text unique not null,
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);

-- Members of a family
create table members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references families(id) on delete cascade,
  user_id uuid references auth.users(id),
  name text not null,
  role text not null default 'family',
  created_at timestamptz default now()
);

-- Babies
create table babies (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references families(id) on delete cascade,
  name text not null default 'Baby',
  birthday date,
  photo_url text,
  created_at timestamptz default now()
);

-- Posts (photos and text)
create table posts (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references families(id) on delete cascade,
  baby_id uuid references babies(id) on delete cascade,
  author_id uuid references members(id),
  type text not null check (type in ('photo', 'text')),
  content text,
  photo_url text,
  created_at timestamptz default now()
);

-- Reactions
create table reactions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade,
  member_id uuid references members(id) on delete cascade,
  created_at timestamptz default now(),
  unique(post_id, member_id)
);

-- ═══════════════════════════════════════
-- Row Level Security
-- ═══════════════════════════════════════
alter table families enable row level security;
alter table members enable row level security;
alter table babies enable row level security;
alter table posts enable row level security;
alter table reactions enable row level security;

-- Families
create policy "Members can view their family"
  on families for select using (
    id in (select family_id from members where user_id = auth.uid())
  );

create policy "Authenticated users can create a family"
  on families for insert with check (
    auth.uid() is not null and created_by = auth.uid()
  );

-- Members
create policy "Members can view family members"
  on members for select using (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Authenticated users can join a family"
  on members for insert with check (
    auth.uid() is not null and user_id = auth.uid()
  );

create policy "Members can update their own name"
  on members for update using (
    user_id = auth.uid()
  ) with check (
    user_id = auth.uid()
  );

-- Babies
create policy "Members can view babies"
  on babies for select using (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Members can create babies"
  on babies for insert with check (
    family_id in (select family_id from members where user_id = auth.uid())
  );

-- Posts
create policy "Members can view posts"
  on posts for select using (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Members can create posts"
  on posts for insert with check (
    family_id in (select family_id from members where user_id = auth.uid())
  );

-- Reactions
create policy "Members can view reactions"
  on reactions for select using (
    post_id in (
      select id from posts where family_id in (
        select family_id from members where user_id = auth.uid()
      )
    )
  );

create policy "Members can react"
  on reactions for insert with check (
    member_id in (select id from members where user_id = auth.uid())
  );

create policy "Members can unreact"
  on reactions for delete using (
    member_id in (select id from members where user_id = auth.uid())
  );

-- ═══════════════════════════════════════
-- RPC: lookup family by invite code
-- ═══════════════════════════════════════
create or replace function lookup_family_by_invite(code text)
returns uuid
language sql
security definer
set search_path = public
as $$
  select id from families where invite_code = code limit 1;
$$;

-- ═══════════════════════════════════════
-- Storage
-- ═══════════════════════════════════════
insert into storage.buckets (id, name, public) values ('photos', 'photos', true);

create policy "Authenticated users can upload photos"
  on storage.objects for insert with check (
    bucket_id = 'photos' and auth.uid() is not null
  );

create policy "Anyone can view photos"
  on storage.objects for select using (bucket_id = 'photos');
