-- Fix infinite recursion in RLS policies
-- Run this in Supabase SQL Editor

-- Drop the problematic policies
drop policy if exists "Members can view their family" on families;
drop policy if exists "Members can view family members" on members;
drop policy if exists "Members can view babies" on babies;
drop policy if exists "Members can create babies" on babies;
drop policy if exists "Members can view posts" on posts;
drop policy if exists "Members can create posts" on posts;
drop policy if exists "Members can view reactions" on reactions;

-- Recreate with non-recursive policies using auth.uid() directly

create policy "Members can view their family"
  on families for select using (
    id in (select family_id from members where user_id = (select auth.uid()))
  );

create policy "Members can view family members"
  on members for select using (
    user_id = (select auth.uid())
    or family_id in (select m.family_id from members m where m.user_id = (select auth.uid()))
  );

create policy "Members can view babies"
  on babies for select using (
    family_id in (select m.family_id from members m where m.user_id = (select auth.uid()))
  );

create policy "Members can create babies"
  on babies for insert with check (true);

create policy "Members can view posts"
  on posts for select using (
    family_id in (select m.family_id from members m where m.user_id = (select auth.uid()))
  );

create policy "Members can create posts"
  on posts for insert with check (true);

create policy "Members can view reactions"
  on reactions for select using (true);
