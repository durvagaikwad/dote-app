-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor > New query)

-- Families
create table families (
  id uuid primary key default gen_random_uuid(),
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
  hearts int default 0,
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

-- Enable Row Level Security
alter table families enable row level security;
alter table members enable row level security;
alter table babies enable row level security;
alter table posts enable row level security;
alter table reactions enable row level security;

-- RLS Policies: members can read their family's data
create policy "Members can view their family"
  on families for select using (
    id in (select family_id from members where user_id = auth.uid())
  );

create policy "Anyone can create a family"
  on families for insert with check (true);

create policy "Members can view family members"
  on members for select using (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Anyone can join a family"
  on members for insert with check (true);

create policy "Members can view babies"
  on babies for select using (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Members can create babies"
  on babies for insert with check (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Members can view posts"
  on posts for select using (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Members can create posts"
  on posts for insert with check (
    family_id in (select family_id from members where user_id = auth.uid())
  );

create policy "Members can view reactions"
  on reactions for select using (
    post_id in (select id from posts where family_id in (select family_id from members where user_id = auth.uid()))
  );

create policy "Members can react"
  on reactions for insert with check (true);

create policy "Members can unreact"
  on reactions for delete using (member_id in (select id from members where user_id = auth.uid()));

-- Storage bucket for photos
insert into storage.buckets (id, name, public) values ('photos', 'photos', true);

create policy "Anyone can upload photos"
  on storage.objects for insert with check (bucket_id = 'photos');

create policy "Anyone can view photos"
  on storage.objects for select using (bucket_id = 'photos');
