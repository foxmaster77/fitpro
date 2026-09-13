-- FITPRO — privacy-first schema for Supabase (Postgres)
-- Health fields are ciphertext. The device holds the AES key.
-- Enable pgcrypto if you later add envelope encryption with a user wrapping key.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  onboarding_complete boolean not null default false,
  accepted_privacy_at timestamptz,
  zero_data_selling_ack boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  tier text not null default 'core' check (tier in ('core', 'ai_pro')),
  provider text check (provider in ('app_store', 'play', 'stripe')),
  sku text default 'ai_pro_monthly',
  renews_at timestamptz,
  updated_at timestamptz not null default now()
);

-- Opaque blobs only. kind is metadata so queries stay useful without decrypting.
create table if not exists public.encrypted_events (
  id uuid primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  kind text not null check (kind in ('lift', 'run', 'calorie', 'readiness', 'plan', 'pt_export')),
  created_at timestamptz not null default now(),
  ciphertext text not null,
  client_schema_version int not null default 1
);

create index if not exists encrypted_events_user_kind_created
  on public.encrypted_events (user_id, kind, created_at desc);

create table if not exists public.pt_share_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  clinician_email text,
  expires_at timestamptz not null,
  ciphertext_bundle text not null,
  revoked boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.subscriptions enable row level security;
alter table public.encrypted_events enable row level security;
alter table public.pt_share_tokens enable row level security;

create policy "own profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "own subscription" on public.subscriptions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "own events" on public.encrypted_events
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "own pt shares" on public.pt_share_tokens
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Server must never log ciphertext in plaintext analytics.
-- Do not add columns for sleep_score, weight, calories, etc.
