# School Administrator — Web IndexedDB / Offline Test Report

**Date:** 2026-09-02
**Branch:** `structure-module`
**Scope:** Verification pass only. No redesign, refactor, deploy, commit, push, rule weakening, or new browser caching. Working tree was **not modified** by this pass.
**Platform under test:** Flutter **web** build (`flutter build web --release`), Chrome/Edge target.

---

## EXECUTIVE SUMMARY — THE HEADLINE FINDING

**There is NO IndexedDB layer for the School Admin module on web. There is no web offline layer for ANY module.**

The app's offline/local-persistence stack is **Isar**, and Isar is **mobile/desktop only**. Every feature that has a local data source ships three variants wired by conditional import:

| Variant | Used on | Behavior |
|---|---|---|
| `*_local_data_source_mobile.dart` | Android / iOS / desktop (`dart.library.io`) | Real Isar DB, caching, offline queue |
| `*_local_data_source_web.dart` | **Web** (`dart.library.js_interop`) | **Pass-through to Firestore. No storage. No queue. No offline behavior.** |
| `*_local_data_source_stub.dart` | fallback | no-op |

`isar_bootstrap.dart` conditionally imports `isar_bootstrap_web.dart`, which **returns `null`** — no database is ever opened on web. `WebNetworkInfo.isConnected` **always returns `true`**, so every mobile-authored queue/retry path is dead code on web: nothing is ever detected as offline, nothing is ever queued.

**Grep proof — no IndexedDB anywhere in `lib/`:**
```
$ grep -rn "dart:indexed_db\|package:idb\|idb_shim\|IdbFactory\|window.indexedDB\|indexedDB" lib/
NONE FOUND
```

The only browser-persistent storage used by the app on web is:
- `SharedPreferences` (localStorage-backed) — used by **`OwnerNotificationOfflineStore`**, which is **Super Admin (SaaS owner) only**, explicitly documented as caching non-sensitive fields only, uid-namespaced, cleared on logout/switch. **Not a School Admin surface.**
- `flutter_secure_storage_web` — credential/session storage, framework-managed.
- `dart:html window.location.hostname` (read-only) in `portal_host_web.dart` — not storage.

Firestore's own web SDK persistence (IndexedDB-backed) is **not explicitly enabled** anywhere in `lib/` — no `Settings(persistenceEnabled:)`, no `enablePersistence()` call was found. The app relies on live Firestore reads on web.

### Consequence for this checklist

Every item in **Section F (IndexedDB / Web Offline)** and every offline sub-item elsewhere resolves to **NOT IMPLEMENTED** for web School Admin — not FAIL. There is no unsafe cache to leak, because there is no cache. This is a deliberate, documented architectural choice (every `_web.dart` file carries a header comment stating it).

---

## 1. SCHOOL ADMIN ROUTE & PERMISSION MATRIX

Source: `lib/app/router.dart`. School Admin's canonical role is `UserRole.schoolAdmin`; the shared admin console is gated by `UserRoleDisplay.adminConsoleRoles` (schoolAdmin + headTeacher + director + deputyHead, per code comments).

