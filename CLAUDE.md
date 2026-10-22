# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

School Pulse is a multi-tenant Flutter + Firebase school-management platform for Uganda, targeting Android, iOS, and web from one codebase. See `PROJECT_CONTEXT.md` for the full product/architecture context (business rules, functional areas, engineering conventions) — read it before making non-trivial changes. `README.md` has the core business rules (user access, parent-student allocation limits).

Firebase project: `school-pulse-3d95b` (see `.firebaserc`).

## Commands

### Flutter app
```bash
flutter analyze                          # static analysis — must be zero new warnings/errors
dart format <files>                      # format touched files before committing
flutter test                             # full test suite
flutter test test/features/<feature>/    # a feature's tests only
flutter test path/to/some_test.dart      # a single test file
flutter test path/to/some_test.dart --plain-name "test name"  # a single test case
flutter run -d chrome --web-port=<port>  # run web in debug (interactive hot reload)
flutter run -d <device-id>               # run on a simulator/device in debug
flutter build web --release              # web release build (build/web)
flutter build apk --release              # Android release APK
flutter build ios --release --no-codesign # iOS release build, unsigned (no distribution cert configured)
```
`flutter devices` lists available simulators/browsers. `flutter build ios`/`build apk` in **release** mode is not supported for running on a simulator — use debug mode (`flutter run`) for simulator testing, release builds are for real artifacts only.

### Firebase Functions (`functions/`)
Each backend feature/module has its own named test script in `functions/package.json` rather than one blanket `npm test` — e.g.:
```bash
npm run test:rules                                   # Firestore rules (emulator)
npm run test:storage-rules                           # Storage rules (emulator)
npm run test:finance-governance:emulator             # one feature's emulator test
npm run test:academic-calendar-billing               # a pure-logic unit test (no emulator)
```
Check `functions/package.json` `scripts` for the exact script name matching the module you touched — emulator-backed tests (`*:emulator`, `test:rules*`) spin up `firebase emulators:exec` against a scoped demo project id; plain tests (e.g. `test:report-card-engine`) run directly with `node`.

### Deploy
```bash
firebase use school-pulse-3d95b
firebase deploy --only hosting     # web (after flutter build web --release)
firebase deploy --only functions   # Cloud Functions
firebase deploy --only firestore:rules,firestore:indexes,storage
```
Never deploy without running the relevant tests/analyze first, and never weaken `firestore.rules`/`storage.rules`.

## Architecture

- `lib/main.dart` — bootstrap: Firebase/App Check init, DI, notification init, app-wide BLoCs. Notification init (`getToken()`) has historically hung the splash screen on iOS simulator/web if awaited unconditionally in `main()` before `runApp()` — it must be time-bounded (`.timeout(...)`).
- `lib/app/router.dart` — single large `go_router` config: every route, auth/role/institution redirect guards, and responsive shell wiring. Look here first when tracing navigation. Several `ShellRoute`s (Student/Parent/Staff/Nurse/Messaging) keep a persistent shell mounted around their nested routes; most admin routes (`/staff/admin/...`) are plain nested `GoRoute`s, not shell-wrapped, each building a full-page widget (e.g. `AdminShell`) independently — `context.push` vs `context.go` matters here since siblings aren't shell-composed.
- `lib/features/<feature>/` — feature-first, each usually split into `data/`, `domain/`, `presentation/` (screens, widgets, `bloc/`). State management is `flutter_bloc`; DI is `get_it` via `lib/injection_container.dart`.
- `lib/core/` — shared services: roles/permissions (`user_roles.dart`), theme, networking, cross-cutting utilities.
- `lib/design_system/` — shared UI components, responsive breakpoints/layout builder, theming. Reuse these before adding new one-off widgets; responsive web/mobile parity is a hard requirement.
- Admin desktop/tablet shells (e.g. `AdminWebShell`, `BursarShell`) follow a common pattern: a persistent `_Sidebar` + `Expanded(IndexedStack(...))` of per-section `Navigator`s keyed by an enum, so in-shell section switches don't go through `go_router` at all — only entry into/out of the shell does.
- `lib/features/structure/` — the school setup/onboarding wizard (16 steps covering institution profile, academic years/calendar, education levels, classes, streams, subjects, teaching plans, departments, responsibilities, assessment/grading, spaces, operations, feature toggles, timetables, review). `structure_screen.dart` drives the step sequence; `SetupWizardShell` (in `presentation/widgets/`) is the single shared shell (header, step progress, sticky footer) all steps should use. `StructureBloc` backs most steps directly against Firestore; a few steps (teaching plans, academic responsibilities) instantiate their own repositories against `FirebaseFirestore.instance` directly rather than going through the bloc — this is existing, intentional inconsistency, not a bug to silently "fix" without checking history first.
- `functions/` — private Cloud Functions for core product workflows (finance, health, exam factory, report cards, attendance, etc.), Node 20. `public_functions/` — public-site functions: owner/platform auth, payments, email, onboarding, portal-domain lookups, document verification. Every callable must validate `request.auth`, look up the caller's role/institution, and reject cross-tenant calls server-side (see `functions/academic_calendar_billing.js`'s `requireSchoolAdmin()` for the pattern).
- `firestore.rules` / `storage.rules` / `firestore.indexes.json` — most structure/setup collections are top-level (not nested under `schools/{id}`) and rely on `isSameSchool(resource.data.schoolId)` + `schoolIdUnchanged()` checks for tenant isolation; some collections (e.g. `academic_terms`) add defense-in-depth blocking specific client-side field flips (e.g. `isConfirmed`).

## Engineering conventions specific to this repo

1. **Tenant isolation is non-negotiable.** Every read/write/query/function must be scoped to the authenticated institution; never weaken rules or add cross-tenant access.
2. **A student can be linked to at most 2 parents**; a parent can be linked to many students; only school admins can reallocate an existing link (see `README.md`).
3. Reuse existing BLoC/repository/design-system patterns before introducing new ones — this codebase has accumulated some duplication (see the `school_onboarding` vs `structure` example below) and new duplication should not be added.
4. Don't assume a single fixed curriculum, term structure, class naming, or grading model — the platform must support Ugandan and international schools, K–12, and custom structures. Avoid hard-coded regional defaults (e.g. defaulting country to Uganda, fixed district lists, fixed term names) in new or edited onboarding code.
5. For money, health, student data, attendance, gate access, or notifications: explicitly consider authorization, auditability, and offline/failure behavior — these domains have existing audit-log and offline-queue patterns to extend, not replace.
6. When multiple similar-looking modules exist for the same concept, check git history/comments for which one is actually wired into the router/DI before extending either — dead, unwired duplicates (fully built out, tested, but never referenced outside their own folder) have existed in this codebase before.
