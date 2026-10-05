-- Apply once to the existing shop database (after schema.sql on a fresh database).
-- A durable signal row covers additions, updates, final-item removal and checkout.
-- Clients fetch the authoritative cart from the existing /api/account endpoint.
begin;
create table public.cart_revisions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 1
);
alter table public.cart_revisions enable row level security;
create policy own_cart_revision on public.cart_revisions for select to authenticated
  using (user_id = auth.uid());
revoke all on public.cart_revisions from anon, authenticated;
grant select on public.cart_revisions to authenticated;
grant all on public.cart_revisions to service_role;

create function public.notify_cart_revision() returns trigger
language plpgsql security definer set search_path = '' as $$
declare customer_id uuid;
begin
  customer_id := case when TG_OP = 'DELETE' then OLD.user_id else NEW.user_id end;
  -- During account deletion the cascading cart delete must not recreate its FK.
  if exists (select 1 from auth.users where id = customer_id) then
    insert into public.cart_revisions (user_id, revision) values (customer_id, 1)
    on conflict (user_id) do update set revision = public.cart_revisions.revision + 1;
  end if;
  return null;
end;
$$;
revoke all on function public.notify_cart_revision() from public, anon, authenticated;
create trigger cart_changed after insert or update or delete on public.cart_items
for each row execute function public.notify_cart_revision();
insert into public.cart_revisions (user_id) select distinct user_id from public.cart_items;
alter publication supabase_realtime add table public.cart_revisions;
commit;