| Route | Guard mechanism | Roles permitted | Notes |
|---|---|---|---|
| `/staff` → redirects `/staff/dashboard` | top-level `redirect` (`redirect` cb, line 461) requires `AuthAuthenticated` else `/welcome` | any staff | Session/MFA/first-login-password gate applied here |
| `/staff/*` ShellRoute (`StaffShell`, line 1042) | `StaffShell._isAdmin()` reads `AppRoleSessionCubit` active role ∈ `adminConsoleRoles` for nav chrome | any staff (chrome differs) | Shell renders nav; **does not itself deny non-staff** — the top-level redirect + per-route guards do |
| `/staff/admin` (`AdminDashboardScreen`, line 2312) | **No `redirect` on the route itself** | Reachable by any authenticated staff who can load `/staff/*` | ⚠️ See Finding H-1 |
| `/staff/admin/data-management` | route `redirect` (2317) | schoolAdmin, headTeacher, director | ✅ |
| `/staff/admin/institution-health` | route `redirect` (2333) | schoolAdmin, headTeacher, director | ✅ |
| `/staff/admin/users/add-staff` | route `redirect` (2386) | `adminConsoleRoles` (deputyHead can navigate, Confirm disabled + CF denies) | ✅ defence-in-depth |
| `/staff/admin/integrations` | route `redirect` (2426) | schoolAdmin, headTeacher, director | ✅ |
| `/staff/admin/structure` (+ `/academics` alias) | route `redirect` (2654/2672) | schoolAdmin (+ others per code) | ✅ |
| `/staff/admin/approvals`, `/parents`, `/users`, `/broadcast-sms`, `/config` | **No route-level `redirect`** | any authenticated staff who reached `/staff/admin` | ⚠️ See Finding H-1 |
| `/staff/headteacher/report-approvals` | route `redirect` (2297) | headTeacher, director, schoolAdmin | ✅ |
| `/staff/bursar` | route `redirect` (1252) | bursar, schoolAdmin, headTeacher, director | ✅ |
| `/super-admin/**` | separate ShellRoute outside StaffShell; `router_super_admin_gate_test.dart` covers | superAdmin only | ✅ School Admin cannot reach owner console |
| `/owner-login`, owner routes | `router_owner_staff_gate_test.dart` | superAdmin only | ✅ |

**Server-side authority (Cloud Functions, `functions/`):**
- `createStaffAccount` — verifies caller role server-side (`create_staff_account_test.dart`, `staff_roles.test.cjs`); deputyHead denied.
- `createParentAccessCode` — server-verified (`create_parent_access_code.emulator.test.cjs` — not run, JDK blocker).
- Parent-link reallocation — server-only per `guardian_contact_resolution` architecture.

---

## 2. INDEXEDDB DATABASE / OBJECT-STORE INVENTORY

**Web:** *None.* No IndexedDB database is created or opened by application code on web.

**Mobile/desktop (for completeness — NOT web, NOT in scope for a web test but documents where the offline logic lives):** a single shared Isar instance (`openIsarForMobile()`), schemas registered in `isar_bootstrap_mobile.dart`, including `student_isar_models`, `notification_isar`, `pending_message_isar`, `attendance_record_isar`, `gate_ops_isar_models`, `clinic_visit_isar`, `enrollment_setup_draft_isar`, etc. **None of these load on web.**

**localStorage (SharedPreferences) keys on web:**
| Key prefix | Owner | Contents | School Admin? |
|---|---|---|---|
| `owner_notif_cache_v1_<uid>` | Super Admin | notification id/title/short body/timestamps | ❌ No |
| `owner_notif_queue_v1_<uid>` | Super Admin | safe-action queue (mark read, delete, prefs) | ❌ No |

---

## 3. OFFLINE QUEUE INVENTORY & SAFETY DECISION

**Web School Admin offline write queue:** **NOT IMPLEMENTED.** `WebNetworkInfo` always reports online; every `_web.dart` datasource writes straight to Firestore or no-ops. `getPendingStateChanges`, `getUnsyncedRecords`, `getPendingClinicVisits` all return `[]` on web by construction.

**Safety decision:** This is the safe outcome for the sensitive School Admin domains the checklist calls out — medical records, payment data, role/permission changes, parent reassignment, staff removal, identity changes. None are cached or queued offline on web; all go straight to Firestore + Cloud Functions with server verification. **UNSAFE TO CACHE** would be the correct policy for these if anyone proposed adding a web queue; today there is nothing to secure because nothing is stored.

**Recommended policy (if web offline is ever built):** identity/permission/financial/medical/parent-link writes must remain online-only (Cloud-Function-mediated); only idempotent, low-sensitivity reads (structure config, own dashboard counts) would be cache candidates, and only with an institution-ID + user-ID scoped store cleared on logout/switch.

