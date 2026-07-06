-- Parte 3: catálogo de tipos de membresía + membresías por miembro.
-- Correr después de 001 y 002.

create table if not exists public.membership_types (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  duration_days integer not null check (duration_days > 0),
  price numeric(10,2) not null check (price >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.memberships (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  membership_type_id uuid not null references public.membership_types(id) on delete restrict,
  start_date date not null,
  end_date date not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_memberships_member_id on public.memberships(member_id);
create index if not exists idx_memberships_end_date on public.memberships(end_date);

-- Reutiliza la función set_updated_at() creada en 001_create_members_table.sql
drop trigger if exists trg_memberships_updated_at on public.memberships;
create trigger trg_memberships_updated_at
  before update on public.memberships
  for each row
  execute function public.set_updated_at();

alter table public.membership_types enable row level security;
alter table public.memberships enable row level security;

drop policy if exists "membership_types_anon_all" on public.membership_types;
create policy "membership_types_anon_all"
  on public.membership_types for all to anon using (true) with check (true);

drop policy if exists "memberships_anon_all" on public.memberships;
create policy "memberships_anon_all"
  on public.memberships for all to anon using (true) with check (true);

-- Datos de ejemplo para no arrancar de una tabla vacía (opcional, podés borrarlos).
insert into public.membership_types (name, duration_days, price) values
  ('Mensual', 30, 25.00),
  ('Trimestral', 90, 65.00),
  ('Anual', 365, 220.00)
on conflict (name) do nothing;
