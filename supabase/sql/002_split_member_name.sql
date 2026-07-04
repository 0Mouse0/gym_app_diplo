-- Migración: separar el nombre completo en Nombres/Apellidos.
-- Correr en el SQL Editor de Supabase, DESPUÉS de 001_create_members_table.sql.
-- Se trunca, por si acaso hay datos dentro
truncate table public.members;

alter table public.members drop column if exists full_name;
alter table public.members add column first_name text not null;
alter table public.members add column last_name text not null;
