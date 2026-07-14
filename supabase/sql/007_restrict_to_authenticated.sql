-- Parte 8: login de administrador — restringir el acceso a usuarios
-- autenticados.
--
-- ANTES de correr esto, creá al menos un usuario admin en Supabase:
-- Dashboard -> Authentication -> Users -> Add user, con email y
-- contraseña, tildando "Auto Confirm User" (así no necesita
-- verificar el email para poder loguearse).
--
-- IMPORTANTE: después de correr este script, la app deja de
-- funcionar sin haber iniciado sesión — es exactamente el objetivo.
-- Pasamos de "cualquiera con la anon key puede leer/escribir todo" a
-- "solo quien tenga una sesión válida".

-- members
drop policy if exists "members_anon_all" on public.members;
create policy "members_authenticated_all"
  on public.members
  for all
  to authenticated
  using (true)
  with check (true);

-- membership_types
drop policy if exists "membership_types_anon_all" on public.membership_types;
create policy "membership_types_authenticated_all"
  on public.membership_types
  for all
  to authenticated
  using (true)
  with check (true);

-- memberships
drop policy if exists "memberships_anon_all" on public.memberships;
create policy "memberships_authenticated_all"
  on public.memberships
  for all
  to authenticated
  using (true)
  with check (true);

-- payments
drop policy if exists "payments_anon_all" on public.payments;
create policy "payments_authenticated_all"
  on public.payments
  for all
  to authenticated
  using (true)
  with check (true);

-- classes
drop policy if exists "classes_anon_all" on public.classes;
create policy "classes_authenticated_all"
  on public.classes
  for all
  to authenticated
  using (true)
  with check (true);

-- enrollments
drop policy if exists "enrollments_anon_all" on public.enrollments;
create policy "enrollments_authenticated_all"
  on public.enrollments
  for all
  to authenticated
  using (true)
  with check (true);