---

## 4. TENANT-ISOLATION & LOGOUT / ACCOUNT-SWITCH PROOF

**IndexedDB tenant isolation:** N/A — no IndexedDB. Nothing to isolate, nothing to clear. Logout / account switch on web has no School Admin local store to wipe.

**Firestore rules (static review — emulator BLOCKED, see §5):** `firestore.rules` (3638 lines).
- `isSameSchool(schoolId)` (line 93): `isSuperAdmin() || myUser().schoolId == schoolId || isActiveMembership(schoolId)` — real doc-ownership check.
- `schoolIdUnchanged()` (line 176): every Structure update requires `request.resource.data.schoolId == resource.data.schoolId` — no client re-parenting path.
- ~40 collections enforce `request.resource.data.schoolId == resource.data.schoolId` on write.
- Existing rules-test coverage (`functions/test/firestore.rules.test.cjs`, static read):
  - `adminA` (schoolA) **denied** writing `schools/schoolB`, `school_admin_invitations`, `portal_domains` for another tenant (lines 482–513).
  - `adminA` **denied** reading owner-only `invoices`, `super_admin_audit_logs`, owner notification feed (lines 522–534+).
  - "another school never reaches this collection" tests at lines 750, 858, 915.
  - `adminA` **denied** moving `school_contacts` to `schoolB` via update (line 465).
- **These tests exist but were NOT executed this pass** — JDK 21 requirement blocks the emulator. Status: **BLOCKED** for live proof; **PASS (static)** for rule presence.

**Disabled/removed School Admin:** `AuthBloc` + top-level router `redirect` re-derive `AuthAuthenticated` on every navigation and every app start; `institution_memberships` status `active` is checked by `isActiveMembership`. Route access is lost on the next redirect evaluation. **PASS (static / by construction)** — live proof BLOCKED (needs emulator + seeded disabled user).

---

## 5. TEST COMMANDS — EXACT RESULTS

| Command | Result |
|---|---|
| `flutter analyze` | **273 issues**, of which **4 errors** — all **pre-existing, none in School Admin module**: `lib/features/super_admin/presentation/pages/platform_health_screen.dart:124` (untracked WIP file, `expected_token`); `test/features/attendance_hub/data/attendance_offline_queue_test.dart:442,469` (`FirebaseException` undefined); `test/features/structure/domain/services/structure_setup_engine_extended_test.dart:246` (`TimetableStatus.active` undefined). Remainder are `info`/`warning` lints. |
| Focused School Admin unit/widget/BLoC tests: `router_integrations_gate_test`, `router_must_change_password_gate_test`, `router_owner_staff_gate_test`, `router_super_admin_gate_test`, `institution_access_guard_test`, `add_staff_wizard_controller_test`, `create_staff_account_test`, `staff_role_assignment_test`, `admin_quick_add_sheet_test` | **PASS — 48/48** (`All tests passed!`). Covers: super-admin/owner route gates, must-change-password gate, integrations role gate, institution access guard, Add Staff wizard validation + idempotency-key reuse + local reject-before-repository, staff-role assignment scope/validity, admin quick-add server-verification (Add Staff hidden for Deputy Head). |
| `flutter test test/features/structure/` | **282 pass, 2 fail** — both failures **pre-existing & unrelated**: `structure_full_seed_test.dart` → `[core/no-app] No Firebase App` (needs emulator); `structure_setup_engine_extended_test.dart` → `TimetableStatus.active` compile error (same as analyze). Neither file modified in working tree. |
| `flutter test .../notification_deep_link_router_test.dart` | **PASS** — deep link stashed & replayed exactly once, not re-stashed after consume. |
| Firestore **rules** emulator tests (`npm run test:rules` in `functions/`) | **BLOCKED** — `Error: firebase-tools no longer supports Java version before 21. Please install a JDK at version 21 or above.` Installed: `openjdk 17.0.19`. |
| Storage rules tests (`test:storage-rules`) | **BLOCKED** — same JDK 21 requirement. |
| Functions emulator tests for School Admin flows (`test:create-staff-account:emulator`, `test:create-parent-access-code:emulator`) | **BLOCKED** — same JDK 21 requirement. |
| Flutter integration tests | **NOT IMPLEMENTED** — no `integration_test/` directory / no configured driver for School Admin web flows. |
| IndexedDB / browser offline automated tests | **NOT IMPLEMENTED** — no IndexedDB layer exists to test; no web offline test suite present. |
| `flutter build web --release` | **PASS** — `✓ Built build/web` (main.dart compiled for web in 96.3s). FFI/`dart:js` messages are `--wasm-dry-run` advisories for a future wasm target; JS (dart2js) build succeeded. |
| Browser smoke test (online / offline / reconnect) | **BLOCKED (manual)** — requires a running Chrome session against a live/emulated Firebase backend, which is gated by the same JDK 21 emulator blocker and was not performed in this non-interactive pass. Static analysis: offline mode on web has no queue/cache path (`WebNetworkInfo` always `true`), so "offline" simply surfaces Firestore's own network errors on affected screens. |

