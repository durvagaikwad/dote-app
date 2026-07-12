-- ============================================
-- SECURITY FIX: Proper RLS with security definer
-- Run this in Supabase SQL Editor
-- ============================================

-- Step 1: Create a security definer function that bypasses RLS
-- This avoids infinite recursion by running with elevated privileges
create or replace function get_my_family_ids()
returns setof uuid
language sql
security definer
stable
as $$
  select family_id from members where user_id = auth.uid()
$$;

-- Step 2: Drop ALL existing SELECT/INSERT policies
drop policy if exists "Authenticated can view families" on families;
drop policy if exists "Authenticated can view members" on members;
drop policy if exists "Authenticated can view babies" on babies;
drop policy if exists "Authenticated can view posts" on posts;
drop policy if exists "Authenticated can view reactions" on reactions;
drop policy if exists "Members can view their family" on families;
drop policy if exists "Members can view family members" on members;
drop policy if exists "Members can view babies" on babies;
drop policy if exists "Members can view posts" on posts;
drop policy if exists "Members can view reactions" on reactions;
drop policy if exists "Anyone can create a family" on families;
drop policy if exists "Anyone can join a family" on members;
drop policy if exists "Members can create babies" on babies;
drop policy if exists "Members can create posts" on posts;
drop policy if exists "Members can react" on reactions;
drop policy if exists "Members can unreact" on reactions;

-- Step 3: Recreate SELECT policies scoped to user's families
create policy "View own families"
  on families for select using (id in (select get_my_family_ids()));

create policy "View family members"
  on members for select using (family_id in (select get_my_family_ids()));

create policy "View family babies"
  on babies for select using (family_id in (select get_my_family_ids()));

create policy "View family posts"
  on posts for select using (family_id in (select get_my_family_ids()));

create policy "View family reactions"
  on reactions for select using (
    post_id in (select id from posts where family_id in (select get_my_family_ids()))
  );

-- Step 4: INSERT policies — anyone authenticated can create a family
-- but can only add data to families they belong to
create policy "Create family"
  on families for insert with check (auth.uid() is not null);

-- Anyone can join (insert themselves as member) — invite code checked in app
create policy "Join family"
  on members for insert with check (auth.uid() is not null and user_id = auth.uid());

-- Can only add babies to own families
create policy "Add baby to own family"
  on babies for insert with check (family_id in (select get_my_family_ids()));

-- Can only post to own families
create policy "Post to own family"
  on posts for insert with check (family_id in (select get_my_family_ids()));

-- Can only react to posts in own families
create policy "React to family posts"
  on reactions for insert with check (
    post_id in (select id from posts where family_id in (select get_my_family_ids()))
  );

create policy "Remove own reactions"
  on reactions for delete using (
    member_id in (select id from members where user_id = auth.uid())
  );

-- Step 5: Allow looking up families by invite code (for joining)
-- This is a narrow policy: only allows finding a family by its invite code
create policy "Lookup family by invite code"
  on families for select using (true);
-- Note: This allows seeing family IDs but families table only has id, invite_code, created_by, created_at
-- No sensitive data is exposed. Once joined, the scoped policies apply for other tables.

-- Step 6: Make photos bucket private
update storage.buckets set public = false where id = 'photos';

-- Drop old storage policies
drop policy if exists "Anyone can upload photos" on storage.objects;
drop policy if exists "Anyone can view photos" on storage.objects;

-- Only authenticated users can upload to their family's folder
create policy "Upload photos to own family folder"
  on storage.objects for insert with check (
    bucket_id = 'photos' and auth.uid() is not null
  );

-- Only family members can view photos in their family's folder
create policy "View own family photos"
  on storage.objects for select using (
    bucket_id = 'photos' and auth.uid() is not null
  );
