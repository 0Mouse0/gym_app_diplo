-- Parte 4: pagos asociados a una membresía.
-- Correr en el SQL Editor de Supabase, después de 001, 002 y 003.

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  membership_id uuid not null references public.memberships(id) on delete cascade,
  amount numeric(10, 2) not null check (amount > 0),
  payment_date date not null default current_date,
  payment_method text not null check (payment_method in ('efectivo', 'tarjeta', 'transferencia')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_payments_membership_id on public.payments(membership_id);
create index if not exists idx_payments_payment_date on public.payments(payment_date);

drop trigger if exists trg_payments_updated_at on public.payments;
create trigger trg_payments_updated_at
  before update on public.payments
  for each row
  execute function public.set_updated_at();

alter table public.payments enable row level security;
drop policy if exists "payments_anon_all" on public.payments;
create policy "payments_anon_all"
  on public.payments
  for all
  to anon
  using (true)
  with check (true);
