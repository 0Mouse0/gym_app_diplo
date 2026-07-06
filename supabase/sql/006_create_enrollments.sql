-- Parte 6: inscripciones de un miembro a una clase.
-- Correr en el SQL Editor de Supabase, después de 001 a 005.
--
-- No tiene "update": una inscripción no se edita, se cancela
-- (se borra la fila, liberando el cupo). El unique de
-- (member_id, class_id) evita que alguien quede inscrito dos veces
-- a la misma clase.

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  class_id uuid not null references public.classes(id) on delete cascade,
  enrolled_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint enrollments_member_class_unique unique (member_id, class_id)
);

create index if not exists idx_enrollments_class_id on public.enrollments(class_id);
create index if not exists idx_enrollments_member_id on public.enrollments(member_id);

alter table public.enrollments enable row level security;
drop policy if exists "enrollments_anon_all" on public.enrollments;
create policy "enrollments_anon_all"
  on public.enrollments
  for all
  to anon
  using (true)
  with check (true);