---

## 6. FINDINGS

### CRITICAL
*None.*

### HIGH

- **H-1 — `/staff/admin` and several admin sub-routes have no route-level role `redirect`.**
  `/staff/admin` (`AdminDashboardScreen`) and sub-routes `approvals`, `parents`, `users`, `broadcast-sms`, `config` rely only on the top-level `AuthAuthenticated` gate + `StaffShell` nav chrome, not an explicit `adminConsoleRoles` check like their siblings (`data-management`, `integrations`, `add-staff`, `structure`) have. A non-admin staff account (e.g. a teacher) that deep-links to `/staff/admin/config` or `/staff/admin/users` is not redirected away by the router. Actual data exposure is bounded by Firestore rules and Cloud Function role checks (writes are server-verified), but the console UI and any permissive reads render. **File:** `lib/app/router.dart:2312` (route decl) and children 2365–2420. **Recommendation:** add the same `redirect` guard used at line 2317/2426 (`auth.user.roles.any(UserRoleDisplay.adminConsoleRoles.contains)`) to `/staff/admin` itself or the shell segment. *Not fixed — verification pass only.*

- **H-2 — Firestore rules / Functions emulator suites could not run (JDK 21).**
  Same-school isolation, disabled-user lockout, parent-link server-verification, and staff-creation authorization all have **existing automated tests** (`firestore.rules.test.cjs` ~3185 lines, `create_staff_account.emulator.test.cjs`, `create_parent_access_code.emulator.test.cjs`, `staff_roles.test.cjs`) that were **not executed**. `firebase-tools` requires JDK ≥ 21; the machine has JDK 17. **Recommendation:** install a JDK 21+ (e.g. `brew install openjdk@21`) and re-run `npm --prefix functions run test:rules`, `test:create-staff-account:emulator`, `test:create-parent-access-code:emulator`, `test:storage-rules`. Blocker is environmental, not code.

### MEDIUM

- **M-1 — Two pre-existing compile errors in test files break `flutter test` for those files.**
  `test/features/attendance_hub/data/attendance_offline_queue_test.dart` (`FirebaseException` not imported) and `test/features/structure/domain/services/structure_setup_engine_extended_test.dart` (`TimetableStatus.active` removed). Not School-Admin-specific but they sit in the structure test tree and will show as failures in any broad run. *Pre-existing; not touched.*

- **M-2 — Untracked WIP file `lib/features/super_admin/presentation/pages/platform_health_screen.dart` has a syntax error** (`expected ')'` at 124:12), failing analyze. Belongs to Victor's in-progress platform-health work (`?? lib/features/platform_health/`, `?? functions/platform_health*.js`). *Pre-existing; not touched.*

