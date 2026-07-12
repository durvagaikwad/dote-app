-- ============================================================
-- FIX: "Baby insert error" — 42P17 infinite recursion in the
-- members RLS policy.
--
-- Why it happens: policies from supabase-schema.sql, fix-rls.sql
-- and fix-security.sql are mixed together in the live DB. The
-- surviving members SELECT policy references the members table
-- inside its own USING clause, so any policy that subqueries
-- members (like the babies INSERT check) recurses forever.
--
-- This script is idempotent: it drops EVERY policy on the five
-- app tables regardless of which script created it, then
-- rebuilds one coherent, non-recursive set.
--
-- Run in: Supabase Dashboard > SQL Editor > New query > Run
-- ============================================================

-- 1. Security definer helper — bypasses RLS, so policies that
--    need "which families am I in?" never re-enter members' RLS.
create or replace function get_my_family_ids()
returns setof uuid
language sql
security definer
stable
set search_path = public
as $$
  select family_id from members where user_id = auth.uid()
$$;

grant execute on function get_my_family_ids() to authenticated, anon;

-- 2. Drop ALL existing policies on the app tables (any generation).
do $$
declare r record;
begin
  for r in
    select policyname, tablename from pg_policies
    where schemaname = 'public'
      and tablename in ('families','members','babies','posts','reactions')
  loop
    execute format('drop policy %I on public.%I', r.policyname, r.tablename);
  end loop;
end $$;

-- 3. Rebuild — SELECT policies scoped via the helper function.

-- Families: any signed-in user may look up a family row (needed to
-- resolve invite codes; the table holds no sensitive data).
create policy "families_select" on families
  for select using (auth.uid() is not null);

create policy "families_insert" on families
  for insert with check (auth.uid() is not null and created_by = auth.uid());

-- Members
create policy "members_select" on members
  for select using (
    user_id = auth.uid()
    or family_id in (select get_my_family_ids())
  );

create policy "members_insert" on members
  for insert with check (auth.uid() is not null and user_id = auth.uid());

create policy "members_update_own" on members
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Babies
create policy "babies_select" on babies
  for select using (family_id in (select get_my_family_ids()));

create policy "babies_insert" on babies
  for insert with check (family_id in (select get_my_family_ids()));

create policy "babies_update" on babies
  for update using (family_id in (select get_my_family_ids()))
  with check (family_id in (select get_my_family_ids()));

-- Posts
create policy "posts_select" on posts
  for select using (family_id in (select get_my_family_ids()));

create policy "posts_insert" on posts
  for insert with check (family_id in (select get_my_family_ids()));

-- Reactions
create policy "reactions_select" on reactions
  for select using (
    post_id in (select id from posts where family_id in (select get_my_family_ids()))
  );

create policy "reactions_insert" on reactions
  for insert with check (
    member_id in (select id from members where user_id = auth.uid())
    and post_id in (select id from posts where family_id in (select get_my_family_ids()))
  );

create policy "reactions_delete" on reactions
  for delete using (
    member_id in (select id from members where user_id = auth.uid())
  );

-- 4. Sanity check — should list exactly the policies created above.
select tablename, policyname, cmd from pg_policies
where schemaname = 'public'
  and tablename in ('families','members','babies','posts','reactions')
order by tablename, policyname;
