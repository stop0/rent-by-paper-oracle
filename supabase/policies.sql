-- RLS policies for Rent by Paper Oracle
-- Enable RLS

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.properties enable row level security;
alter table public.property_managers enable row level security;
alter table public.units enable row level security;
alter table public.tenants enable row level security;
alter table public.leases enable row level security;
alter table public.lease_tenants enable row level security;
alter table public.payments enable row level security;
alter table public.invitations enable row level security;

-- Helper: get current user's profile
create or replace function public.current_profile()
returns public.profiles
language sql
stable
security definer
set search_path = public
as $$
  select p.*
  from public.profiles p
  where p.user_id = auth.uid()
  limit 1;
$$;

-- ORGANIZATIONS: owners and managers can see only their org
create policy "select own organization"
on public.organizations
for select
using (
  id = (select organization_id from public.current_profile())
);

-- PROFILES: only within same organization; owners can see all, managers cannot see owners' email/user_id (handled via app-level field selection)
create policy "select profiles in org"
on public.profiles
for select
using (
  organization_id = (select organization_id from public.current_profile())
);

-- Allow insert profile only for self on signup bootstrap
create policy "insert own profile"
on public.profiles
for insert
with check (user_id = auth.uid());

-- PROPERTIES: org-scoped
create policy "select properties in org"
on public.properties
for select
using (
  organization_id = (select organization_id from public.current_profile())
);

create policy "modify properties owners only"
on public.properties
for all
using (
  organization_id = (select organization_id from public.current_profile())
  and (select role from public.current_profile()) = 'owner'
)
with check (
  organization_id = (select organization_id from public.current_profile())
  and (select role from public.current_profile()) = 'owner'
);

-- PROPERTY MANAGERS: org-scoped
create policy "select property_managers in org"
on public.property_managers
for select
using (
  property_id in (
    select id from public.properties
    where organization_id = (select organization_id from public.current_profile())
  )
);

create policy "modify property_managers owners only"
on public.property_managers
for all
using (
  property_id in (
    select id from public.properties
    where organization_id = (select organization_id from public.current_profile())
  )
  and (select role from public.current_profile()) = 'owner'
)
with check (
  property_id in (
    select id from public.properties
    where organization_id = (select organization_id from public.current_profile())
  )
  and (select role from public.current_profile()) = 'owner'
);

-- UNITS: org-scoped
create policy "select units in org"
on public.units
for select
using (
  property_id in (
    select id from public.properties
    where organization_id = (select organization_id from public.current_profile())
  )
);

create policy "modify units owners or assigned managers"
on public.units
for all
using (
  property_id in (
    select pm.property_id
    from public.property_managers pm
    join public.profiles pr on pr.id = pm.profile_id
    where pr.user_id = auth.uid()
  )
  or (
    (select role from public.current_profile()) = 'owner'
    and property_id in (
      select id from public.properties
      where organization_id = (select organization_id from public.current_profile())
    )
  )
)
with check (
  property_id in (
    select pm.property_id
    from public.property_managers pm
    join public.profiles pr on pr.id = pm.profile_id
    where pr.user_id = auth.uid()
  )
  or (
    (select role from public.current_profile()) = 'owner'
    and property_id in (
      select id from public.properties
      where organization_id = (select organization_id from public.current_profile())
    )
  )
);

-- TENANTS: org-scoped, owners and managers can CRUD
create policy "select tenants in org"
on public.tenants
for select
using (
  organization_id = (select organization_id from public.current_profile())
);

create policy "modify tenants owners or managers"
on public.tenants
for all
using (
  organization_id = (select organization_id from public.current_profile())
)
with check (
  organization_id = (select organization_id from public.current_profile())
);

-- LEASES: org-scoped; managers limited to assigned properties via units
create policy "select leases in org or assigned"
on public.leases
for select
using (
  organization_id = (select organization_id from public.current_profile())
  and (
    (select role from public.current_profile()) = 'owner'
    or unit_id in (
      select u.id
      from public.units u
      join public.property_managers pm on pm.property_id = u.property_id
      join public.profiles pr on pr.id = pm.profile_id
      where pr.user_id = auth.uid()
    )
  )
);

create policy "modify leases owners or assigned managers"
on public.leases
for all
using (
  organization_id = (select organization_id from public.current_profile())
  and (
    (select role from public.current_profile()) = 'owner'
    or unit_id in (
      select u.id
      from public.units u
      join public.property_managers pm on pm.property_id = u.property_id
      join public.profiles pr on pr.id = pm.profile_id
      where pr.user_id = auth.uid()
    )
  )
)
with check (
  organization_id = (select organization_id from public.current_profile())
  and (
    (select role from public.current_profile()) = 'owner'
    or unit_id in (
      select u.id
      from public.units u
      join public.property_managers pm on pm.property_id = u.property_id
      join public.profiles pr on pr.id = pm.profile_id
      where pr.user_id = auth.uid()
    )
  )
);

-- LEASE TENANTS: follow leases policy
create policy "select lease_tenants by lease visibility"
on public.lease_tenants
for select
using (
  lease_id in (
    select id from public.leases
    where organization_id = (select organization_id from public.current_profile())
  )
);

create policy "modify lease_tenants by lease visibility"
on public.lease_tenants
for all
using (
  lease_id in (
    select id from public.leases
    where organization_id = (select organization_id from public.current_profile())
  )
)
with check (
  lease_id in (
    select id from public.leases
    where organization_id = (select organization_id from public.current_profile())
  )
);

-- PAYMENTS: org-scoped; both roles can read, owners and assigned managers can modify
create policy "select payments in org"
on public.payments
for select
using (
  organization_id = (select organization_id from public.current_profile())
);

create policy "modify payments owners or assigned managers"
on public.payments
for all
using (
  organization_id = (select organization_id from public.current_profile())
  and (
    (select role from public.current_profile()) = 'owner'
    or lease_id in (
      select l.id
      from public.leases l
      join public.units u on u.id = l.unit_id
      join public.property_managers pm on pm.property_id = u.property_id
      join public.profiles pr on pr.id = pm.profile_id
      where pr.user_id = auth.uid()
    )
  )
)
with check (
  organization_id = (select organization_id from public.current_profile())
  and (
    (select role from public.current_profile()) = 'owner'
    or lease_id in (
      select l.id
      from public.leases l
      join public.units u on u.id = l.unit_id
      join public.property_managers pm on pm.property_id = u.property_id
      join public.profiles pr on pr.id = pm.profile_id
      where pr.user_id = auth.uid()
    )
  )
);

-- INVITATIONS: org-scoped; owners manage
create policy "select invitations owners"
on public.invitations
for select
using (
  organization_id = (select organization_id from public.current_profile())
  and (select role from public.current_profile()) = 'owner'
);

create policy "modify invitations owners"
on public.invitations
for all
using (
  organization_id = (select organization_id from public.current_profile())
  and (select role from public.current_profile()) = 'owner'
)
with check (
  organization_id = (select organization_id from public.current_profile())
  and (select role from public.current_profile()) = 'owner'
);

