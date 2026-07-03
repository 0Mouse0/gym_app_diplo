# Parte 0 — Setup base (tema + Supabase + Riverpod clásico)

## Qué incluye
- `core/theme/`: colores, tipografía y espaciados centralizados + `AppTheme` (ThemeData único).
- `core/config/env.dart`: acceso centralizado a variables de entorno.
- `core/supabase/supabase_providers.dart`: provider único del `SupabaseClient`.
- `features/home/`: pantalla de prueba + un `StateNotifierProvider` (patrón clásico de Riverpod) que verifica la conexión a Supabase.

## Pasos para integrarlo en tu máquina

1. Creá el proyecto Flutter (si todavía no lo hiciste):
   ```bash
   flutter create gym_app
   cd gym_app
   ```

2. Reemplazá el `pubspec.yaml` generado por el de este paquete, y copiá la carpeta `lib/` completa (reemplazando el `lib/main.dart` de ejemplo).

3. Creá un proyecto en [supabase.com](https://supabase.com) (es gratis). Andá a **Project Settings → API** y copiá:
   - **Project URL**
   - **anon public key**

4. Copiá `.env.example` a `.env` y completá esos dos valores:
   ```bash
   cp .env.example .env
   ```
   (`.env` ya está en `.gitignore`, no se sube al repo).

5. Instalá las dependencias:
   ```bash
   flutter pub get
   ```

6. Corré la app:
   ```bash
   flutter run
   ```

## Qué deberías ver (criterio de "funciona")
- La pantalla carga con el tema aplicado (colores, tipografía Poppins/Inter, botones, campo de texto con el estilo centralizado).
- Una tarjeta arriba muestra el estado de conexión con Supabase:
  - 🟡 mientras verifica,
  - 🟢 "Conectado a Supabase..." si las credenciales del `.env` son correctas (aunque no exista ninguna tabla todavía — es esperado, en la Parte 2 creamos la primera tabla),
  - 🔴 con un mensaje de error si la URL o la key están mal.
- El botón de refrescar (ícono ⟳) vuelve a disparar la verificación.

## Por qué esta estructura ya cumple parte de la rúbrica
- **Ningún color/estilo suelto**: todos los widgets usan `Theme.of(context)` o `AppColors`/`AppSpacing`, nunca `Color(0xFF...)` directo.
- **Riverpod usado desde el día 1**: el chequeo de conexión ya sigue el patrón `StateNotifier` + `StateNotifierProvider` que vamos a repetir en cada módulo (listados, formularios, validaciones de negocio).
- **Acceso remoto desacoplado**: ningún widget ni futuro repositorio va a llamar a `Supabase.instance.client` directamente — todos dependen de `supabaseClientProvider`.

## Siguiente parte
Parte 1: creación de la tabla `members` en Supabase + modelo `Member` (sin freezed, clase inmutable manual con `copyWith`/`fromJson`/`toJson`) + `MemberRepository` (interfaz + implementación Supabase) — todavía sin UI, probado con un botón simple que liste miembros por consola/pantalla mínima. Después de eso, en la Parte 2 armamos el CRUD completo con formulario validado.
