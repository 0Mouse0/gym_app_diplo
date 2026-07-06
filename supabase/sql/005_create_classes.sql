-- Parte 5: clases del gimnasio (con cupo).
-- Correr en el SQL Editor de Supabase, después de 001, 002, 003 y 004.
--
-- Cada fila es una clase concreta (una sesión con fecha/hora fija),
-- no una plantilla recurrente. Si "Yoga" se dicta todos los lunes,
-- se crea una fila por cada lunes. Esto simplifica bastante el
-- cálculo de cupo/ocupación en las próximas partes.

create table if not exists public.classes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  instructor text,
  scheduled_at timestamptz not null,
  duration_minutes integer not null default 60 check (duration_minutes > 0),
  capacity integer not null check (capacity > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint classes_name_schedule_unique unique (name, scheduled_at)
);

create index if not exists idx_classes_scheduled_at on public.classes(scheduled_at);

drop trigger if exists trg_classes_updated_at on public.classes;
create trigger trg_classes_updated_at
  before update on public.classes
  for each row
  execute function public.set_updated_at();

alter table public.classes enable row level security;
drop policy if exists "classes_anon_all" on public.classes;
create policy "classes_anon_all"
  on public.classes
  for all
  to anon
  using (true)
  with check (true);

-- Un par de clases de ejemplo, en los próximos días, para no arrancar
-- de una tabla vacía. Es seguro volver a correr este script: el
-- unique de (name, scheduled_at) evita duplicarlas.
insert into public.classes (name, instructor, scheduled_at, duration_minutes, capacity)
values
  ('Yoga', 'Ana Pérez', (current_date + interval '1 day' + time '08:00'), 60, 15),
  ('Spinning', 'Carlos Ruiz', (current_date + interval '2 day' + time '18:00'), 45, 20),
  ('Crossfit', 'Lucía Gómez', (current_date + interval '3 day' + time '19:00'), 60, 12)
on conflict (name, scheduled_at) do nothing;
