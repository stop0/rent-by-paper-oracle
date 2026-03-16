-- Supabase schema for Rent by Paper Oracle
-- Safe to run in Supabase SQL editor

-- ENUMS
create type public.user_role as enum ('owner', 'manager');
create type public.lease_status as enum ('draft', 'active', 'ended', 'cancelled');
create type public.payment_status as enum ('pending', 'processing', 'succeeded', 'failed');

-- ORGANIZATIONS
create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  country_code text,
  currency_code text default 'USD',
  created_at timestamptz not null default now()
);

-- PROFILES (SUPABASE AUTH USERS METADATA)
create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  organization_id uuid not null references public.organizations (id) on delete restrict,
  role public.user_role not null,
  display_name text,
  created_at timestamptz not null default now(),
  unique (user_id)
);

-- PROPERTIES
create table public.properties (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  name text not null,
  address_line1 text not null,
  address_line2 text,
  city text,
  state_region text,
  postal_code text,
  country_code text,
  created_at timestamptz not null default now()
);

-- MANAGER ASSIGNMENTS (WHICH MANAGER CAN SEE WHICH PROPERTY)
create table public.property_managers (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties (id) on delete cascade,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (property_id, profile_id)
);

-- UNITS
create table public.units (
  id uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties (id) on delete cascade,
  unit_number text not null,
  bedrooms int,
  bathrooms int,
  square_feet int,
  created_at timestamptz not null default now(),
  unique (property_id, unit_number)
);

-- TENANTS (NOT AUTH USERS IN MVP)
create table public.tenants (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  full_name text not null,
  email text,
  phone text,
  created_at timestamptz not null default now()
);

-- LEASES
create table public.leases (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  unit_id uuid not null references public.units (id) on delete restrict,
  start_date date not null,
  end_date date,
  rent_amount numeric(12, 2) not null,
  currency_code text not null default 'USD',
  rent_due_day int not null check (rent_due_day between 1 and 28),
  late_fee_flat numeric(12, 2),
  late_fee_percent numeric(5, 2),
  status public.lease_status not null default 'draft',
  created_at timestamptz not null default now()
);

-- LEASE TENANTS (MANY-TO-MANY)
create table public.lease_tenants (
  id uuid primary key default gen_random_uuid(),
  lease_id uuid not null references public.leases (id) on delete cascade,
  tenant_id uuid not null references public.tenants (id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (lease_id, tenant_id)
);

-- PAYMENTS
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  lease_id uuid not null references public.leases (id) on delete restrict,
  due_date date not null,
  amount_due numeric(12, 2) not null,
  amount_paid numeric(12, 2) not null default 0,
  currency_code text not null default 'USD',
  status public.payment_status not null default 'pending',
  stripe_payment_intent_id text,
  stripe_checkout_session_id text,
  last_error text,
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

-- INVITATIONS (FOR OWNERS/MANAGERS)
create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  email text not null,
  role public.user_role not null,
  token text not null unique,
  accepted_at timestamptz,
  created_at timestamptz not null default now()
);

