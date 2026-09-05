# `super_admin` — SaaS Owner Console

Everything the **platform owner** (SchoolPulse SaaS operator) sees and does
lives in this folder. If you are adding or changing an owner-console screen,
service, route or dependency, it belongs here — not scattered across
`lib/app/`, `lib/core/` or a sibling feature.

## Layout

```
super_admin/
├── data/            # datasources, repositories, models, services (Firestore + callables)
│   └── platform_health_repository.dart   # platform_health/current aggregate
├── domain/          # entities, security policy/session services, repository contracts
│   └── platform_health_models.dart
├── presentation/
│   ├── pages/       # every owner-console screen
│   ├── widgets/     # owner-console-only shells, nav, guards, top bar
│   ├── bloc/        # SuperAdminBloc, cubits
│   ├── login_flow/  # PlatformOwnerAccessScreen (owner sign-in)
│   ├── responsive.dart
│   └── super_admin_routes.dart           # the ENTIRE /super-admin GoRoute subtree
├── super_admin_injection.dart            # registerSuperAdmin(sl) — DI graph
└── README.md
```

## Wiring points (only two, both one line)

| Concern | File | Hook |
| --- | --- | --- |
| Routes | `lib/app/router.dart` | splices in `superAdminRoutes` |
| DI     | `lib/injection_container.dart` | calls `registerSuperAdmin(sl)` |

Add a new owner screen → add its `GoRoute` inside `super_admin_routes.dart`,
nothing in `router.dart` changes. Add a new owner service that needs DI → add
it inside `registerSuperAdmin()`.

## Deliberate exceptions (do not "fix" these)

- **`SecuritySettingsRemoteDataSource` / `OwnerSessionRemoteDataSource`** are
  registered directly in `injection_container.dart` `init()`, right after the
  core `FirebaseFirestore` singleton. Registration order matters, so they are
  intentionally not inside `registerSuperAdmin()`.
- **Owner login use cases** (`LoginOwnerWithEmail/Google/Apple`,
  `VerifyOwnerSession`) live in `features/auth/domain/usecases/login_owner.dart`.
  They are part of the shared `AuthBloc` / `AuthRepository` graph and moving
  them would split the auth domain. `PlatformOwnerAccessScreen` (the sign-in
  screen itself) does live here, under `presentation/login_flow/`.
- **`AdminSeeder`** (`lib/core/utils/admin_seeder.dart`) is QA/demo seeding for
  *school* admins — unrelated to the SaaS owner despite the name.

## Outbound dependencies

`super_admin` may import from `auth`, `billing`, `institution`, `profile`,
`module_control`. Nothing outside `super_admin` should import *from* it except
the two wiring points above.