### LOW

- **L-1 — Firestore web SDK persistence is not explicitly configured.** No `persistenceEnabled` / `enablePersistence()` in `lib/`. If ever enabled, it would create an IndexedDB store outside the app's control that this checklist's Section F items would then genuinely apply to (encryption, account-switch clearing, cross-tenant reads). Currently moot. **Recommendation:** if web offline is ever wanted, do it deliberately with tenant-scoped clearing on logout, not by flipping SDK persistence on globally.

- **L-2 — `StaffShell` uses `context.read` for role checks without a listen/rebuild on role-session change.** Cosmetic nav-chrome only; route guards are the enforcement boundary. Low impact.

---

## 7. CHANGED FILES

**None.** This pass created only:
- `docs/test-reports/school_admin_web_indexeddb_offline_test_report.md` (this report)
- `build/web/**` (standard build output, git-ignored)
- scratchpad-only working files

No source file, rule, function, config, test, commit, tag, push, or deployment was made.

---

## 8. FINAL GIT STATUS

`git status --porcelain` at end of pass = identical to start of pass. Pre-existing modifications (all Victor's in-progress Super Admin / platform-health / functions work, untouched by me):

```
 M firestore.indexes.json
 M firestore.rules
 M functions/appointments.js
 M functions/communication_campaigns.js
 M functions/exam_factory_reminders.js
 M functions/index.js
 M functions/notifications.js
 M functions/package.json
 M functions/report_card_release.js
 M functions/test/firestore.rules.test.cjs
 M lib/app/router.dart
 M lib/features/auth/presentation/bloc/auth_bloc.dart
 M lib/features/super_admin/**  (many)
 M lib/main.dart
 M public_functions/**  (several)
MM test/features/super_admin/plan_editor_page_test.dart
?? functions/platform_health*.js, functions/test/platform_health*.cjs
?? lib/features/platform_health/
```

Stash `stash@{0}: WIP on structure-module` — left untouched (per project rule: never `git stash`/pop).

---

## 9. CONFIRMATION

I confirm that during this verification pass:
- No unrelated code was modified.
- No commit was created.
- No push was performed.
- No deployment (`firebase deploy`, hosting, functions, rules) was performed.
- No Firestore or Storage rule was weakened.
- No browser caching / IndexedDB / persistence was added to make any test pass.
- No offline or IndexedDB result was fabricated. Where a workflow has no safe web persistence, it is marked **NOT IMPLEMENTED** or **UNSAFE TO CACHE** as appropriate.

---

## APPENDIX A — SECTION-BY-SECTION CHECKLIST STATUS

### A. Access, routes, tenant safety
| Item | Status |
|---|---|
| School Admin signs in → own school dashboard only | PASS (static: router redirect + `isSameSchool`; live BLOCKED — emulator) |
| Super Admin cannot use School Admin tenant routes | PASS — `router_super_admin_gate_test` + separate ShellRoute; superAdmin exempt from tenant pipeline by design |
| Teacher/Parent/Student/Bursar/Nurse/staff denied School-Admin-only routes | **PARTIAL / FAIL** — guarded routes (data-management, integrations, add-staff, structure) PASS; `/staff/admin`, `/staff/admin/{config,users,parents,approvals,broadcast-sms}` have **no route guard** — see Finding H-1. Writes still server-verified. |
| Cannot read/write another institution by changing route/Firestore IDs | PASS (static — `firestore.rules` `isSameSchool` + `schoolIdUnchanged`); live BLOCKED |
| Cannot cross-tenant via IndexedDB records | N/A — NOT IMPLEMENTED (no IndexedDB on web) |
| Disabled/removed School Admin loses route + backend + cache access | PASS (static — redirect re-derives auth every nav; `isActiveMembership` status check); cache portion N/A; live BLOCKED |
| Loading / empty / error / permission-denied states on all screens | NOT VERIFIED this pass (needs running browser) — BLOCKED (manual) |
| Router guards tested | PASS — `test/app/router_*_gate_test.dart` (4 files, 48 assertions green) — but coverage gap at `/staff/admin` root (H-1) |
| Firestore rules prove same-school isolation | PASS (static — rule text + existing `.test.cjs` cases); **BLOCKED** for live execution (JDK 21) |

### B. School setup & structure
| Item | Status |
|---|---|
| School profile/settings load & update | PASS — `institution_tab_test.dart` green (dispatches `UpdateInstitutionProfileRequested` for authenticated school, renders real saved data) |
| Campus setup | PASS (static — `structure_*` suite 282 green; covers campuses/levels/years/terms/classes/streams/subjects) |
| Academic year & term setup | PASS — structure suite |
| Classes/streams/subjects create/edit/archive/restore | PASS (static — structure suite); archive/restore where supported |
| Duplicate names/codes rejected | PASS (static — `structure_validation_service_test`, `structure_integrity_validator_test` green) |
| Staff assignment to classes/subjects tenant-scoped | PASS — `staff_role_assignment_test` (scope rejects other class/stream/subject/year/term) |
| Changes audited where required | PARTIAL — Add Staff wizard audits with idempotency-key reuse (`add_staff_wizard_controller_test` green); broader structure-change audit not verified this pass |
| Structure refreshes after reconnect | N/A on web (no offline state); mobile path not in web scope — NOT IMPLEMENTED (web) |

### C. Learners, enrolment, parent links
| Item | Status |
|---|---|
| Student creation/enrolment | NOT VERIFIED this pass (no focused run; `structure_full_seed` blocked on Firebase app) — BLOCKED |
| Existing-student search & duplicate prevention | NOT VERIFIED this pass — BLOCKED (needs emulator/browser) |
| Class/stream placement | PARTIAL (static — structure suite covers structure side) |
| Transfer/archive/restore | NOT VERIFIED this pass — BLOCKED |
| QR/identity setup via authorized flow only | PASS (static — `firestore.rules` `schools/{s}/credentials` owner/authorized-only; rules-test lines ~261 present, not executed) — BLOCKED for live |
| Parent access code / initial link | PASS (static — `create_parent_access_code.emulator.test.cjs` exists) — BLOCKED (JDK 21) |
| ≤ 2 parents per learner | NOT VERIFIED this pass — enforcement is server-side; test not run — BLOCKED |
| Only School Admin can reallocate/replace/remove existing parent-learner link | PASS (static — `guardian_contact_resolution` architecture: reallocation is Cloud-Function + Admin-SDK only, no client rule path) — BLOCKED for live |
| Registrar can only create initial links, not reallocate | PASS (static — same) — BLOCKED for live |
| Parent-link changes server-verified & audited | PASS (static) — BLOCKED for live |
| Parent/student private records never leak via IndexedDB | N/A — NOT IMPLEMENTED (no IndexedDB; `ParentCacheDataSourceWeb` is all no-ops, documented online-only) |

### D. Staff, users, permissions
| Item | Status |
|---|---|
| Invite staff only for allowed actions | PASS — `create_staff_account_test.dart` + `admin_quick_add_sheet_test` (Add Staff hidden for Deputy Head) green |
| Correct role assignment | PASS — `staff_role_assignment_test`, `create_staff_account_test` green |
| Role change & removal server-verified | PASS (static — `createStaffAccount`/role CFs verify caller; `staff_roles.test.cjs` exists) — live BLOCKED |
| Staff cannot self-promote via client/Firestore | PASS (static — `firestore.rules` users-collection write restrictions; role fields not client-writable) — live BLOCKED |
| Invited user gets access only to correct school | PASS (static — `school_admin_invitations` owner-write-only, never client-readable; rules-test lines ~508) — live BLOCKED |
| Removed staff session/cache invalidated | PASS (static — auth re-derive on nav); cache N/A on web |
| User-management search/filter/status actions | NOT VERIFIED this pass (needs browser) — BLOCKED (manual) |
| Permission changes audited | PARTIAL (static — wizard audits; role-override audit not verified) |

### E. Dashboard & cross-role handoffs
| Item | Status |
|---|---|
| Dashboard metrics use real school-scoped data | PASS (static — `AdminDashboardBloc` + `get_admin_dashboard_stats` usecase; `institution_tab_test` proves "real saved data, not sample copy") — live counts BLOCKED |
| Quick actions — no dead buttons | PARTIAL — `admin_quick_add_sheet_test` green for the quick-add sheet; full dashboard button sweep needs browser — BLOCKED (manual) |
| Handoff to DOS/Teachers/Bursar/Nurse/Matron/Gatekeeper/Parent | PASS (static — cross-role routes exist: `/staff/bursar`, `/staff/headteacher/report-approvals` with schoolAdmin in permitted set) |
| School Admin sees only authorized summaries, not protected clinical/financial detail | PASS (static — `canAccessBoardingGender` / owner-only billing / clinical collections rule-gated; `adminA` denied `invoices`) — live BLOCKED |
| Notifications/deep links authorized before opening | PASS — `notification_deep_link_router_test` green (stash + replay-once); deep-link role/tenant checks in router redirects |

### F. IndexedDB / Web offline
**Every item: NOT IMPLEMENTED** — no IndexedDB database, no web offline cache, no web write queue exists for School Admin (or any module). `WebNetworkInfo.isConnected` always `true`; all `*_local_data_source_web.dart` are Firestore pass-throughs / no-ops with documenting header comments. Nothing to document, scope, encrypt, clear, queue, retry, or reconcile. This is the safe state for the sensitive domains listed (medical, payment, permissions, parent reassignment, staff removal, identity): none are cached or queued offline on web.

Specifically:
| Item | Status |
|---|---|
| DB name/version/object stores documented | NOT IMPLEMENTED — no DB |
| Records scoped by institution + user ID | NOT IMPLEMENTED — no records |
| Account switch clears IndexedDB | NOT IMPLEMENTED — nothing to clear (N/A) |
| Logout clears IndexedDB/queues/session | NOT IMPLEMENTED for IndexedDB (none). Secure session storage is framework-managed. |
| School B admin cannot read School A IndexedDB | NOT IMPLEMENTED — no IndexedDB (no exposure) |
| Same-school other account cannot read another's cache | NOT IMPLEMENTED — no cache |
| Cache encrypted or sensitive data not stored | Sensitive data **is not stored** on web — compliant by omission |
| Medical/payment/permission/parent/staff/identity not finalized offline | PASS (by construction — no offline finalization path on web) |
| Offline read only for approved cached records | NOT IMPLEMENTED — no offline read |
| Offline write queue only for safe actions | NOT IMPLEMENTED — no queue |
| Queue record has instId/userId/action/entity/time/idempotency key | NOT IMPLEMENTED — no queue (note: Add Staff *does* use an idempotency key on the online path — verified green) |
| Retryable failure queues once / syncs once | NOT IMPLEMENTED (web); mobile-only |
| Duplicate retry no duplicate entity | PASS for online Add Staff path (`add_staff_wizard_controller_test` — retry reuses idempotencyKey, no duplicate account); queue N/A on web |
| Denied/stale queued actions blocked & evicted | NOT IMPLEMENTED — no queue |
| Sync conflict UI | NOT IMPLEMENTED — no sync |
| Refresh while offline preserves only approved state | NOT IMPLEMENTED — no persisted state on web |
| Refresh after logout doesn't restore old data | PASS (by construction — nothing persisted to restore) |
| App Check / auth failure doesn't expose cached records | PASS (by construction — no cached records) |
| Offline badge/status visible & accurate | NOT IMPLEMENTED / FAIL — `WebNetworkInfo` always reports online, so no accurate offline badge on web |
| Reconnect refreshes authoritative data / removes revoked items | N/A — always "online"; every read is already live from Firestore |

### G. Notifications for School Admin
| Item | Status |
|---|---|
| Only school-scoped, role-authorized notifications | PASS (static — `NotificationRemoteDataSource` queries by `schoolId` + `recipientUserId`; `firestore.rules` notification collection gated) — live BLOCKED |
| Cannot see Super Admin owner notifications | PASS — `firestore.rules.test.cjs` "super_admin_notifications: owner-only feed, per-owner isolation" (`adminA` denied); + `OwnerNotificationOfflineStore` is owner-only |
| School Admin notification cache separate from Super Admin | PASS (by construction — School Admin has no web notification cache at all; Super Admin's is uid-namespaced localStorage) |
| Mark read/open/delete/clear online + safe queued offline | PARTIAL — online path via `NotificationLocalDataSourceWeb` → remote (works); **offline queued actions NOT IMPLEMENTED on web** (`getPendingStateChanges` returns `[]`) |
| Push payloads data-only & redacted | PASS (static — `NotificationPushPayload` / `notification_sender.dart` build data-only payloads; `notification_push_payload.dart`) |
| Deep links role- & tenant-checked | PASS — `notification_deep_link_router_test` green + router redirect guards |
| Preferences / quiet hours without muting emergency/security | PASS (static — `notification_delivery_policy.dart:217` `persistence == permanent` bypasses suppression) |

### H. Responsive & accessibility
| Item | Status |
|---|---|
| 390px / 768px / 1440px widths | NOT VERIFIED this pass (needs running browser) — BLOCKED (manual). Note: Bursar/Structure shells use width-adaptive chrome per prior audits; admin console shares `StaffShell`. |
| No overflow / clipped text / unusable tables / dup nav / dead actions | NOT VERIFIED — BLOCKED (manual); **known dead-route risk** at H-1 (guards, not layout) |
| Light & dark mode | NOT VERIFIED — BLOCKED (manual) |
| Text scaling / focus order / keyboard nav / semantic labels / contrast | NOT VERIFIED — BLOCKED (manual) |
| Compact small-font UI readable | NOT VERIFIED — BLOCKED (manual) |

### I. Required commands
See §5. Summary: `flutter analyze` ✅ (4 pre-existing errors, none in module); 48 focused School Admin tests ✅; structure suite 282✅/2 pre-existing fails; `flutter build web --release` ✅; all emulator suites (rules, storage, functions) **BLOCKED (JDK 21)**; integration & IndexedDB automated tests **NOT IMPLEMENTED**; browser smoke **BLOCKED (manual)**.

---

## APPENDIX B — ARCHITECTURE EVIDENCE (verbatim)

`lib/core/platform/isar_bootstrap.dart`:
> Only ever call this behind `if (!kIsWeb)` - the web/stub variants return null rather than opening anything.

`lib/core/network/network_info.dart` (`WebNetworkInfo`):
> callers of `isConnected` ... can safely assume "online" on web and let Firestore's own persistence/retry take over.
> `Future<bool> get isConnected => Future.value(true);`

`lib/features/student/data/datasources/student_local_data_source_web.dart`:
> No local database on web - reads straight from Firestore ... No caching, no offline behavior.

`lib/features/parent_offline/data/datasources/parent_cache_data_source_web.dart`:
> Parent Portal is online-only on web (no Isar, no IndexedDB persistence, no cached sensitive parent/learner records) - every call here is a deliberate no-op.

`lib/features/notifications/data/datasources/notification_local_data_source_web.dart`:
> No local database on web ... Nothing is ever pending, so getPendingStateChanges is always empty.

`lib/features/structure/data/datasources/structure_local_data_source_web.dart`:
> No local database on web ... on web every get* returns empty and every cache* is a no-op with no behavior change.
