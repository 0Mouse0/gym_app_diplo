# Sistema de Gestión de Gimnasio

Proyecto académico: sistema de información para gimnasios hecho en **Flutter**, con **Riverpod** como manejo de estado/arquitectura y **Supabase** como backend remoto (base de datos Postgres + autenticación).

Gestiona miembros, membresías (con vigencia), pagos, clases (con cupo) e inscripciones, con las validaciones de negocio y los reportes que se detallan más abajo.

---

## Índice

1. [Stack tecnológico](#stack-tecnológico)
2. [Arquitectura](#arquitectura)
3. [Modelo de datos](#modelo-de-datos)
4. [Guía de instalación](#guía-de-instalación)
5. [Módulos y reglas de negocio](#módulos-y-reglas-de-negocio)
6. [Reportes](#reportes)
7. [Seguridad](#seguridad-autenticación-y-rls)
8. [Cómo se cubre cada punto de la rúbrica](#cómo-se-cubre-cada-punto-de-la-rúbrica)
9. [Decisiones de diseño y por qué](#decisiones-de-diseño-y-por-qué)
10. [Limitaciones conocidas / mejoras futuras](#limitaciones-conocidas--mejoras-futuras)
11. [Problemas que aparecieron durante el desarrollo (y cómo se resolvieron)](#problemas-que-aparecieron-durante-el-desarrollo)
12. [Estructura de carpetas](#estructura-de-carpetas)

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| UI / lógica de app | Flutter (Dart >= 3.3) |
| Manejo de estado | Riverpod clásico (`StateNotifier` + `StateNotifierProvider`)|
| Backend remoto | Supabase (Postgres + Auth + Row Level Security) |
| Tipografía | Google Fonts (Poppins para títulos, Inter para texto) |
| Otras dependencias | `supabase_flutter`, `flutter_dotenv` (variables de entorno), `intl` (fechas/moneda) |

## Arquitectura

El proyecto sigue **Clean Architecture por feature**: cada módulo (`members`, `memberships`, `payments`, `classes`, `enrollments`, `membership_types`, `reports`, `auth`, `home`) tiene sus propias carpetas `domain/`, `data/` y `presentation/`, más una carpeta `core/` transversal.

```
domain/         → entidades (clases inmutables) + interfaces de repositorio (abstract class)
                  + servicios de dominio (reglas de negocio que cruzan entidades)
data/           → implementación concreta del repositorio (habla con Supabase)
                  + su provider de Riverpod
presentation/   → providers (StateNotifier + estado inmutable) + pantallas (formularios/listados)
```

## Modelo de datos

```
members (miembros)
  └─< memberships (membresías) >── membership_types (tipos: Mensual, Trimestral, etc.)
        └─< payments (pagos)
members >─< classes   (a través de)   enrollments (inscripciones)
```

- Un **miembro** puede tener varias **membresías** a lo largo del tiempo, pero nunca dos vigentes/superpuestas al mismo tiempo.
- Una **membresía** pertenece a un **tipo** (que define duración y precio) y puede tener uno o más **pagos** asociados.
- Un **miembro** se **inscribe** a una **clase** (relación muchos a muchos a través de `enrollments`), sujeto a cupo y vigencia de membresía.

## Guía de instalación

### 1. Crear el proyecto Flutter

```bash
flutter create gym_app
cd gym_app
```

Reemplaza el `pubspec.yaml` generado por el de este repo, y copia la carpeta `lib/` completa.

### 2. Crear el proyecto en Supabase

En [supabase.com](https://supabase.com), creá un proyecto nuevo (es gratis). Andá a **Project Settings → API** y se copia:
- **Project URL**
- **publishable key**

### 3. Configurar variables de entorno

Copia `.env.example` a `.env` y completa esos dos valores:

```bash
cp .env.example .env
```

```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-publishable-key
```

### 4. Correr los scripts SQL, EN ORDEN

En el **SQL Editor** de Supabase, corre uno por uno, en este orden exacto (cada uno depende del anterior):

| # | Script | Qué hace |
|---|---|---|
| 1 | `001_create_members_table.sql` | Tabla `members`, con RLS habilitado |
| 2 | `002_split_member_name.sql` | Separa el nombre completo en `first_name`/`last_name` |
| 3 | `003_create_membership_tables.sql` | Tablas `membership_types` y `memberships` (con tipos de ejemplo) |
| 4 | `004_create_payments.sql` | Tabla `payments` |
| 5 | `005_create_classes.sql` | Tabla `classes` (con clases de ejemplo) |
| 6 | `006_create_enrollments.sql` | Tabla `enrollments` |
| 7 | `007_restrict_to_authenticated.sql` | Cambia el acceso de `anon` a `authenticated` |

**Importante**: antes de correr el script 7, se debe crear el o los usuarios admin (paso siguiente) — si no, se quedará sin acceso a la base.

### 5. Crear el usuario administrador

Supabase Dashboard → **Authentication → Users → Add user**. Completá email y contraseña, y tildá **"Auto Confirm User"** (evita el flujo de confirmación por email, innecesario para un usuario interno).

### 6. Instalar dependencias y correr

```bash
flutter pub get
flutter run
```

### Notas de entorno (Android/Windows)

Si el build de Android falla con errores de Kotlin tipo `Could not close incremental caches` / `Daemon compilation failed`, se agrega esta línea a `android/gradle.properties`:

```
kotlin.incremental=false
```

Es un bug conocido del compilador incremental de Kotlin en Windows, no relacionado con este proyecto en particular.

## Módulos y reglas de negocio

Cada módulo sigue el mismo patrón (CRUD con formulario validado + listado), así que en este punto me centro en lo que tiene de particular cada uno — sobre todo las reglas de negocio.

### Miembros
CRUD estándar. Nombres y apellidos separados (para ordenar/mostrar como directorio: "Apellido, Nombre"). El documento (`document_id`) es único — la restricción vive en la base (`unique`), y el repositorio traduce el error a "Ya existe un miembro con ese número de documento" en vez de mostrar el error crudo de Postgres.

El flag `is_active` de un miembro **no es decorativo**: un miembro inactivo no puede recibir una membresía nueva ni inscribirse a una clase (ver más abajo).

### Tipos de Membresía
Catálogo simple (nombre, duración en días, precio). Sirve de base para calcular la vigencia de una membresía automáticamente.

### Membresías
La fecha de fin **se calcula sola** a partir del tipo elegido (`start_date + duration_days del tipo`) — nunca se escribe a mano, para que no pueda quedar inconsistente con el tipo.

`Membership` tiene lógica de dominio reutilizable:
- `isExpired`: la fecha de fin ya pasó.
- `isFuture`: la fecha de inicio todavía no llegó (membresía "programada", por ejemplo una renovación cargada de antemano).
- `isCurrentlyValid`: `is_active == true` **y** no vencida **y** no futura. Esta es la propiedad que usa Inscripciones.

**Regla de negocio** (vive en `MembershipRulesService`, `domain/services/`): no se puede asignar una membresía si:
1. El miembro no existe o está inactivo.
2. Sus fechas se superponen con otra membresía `is_active = true` del mismo miembro (esto cubre "no más de una membresía activa a la vez", y de paso permite programar una renovación que arranca justo cuando termina la actual, porque esa no se superpone).

**Sincronización de vencidas**: cada vez que se lista, el repositorio corre un `UPDATE` que apaga `is_active` de las membresías cuya fecha de fin ya pasó.

### Pagos
Asociados a una membresía (no directamente al miembro — se llega al miembro a través de la membresía). El monto se sugiere automáticamente según el precio del tipo, pero es editable (descuentos, pagos parciales). El método de pago es un `enum` (`efectivo`/`tarjeta`/`transferencia`), no un string suelto, para que nunca pueda mandarse un valor que la base rechace.

### Clases
Cada fila es una **sesión concreta** (fecha/hora fija), no una plantilla recurrente — si "Yoga" se dicta todos los lunes, hay una fila por cada lunes. `capacity` tiene un `check > 0` en la base.

### Inscripciones
Vive en `EnrollmentRulesService` (`domain/services/`), que cruza **cuatro repositorios** (Miembros, Membresías, Clases, Inscripciones) antes de permitir una inscripción:

1. **No inscribir si la clase ya alcanzó su cupo**: cuenta inscripciones reales contra `GymClass.capacity`.
2. **No inscribir si la membresía del miembro está vencida o inactiva**: usa `Membership.isCurrentlyValid`.

Una inscripción **no tiene "editar"** — es una decisión de diseño: cancelar una inscripción es borrarla (libera el cupo), no tiene sentido de negocio "editar" a qué miembro o clase apunta una inscripción existente.

El formulario de inscripción (`EnrollmentFormScreen`) no conoce ninguna de estas reglas: solo llama a `controller.enroll(memberId, classId)` y muestra el mensaje de error que venga del servicio.

## Reportes

| Reporte | Basado en | Lógica en |
|---|---|---|
| Membresías por vencer (ventana de 7/15/30 días) | `membershipsControllerProvider` | `ExpiringMembershipsReport` |
| Ingresos por mes / período personalizado | `paymentsControllerProvider` | `RevenueReport` |
| Ocupación de clases (inscritos vs. cupo) | `classesControllerProvider` + `enrollmentsControllerProvider` | `ClassOccupancyReport` |

Cada uno es una clase con métodos estáticos puros (sin Supabase, sin widgets) en `lib/features/reports/domain/` — la pantalla solo llama al cálculo y pinta el resultado.

## Seguridad (autenticación y RLS)

El login (`AuthGate` → `LoginScreen` / `HomeScreen`) usa **Supabase Auth** (email + contraseña). No hay registro público: los usuarios admin se crean a mano desde el Dashboard de Supabase.

Lo que hace que el login sea real y no solo cosmético es el script `007_restrict_to_authenticated.sql`: cambia las políticas de Row Level Security de las 6 tablas de `to anon` (cualquiera con la clave pública) a `to authenticated` (solo con una sesión válida). Antes de ese script, la PUBLISHABLE KEY ya tenía acceso total a todo; después, hace falta haber iniciado sesión para leer o escribir cualquier dato.

## Cómo se cubre cada punto de la rúbrica

| Criterio | Cómo se cumple |
|---|---|
| **Integración del stack** (almacenamiento remoto) | Las 6 entidades viven en Supabase (Postgres), con `select` embebidos para traer datos relacionados en una sola consulta (ej. `payments -> memberships -> members`), y Supabase Auth para el login. |
| **Arquitectura limpia con Riverpod** | `StateNotifierProvider` de punta a punta para todo estado mutable; `Provider` para repositorios/servicios; el estado de sesión reacciona solo a los cambios de Supabase Auth. Ningún `setState` maneja lógica de negocio. |
| **Código desacoplado, tema centralizado** | `core/theme/` es la única fuente de colores/tipografía/espaciados. Los repositorios traducen errores de Supabase a mensajes de dominio (`RepositoryException`) — los widgets nunca ven un `PostgrestException` crudo. Las reglas que cruzan entidades viven en servicios de dominio dedicados (`MembershipRulesService`, `EnrollmentRulesService`), nunca en pantallas. |
| **CRUDs completos con formularios validados** | Miembros, Tipos de Membresía, Membresías, Pagos y Clases tienen alta/baja/modificación/listado completos. Inscripciones tiene alta/baja/listado (sin modificación, por diseño — no tiene sentido de negocio editar a quién/qué apunta una inscripción ya creada). |

## Decisiones de diseño y por qué

- **Vigencia de membresía calculada, no un simple booleano**: `isExpired`/`isFuture`/`isCurrentlyValid` se calculan comparando fechas en tiempo real, en vez de depender únicamente de un flag que alguien tiene que actualizar. El flag `is_active` en la base existe para permitir la desactivación manual (y se sincroniza con la fecha de forma perezosa), pero la fuente de verdad para "¿puedo usar esto hoy?" siempre pasa por el getter calculado.
- **Servicios de dominio en vez de métodos de repositorio para reglas cruzadas**: cuando una regla necesita datos de más de una entidad (ej. inscribir a alguien requiere consultar Miembros + Membresías + Clases), se armó un servicio aparte (`domain/services/`) en vez de hacer que un repositorio dependa de otro. Mantiene cada repositorio enfocado en una sola tabla.
- **Inscripciones sin "editar"**: ver la sección de Inscripciones arriba.

## Limitaciones conocidas / mejoras futuras

Documentadas a propósito, no son descuidos:

- **Sincronización de membresías vencidas es "perezosa"**: se actualiza cuando alguien lista membresías, no en tiempo real. Una fila puede quedar con `is_active = true` desactualizado en la base si nadie abre esa pantalla. Para tiempo real de verdad haría falta un proceso en el servidor (`pg_cron` en Supabase), que quedó fuera de alcance a propósito.
- **Un solo rol de usuario**: no hay distinción entre administrador y recepcionista. Agregar roles requeriría una tabla de perfiles + políticas RLS más finas por rol.
- **Sin recuperación de contraseña ni registro desde la app**: los admins se crean a mano desde el Dashboard de Supabase.
- **Posible condición de carrera en la validación de superposición de membresías**: la validación es "consultar y después insertar", no una restricción atómica de base de datos (tipo `EXCLUDE USING gist`). Para un solo usuario administrando la app a la vez (el caso de uso real de este proyecto) no es un problema, pero en un escenario con múltiples administradores escribiendo al mismo tiempo, en teoría dos inserciones simultáneas podrían colarse. Se podría reforzar con una restricción de exclusión en Postgres si hiciera falta.

## Estructura de carpetas

```
lib/
  main.dart                    → carga .env, inicializa Supabase, arranca ProviderScope
  app.dart                     → MaterialApp, tema, punto de entrada = AuthGate
  core/
    theme/                     → colores, tipografía, espaciados, ThemeData centralizado
    config/                    → lectura de variables de entorno
    supabase/                  → provider único del SupabaseClient
    errors/                    → RepositoryException (excepción de dominio)
    utils/                     → validadores de formulario reutilizables
  features/
    auth/                      → login, estado de sesión, AuthGate
    home/                      → pantalla principal + drawer de navegación
    members/                   → CRUD de miembros
    membership_types/          → CRUD de tipos de membresía
    memberships/               → CRUD de membresías + MembershipRulesService
    payments/                  → CRUD de pagos
    classes/                   → CRUD de clases
    enrollments/                → alta/baja de inscripciones + EnrollmentRulesService
    reports/                    → los 3 reportes (cálculo puro + pantallas)

  # cada feature de datos sigue el mismo patrón interno:
  features/<nombre>/
    domain/
      entities/                → clases inmutables
      repositories/            → interfaz abstracta
      services/                → reglas de negocio que cruzan entidades (solo donde aplica)
    data/
      repositories/            → implementación contra Supabase
      providers/               → Provider<Repository>
    presentation/
      providers/               → estado inmutable + StateNotifier (controller)
      screens/                 → formulario + listado

supabase/
  sql/                          → scripts de creación de tablas, en orden (001 a 007)
```
