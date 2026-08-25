# School Pulse — Project Context for ChatGPT

## Purpose

School Pulse is a multi-tenant school-management platform built primarily for
schools in Uganda. It provides a consistent web and mobile experience for the
people who run a school, teach in it, care for learners, and communicate with
their families.

The product combines daily school operations in one application: learner and
staff records, academic work, attendance, finance, health, boarding, transport,
communications, reports, parent access, and administration.

## Technology

- **Client:** Flutter/Dart. The same codebase targets Android, iOS, and web.
- **State and navigation:** `flutter_bloc`/BLoC, `go_router`, and dependency
  injection through `get_it`.
- **Backend:** Firebase Authentication, Cloud Firestore, Cloud Functions,
  Cloud Storage, Cloud Messaging, Analytics, and App Check.
- **Offline support:** Isar is used where offline caching/queued work is
  appropriate, notably in the notifications feature.
- **Server code:** Node.js Firebase Functions in `functions/` and
  `public_functions/`. The configured Firebase project is `school-pulse-3d95b`.

## Product model

School Pulse is a SaaS platform. A school is an institution/tenant and users
must only access data in their own institution. The **super admin** is the
platform owner and is not a school-tenant user.

Primary user groups include parents, school administrators, headteachers,
directors, teachers (class and subject teachers), bursars/finance staff, nurses,
matrons/boarding staff, librarians, deans, HR staff, gate/security staff,
transport staff, and other operational roles.

Parent access is intentionally limited to their own children. A learner can be
linked to at most **two parents**; one parent may be linked to many learners.
Only school administrators can reallocate an existing parent–student link.

## Main functional areas

- Admissions, student identity, enrolment, parent–student relationships, and
  school structure (campuses, classes, streams, subjects, terms, and years).
- Teacher workflows: classes, lessons, attendance, homework/tasks, resources,
  marks, performance, report cards, and comments.
- Parent portal: a view of their children’s academics, attendance, fees,
  payments, health, library activity, discipline, transport, boarding,
  appointments, messages, calendar, and notifications.
- Finance: fees and structures, payments, budgets, expenditures, payroll,
  scholarships, and reports.
- Health and welfare: health profiles/checks, clinic visits, medical inventory,
  supply requests, boarding, dormitories, beds, roll call, leave, and welfare.
- Operations: library, inventory/assets, transport, gate operations, biometric
  and QR/NFC identity flows, discipline, catering, games, religion, HR,
  approvals, appointments, communications, and reports.
- Platform functions: school onboarding, subscriptions/payments, branding,
  data management, integrations, official documents and their QR verification.

## Project structure

- `lib/main.dart` — Flutter bootstrap, Firebase/App Check initialization,
  dependency injection, notification initialization, and app-wide BLoCs.
- `lib/app/router.dart` — routes, authentication/role/institution guards, and
  responsive shells.
- `lib/features/<feature>/` — feature-first Flutter code, usually split into
  `data`, `domain`, and `presentation` layers.
- `lib/core/` — shared application services, access/permissions, theme,
  networking, utilities, and shared abstractions.
- `lib/design_system/` — reusable components, responsive layout, and themes.
- `functions/` — private Firebase Functions for core product workflows.
- `public_functions/` — public-site functions, owner/platform auth, payments,
  email, onboarding, location, and document verification.
- `firestore.rules`, `storage.rules`, `firestore.indexes.json` — backend access
  controls and Firestore indexes.
- `test/` and function tests — automated tests.

## Engineering conventions to preserve

1. Treat tenant isolation, roles, and permissions as core requirements—not UI
   details. Do not offer cross-school access or weaken Firestore rules.
2. Keep each feature’s existing data/domain/presentation separation and use the
   existing BLoC/repository patterns instead of introducing unrelated state
   management.
3. Preserve responsive web/mobile parity: staff navigation uses responsive
   shells; parent and operational flows should remain usable on mobile.
4. Never put API keys, Firebase secrets, personal data, or credentials in code,
   ChatGPT replies, or commits. `.env.example` files describe configuration.
5. Reuse existing components, theme, routing, entities, repositories, and
   permission checks before creating new equivalents.
6. For changes involving money, health, student data, attendance, gate access,
   or notifications, explicitly consider authorization, auditability, data
   correctness, and failure/offline behaviour.

## Notifications — important existing design

Notifications are a mature module under `lib/features/notifications/`.

- Server-side fan-out creates one Firestore document per recipient.
- Read, opened, delivered, and acknowledged timestamps are separate states.
- Push notifications are data-only; the client applies quiet hours, category
  preferences, and lock-screen redaction.
- Emergency, medical, attendance, gate, and security notifications cannot be
  muted and override quiet hours.
- Deep links are validated and authorised before navigation.
- Notifications support cache-first/offline behaviour and local queued writes.

See `NOTIFICATIONS_MODULE.md` for implementation detail, verification status,
known gaps, and deployment considerations.

## How to assist on this project

When answering a School Pulse question:

1. First identify the relevant role, tenant boundary, and existing feature.
2. Prefer a focused change that fits the current Flutter + Firebase structure.
3. State assumptions where a business rule is not yet known; do not invent a
   policy that could affect school data or access.
4. For code suggestions, name the likely files/layers to inspect and include
   validation steps (tests, Flutter analysis, Firestore-rules checks, or
   emulator tests as appropriate).
5. Be practical and concise. Explain technical terms in plain language when
   the request is non-technical.

## Current caveats noted in project documentation

- iOS push delivery needs a paid Apple Developer membership and a real bundle
  identifier/provisioning configuration; a simulator cannot receive APNs push.
- Web App Check is intentionally not enabled until a real reCAPTCHA v3 key is
  configured.
- Notification digest scheduling, an email/SMS delivery worker, and a template
  editing UI are documented as remaining work.

## Useful starting files

- `README.md` — core product rules and basic project overview.
- `lib/core/user_roles.dart` — defined user roles and their dashboard routing.
- `lib/app/router.dart` — routes and access/role guards.
- `lib/injection_container.dart` — services and repositories registered for
  dependency injection.
- `NOTIFICATIONS_MODULE.md` — detailed notification architecture and status.

---

This document is a working overview, not a substitute for the source code.
Keep it updated after major product or architecture changes.
