-- Parte 1: tabla de miembros del gimnasio.
-- Correr esto en Supabase: Dashboard -> SQL Editor -> New query -> pegar y ejecutar.

create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  document_id text not null unique,
  email text,
  phone text,
  birth_date date,
  address text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Mantiene updated_at al día automáticamente en cada UPDATE.
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_members_updated_at on public.members;
create trigger trg_members_updated_at
  before update on public.members
  for each row
  execute function public.set_updated_at();

-- RLS: la habilitamos desde ya (buena práctica), y por ahora dejamos
-- una política abierta para la ANON KEY, ya que el proyecto todavía
-- no tiene autenticación (la agregamos como mejora más adelante).
-- IMPORTANTE: esto es válido para un proyecto académico, no para producción.
alter table public.members enable row level security;

drop policy if exists "members_anon_all" on public.members;
create policy "members_anon_all"
  on public.members
  for all
  to anon
  using (true)
  with check (true);
