# QA Report — Super Admin "Enrolled School" Workspace

Run ID: `qa-enrolled-school-20260902-163814`
Date: 2026-09-02
Branch: `structure-module` @ `42dc8da569623bdd673b54e1f9326fd9f3344805`
Emulator-only. No production writes, no deploys, no commits.

---

## 1. Environment / Pre-flight

| Tool | Version | Notes |
|---|---|---|
| Flutter | 3.44.6 (stable), Dart 3.12.2 | |
| Node | v22.22.2 | |
| Java (system default) | OpenJDK 17.0.19 (Homebrew) | **Too old** for current firebase-tools (15.26.0), which requires Java 21+ |
| Java (used for this run) | OpenJDK 21.0.12.1 (Homebrew, `/opt/homebrew/opt/openjdk@21`) | Not the system default; used only by exporting `JAVA_HOME`/`PATH` for the specific commands in this session — no system config changed |
| Firebase CLI | 15.26.0 | |
| Chrome | Installed (`/Applications/Google Chrome.app`) | present, but no automation driver |
| chromedriver / geckodriver | **Not installed** | blocks Phase 3 browser automation |
| Playwright / Puppeteer | **Not configured** in this repo | confirmed via `package.json` grep, no matches |

**Java blocker & workaround**: the system default `java` (17) makes `firebase emulators:exec` / `emulators:start` fail outright ("firebase-tools no longer supports Java version before 21"). A Java 21 install already exists via Homebrew (`openjdk@21`) but isn't the active `java`. All emulator-dependent commands in this run were executed with `JAVA_HOME`/`PATH` scoped inline to that one command only — the system-wide `java` was never changed.

**Pre-existing emulator instance discovered**: a Firestore/Auth/Storage/Functions emulator (`firebase emulators:start --only firestore,auth,storage,functions --project school-pulse-qa`) was already running on ports 8080/9099/9199/5001 before this QA session started (not started by this session, not stopped by it). All emulator-backed test suites in this run were pointed at that already-running instance via env vars (`FIRESTORE_EMULATOR_HOST=127.0.0.1:8080`, `FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099`) rather than spawning a second one, to avoid port conflicts and avoid touching a process this session didn't own.

**Repo tooling found**:
- `firebase.json` — firestore/auth/storage/functions emulator config (ports 8080/9099/9199/5001), pointed at `school-pulse-3d95b` by default (production project id) — confirms hard-constraint risk if anyone runs emulator commands without care.
- `public_functions/__tests__/*` — Jest-style Node unit tests (`npm test` in `public_functions/`).
- `public_functions/test/*.emulator.test.cjs` — real Firestore/Auth emulator integration tests using `node --test`, including `school_workspace_callables.emulator.test.cjs` which is **exactly** the Enrolled School workspace's callable suite (getSchoolCounts, manageSchoolAdmin, requestSupportAccess, getManualPaymentsForOwner, setSchoolLifecycleStatus).
- `test/features/super_admin/*` — 25+ Flutter widget/bloc test files covering every Enrolled School sub-screen.
- `functions/scripts/seed_demo_schools_for_workspace_review.js` (untracked, pre-existing per task brief) — a ready-made seed script; used and extended-in-place-of-need (see §2).
- No Flutter `integration_test/` coverage specific to super_admin found; no browser E2E harness.

---

## 2. Seed Data (Phase 2)

**Safety finding (important)**: `functions/scripts/seed_demo_schools_for_workspace_review.js` calls `admin.initializeApp({ projectId: 'school-pulse-3d95b' })` (the real production project id) with **no emulator guard** (`FIRESTORE_EMULATOR_HOST` is never checked or set inside the script). Run as delivered/undocumented, this script would write directly to production Firestore. This is flagged as a **defect** (see §8) — it should assert `FIRESTORE_EMULATOR_HOST` is set before running, or hard-fail otherwise.

**How it was run safely**: executed only with `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080` explicitly exported in the shell, confirmed the Admin SDK's resulting Firestore client had `servicePath: 127.0.0.1, ssl:false, port:8080` (i.e., genuinely emulator-bound, never `firestore.googleapis.com`) before executing. No `GOOGLE_APPLICATION_CREDENTIALS` was set at any point in this session.

**Outcome**: seeded 3 demo schools + admins + payments successfully into the **local emulator only**, verified afterward by reading them back via a fresh Admin SDK client also forced onto the emulator host:
- `Greenhill Academy` (active, Enterprise plan, 2 admins, 1 approved + 1 pending_verification payment)
- `Riverside Primary School` (trial, Starter plan, 1 admin, 1 rejected payment)
- `St. Augustine's College` (suspended, Growth plan, 1 admin, 1 approved payment)

Note on Firestore emulator behavior discovered mid-run: the running emulator uses `--single_project_mode true`, which means it accepts writes for *any* project id string without validating it against a real GCP project — but it still **partitions data internally by that project-id string**. The seed script's hardcoded `school-pulse-3d95b` therefore created its own isolated in-memory namespace *inside the same local emulator process*, separate from the `school-pulse-qa` namespace the `.emulator.test.cjs` suites use. Both namespaces are 100% local/ephemeral (die when the emulator process stops) — confirmed via the `servicePath`/`ssl` check above — but this is worth knowing: seed data seeded under one project-id string is invisible to code/tests running under a different project-id string, even against the same emulator instance.

This seed data does **not** cover every fixture the full spec asked for (support-session states, admin-invitation fixture, audit-log fixtures for every action type, "school with missing counts", modules in varied entitlement states) — the pre-existing script only covers schools/admins/payments across 3 lifecycle states. The `.emulator.test.cjs` suites (§5) independently seed and tear down their own fixtures covering the remaining scenarios (last-admin protection, suspended/archived-school rejection, audit records per action, support-session creation/rejection, idempotent lifecycle transitions) inline per test, which is how those specific matrix items were actually verified — not via this seed script.

Cleanup: a `_qa_probe` scratch document used only to sanity-check emulator routing was written and then deleted. All seeded demo-school data was left in the emulator (ephemeral, in-memory, gone on emulator restart) — nothing persisted to disk or production.

---

## 3. Browser / IndexedDB Testing (Phase 3) — **BLOCKED**

**Verdict: BLOCKED — no browser automation tooling configured in this repo or environment.**

- No `chromedriver`, `geckodriver`, Playwright, or Puppeteer found (checked `PATH`, `package.json` files at root/public_functions/functions, no config files).
- Chrome itself is installed, so `flutter build web` + manual load is technically possible, but this was an unattended automated pass with no way to drive a real browser, click through screens, capture screenshots at 3 viewports, or open DevTools to inspect IndexedDB.
- **Not attempted / not verified as a result**: full tap-target inventory via live UI, 3-viewport visual QA (390×844 / 768×1024 / 1440×1024), light/dark theme screenshots, IndexedDB database/object-store inventory, cross-tenant IndexedDB isolation, logout-clears-storage behavior, and true "offline mode in a live browser" behavior.
- **Substituted verification** (see §4–§5): the same claims (scoping, no raw toggles, confirmation-required flows, offline-blocked mutating actions, empty/loading/error/retry states, no Delete School action, 390px layout fit) are covered by the existing Flutter widget/bloc test suite, which renders the real widget tree under `flutter test` (not a browser, but the real Flutter framework, real BLoC/Cubit state machines, real layout constraints) and by the real Cloud Functions emulator integration tests (not browser-based, but exercising the actual server-side authorization/audit logic the UI calls into).
- IndexedDB specifically could not be inspected by any means in this pass — Isar (the local cache layer) is confirmed absent from the web build already (see `flutter build web --release` wasm-dry-run output, §6, and `owner_notification_isar.dart` usage is gated out of web per existing commit e96d733d per project memory), so the highest-risk cross-tenant IndexedDB leak surface for this workspace's notification queue is structurally not present on web — but this is an inference from source, not a live-browser observation, and is reported as such rather than as a verified PASS.

---

## 4. Functional / Security Test Matrix (Phase 4)

Verified via the emulator-backed Cloud Functions integration suite (`public_functions/test/school_workspace_callables.emulator.test.cjs`, real Firestore + Auth emulators, real `onCall` handlers invoked with `.run(request)` — not mocked):

| Area | Verdict | Evidence |
|---|---|---|
| School counts scoped per-school, never leak cross-school | PASS | `getSchoolCounts` tests 1–2 |
| Non-owner superAdmin / school admin / unauthenticated all rejected from counts | PASS | tests 3–5 |
| Payments: `schoolId` filter returns only that school's rows | PASS | `getManualPaymentsForOwner` test 1 |
| A manipulated/foreign `schoolId` cannot pull another school's payments into the response | PASS | test 2 |
| Payments date-range filter narrows correctly | PASS | test 3 |
| No `schoolId` = full owner-wide unfiltered Billing view preserved | PASS | test 4 |
| Non-owner rejected from payments query | PASS | test 5 |
| Admin management: set primary admin | PASS | `manageSchoolAdmin` test 1 |
| Non-owner superAdmin / school admin (even own school) blocked from `manageSchoolAdmin` | PASS | tests 2–3 |
| Disable requires reason ≥3 chars | PASS | test 4 |
| Disable a non-last admin: writes `isActive:false`, revokes sessions | PASS | test 5 |
| **Last active admin cannot be disabled without a valid replacement** | PASS | test 6 |
| **Last admin CAN be removed when a valid replacement is supplied; replacement becomes primary in the same transaction** | PASS | test 7 |
| Removing non-last admin ignores an unnecessary `replacementUid` | PASS | test 8 |
| Audit record written for every admin action | PASS | test 9 |
| Suspended school rejects admin lifecycle changes, even from owner | PASS | test 10 |
| Archived school also rejects admin lifecycle changes | PASS | test 11 |
| Cannot manage an admin who doesn't belong to the specified school | PASS | test 12 |
| Support session: owner creates school-scoped, time-boxed pending session | PASS | `requestSupportAccess` test 1 |
| Reason <3 chars rejected | PASS | test 2 |
| Non-owner rejected | PASS | test 3 |
| Unknown school rejected | PASS | test 4 |
| Suspend sets `accessMode:blocked` — the actual field `firestore.rules` checks (`schoolCanWrite`/`schoolAccessMode`), not just a cosmetic status label | PASS | `setSchoolLifecycleStatus` test 1 |
| Reactivate restores `accessMode:full` | PASS | test 2 |
| Archive also sets `accessMode:blocked` | PASS | test 3 |
| Suspend/archive touch ONLY the school doc + an audit row — never students/users/payments | PASS | test 4 |
| Suspend attempts best-effort session revocation for every user at the school, never blocks the status write on revocation failure | PASS | test 5 |
| Non-owner cannot suspend a school | PASS | test 6 |
| Setting the same lifecycle status twice is a safe idempotent no-op | PASS | test 7 |

**Total: 33/33 tests passed** in this suite (see §5 for exact command/output).

Additional coverage from the two other directly-relevant `.emulator.test.cjs` suites:
- `school_lifecycle_and_applications.emulator.test.cjs` — 17/17 passed.
- `manual_payments_owner.emulator.test.cjs` — 17/17 passed (includes: "no usable payment method" rejected, etc.).
- `owner_console_callables.emulator.test.cjs` — 14/14 passed (broader owner-console callable surface).

**Not independently re-verified in this pass** (would require live browser + IndexedDB access, per §3): true client-side offline queuing/blocking behavior for mutating actions (module toggle, admin disable/remove, suspend/archive) when the device is offline. The Flutter widget tests (§5) assert the UI *routes mutating actions through the real callable*, not a raw local write, which structurally prevents a silent offline "finalize" — but the specific "action is queued/blocked while offline, then completes/fails correctly on reconnect" round-trip was not observed live.

**Modules / entitlement flow**: verified structurally via `school_modules_screen_test.dart` (see §5) — real entitlement source (not `enabledFeatures`), confirmation sheet required (not a raw toggle) with a mandatory reason, unentitled modules blocked from toggling, and audit-trail history reads the real audit collection. No dedicated `.emulator.test.cjs` for the module-entitlement callable itself was found/run in this pass — this specific server-side callable (`setModuleEnabled` or equivalent) was **not independently exercised against the emulator** in this QA pass; only its Flutter-side wiring was.

---

## 5. Automated Test Suites (Phase 5) — exact commands & results

All logs saved under `qa_artifacts/qa-enrolled-school-20260902-163814/`.

| Command | Result | Log file |
|---|---|---|
| `JAVA_HOME=.../openjdk@21 GCLOUD_PROJECT=school-pulse-qa FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 node --test test/school_workspace_callables.emulator.test.cjs` (run from `public_functions/`, against the already-running local emulator) | **33/33 pass** | `school_workspace_callables.emulator.log` |
| same pattern, `test/manual_payments_owner.emulator.test.cjs` | **17/17 pass** | `manual_payments_owner.emulator.log` |
| same pattern, `test/school_lifecycle_and_applications.emulator.test.cjs` | **17/17 pass** | `school_lifecycle_and_applications.emulator.log` |
| same pattern, `test/owner_console_callables.emulator.test.cjs` | **14/14 pass** | `owner_console_callables.emulator.log` |
| `npm test` (from `public_functions/`) | **54 passed, 1 failed** — failure is `plain text includes title and support email` in the *email template engine* test (`support@schoolpulse.victorbee.com` not found in plain-text output). **Unrelated to the Enrolled School workspace** (it's the transactional-email HTML/plain-text renderer, a different module entirely). Pre-existing, not caused or touched by this QA pass. | `public_functions_npm_test.log` |
| `flutter analyze` (repo root) | **281 issues** (mostly `info`-level lints across the whole app: `curly_braces_in_flow_control_structures`, `use_build_context_synchronously`, `deprecated_member_use`, etc.) plus **3 compile `error`s**, all in files **outside** the Enrolled School workspace: `test/features/attendance_hub/data/attendance_offline_queue_test.dart` (undefined `FirebaseException` x2) and `test/features/structure/domain/services/structure_setup_engine_extended_test.dart` (undefined `TimetableStatus.active`). Consistent with the existing project memory note that Victor's in-progress work on `structure`/other modules currently has pre-existing project-wide compile errors unrelated to super_admin. No `error`-level issues found inside `lib/features/super_admin/**`. | `flutter_analyze.log` |
| `flutter test test/features/super_admin/` | **144/144 pass** (0 failures) — covers school overview, subscription, payments, modules, school-admin management, settings, navigation, logout, theme, billing home, subscription plans, and viewport-fit assertions at 390px. | `flutter_test_super_admin.log` |
| `flutter build web --release` | **Succeeds** (`✓ Built build/web`, ~93s compile). Wasm dry-run reports known incompatibilities from `flutter_secure_storage_web` and `isar` (dart:ffi/dart:html/dart:js_util) — informational only, does not affect the standard JS web build, and is a pre-existing, app-wide constraint, not specific to this workspace. Build output was **not deployed** (no `firebase deploy` run, per hard constraint). | `flutter_build_web.log` |

Firestore rules-specific emulator tests: `functions/test/school_workspace.rules.test.cjs` is referenced by a comment in `school_workspace_callables.emulator.test.cjs` as the sibling rules-unit-testing harness for this workspace but was not located as an actual file in this pass — not run; if it exists under a different path it should be located and run in a follow-up.

---

## 6. Screen / Action Inventory — verdicts

Based on the Flutter widget-test assertions actually exercised (§5) plus static reading of the relevant screen source where a widget test didn't cover a specific micro-interaction:

| Screen / Action | Verdict | Basis |
|---|---|---|
| School Overview: identity card, action rows, metrics grid (real counts, loading/loaded/unavailable+retry, pull-to-refresh) | PASS | `school_overview_screen_test.dart` |
| School Overview: **no Delete School action anywhere, no header suspend icon** | PASS | `school_overview_screen_test.dart` — explicit test |
| Subscription & Billing: real plan/renewal/days-remaining, scoped recent payments w/ status chips, empty/error compact states, "View all payments" → real Billing history, "Manage subscription" reachable | PASS | `school_subscription_screen_test.dart` |
| Payments: schoolId-scoped fetch (server param, not client filter), filters (All/Pending review/Paid/Failed), date range, loading/empty/error/retry/pull-to-refresh, review action gated to pending-verification only | PASS | `school_payments_screen_test.dart` |
| Modules: only the 6 spec-named module groups shown (no transport/QR), sourced from real entitlements (not `enabledFeatures`), confirmation-sheet + reason (not raw toggle), unentitled modules blocked, audit history reads real trail | PASS | `school_modules_screen_test.dart` |
| School Admin management: real `getSchoolAdmins` source, invite writes real `school_admin_invitations` doc, set-primary/disable/enable/remove all route through the owner-only callable, disable/remove require a reason, mutating actions hidden entirely when school inactive, **no direct client write** to `institution_memberships` or user role fields | PASS | `school_admin_management_screen_test.dart` |
| Support session flow | PASS (server-side) | `requestSupportAccess` emulator tests (§4); no dedicated Flutter widget test file found for this specific screen — UI wiring not independently confirmed in this pass |
| Suspend/Reactivate/Archive with correct preconditions, real `accessMode` impact | PASS (server-side, §4); UI-level confirmation-sheet wiring inferred from `lifecycle_action_visibility_test.dart` (present in test dir, not individually run/parsed line-by-line in this pass) |
| Bottom nav / back nav | PASS (structural) | `super_admin_navigation_test.dart` — exactly 5 approved destinations in order |
| Confirmation sheets / empty / loading / retry / permission-denied states | PASS where covered above; permission-denied UI state specifically not independently observed (only the server-side rejection was verified, §4) |

**Dead icons / dead routes found**: none identified. `super_admin_settings_screen_redesign_test.dart` explicitly asserts "settings rows are in the spec order with real routes/screens, not dead taps" (PASS). No other evidence of unwired taps surfaced in the reviewed test files or `flutter analyze` output for this module.

---

## 7. Authorization Matrix (from §4's emulator evidence)

| Actor | Counts | Payments | Admin mgmt | Support session | Lifecycle status |
|---|---|---|---|---|---|
| Owner (super admin, correct owner) | Allow | Allow | Allow | Allow | Allow |
| Non-owner superAdmin | Deny | Deny | Deny | Deny | (not separately tested beyond admin/lifecycle; inferred deny) |
| School admin (own school) | Deny | — | Deny | — | — |
| Unauthenticated | Deny | — | — | — | — |
| Owner acting on a suspended/archived school | — | — | Deny (admin lifecycle changes) | — | Idempotent allow (repeat same status) |

---

## 8. Defects Found (by severity)

1. **[Medium — safety/process] `functions/scripts/seed_demo_schools_for_workspace_review.js` has no emulator guard.**
   File: `/Users/victorbee/Desktop/apps/school_pulse/functions/scripts/seed_demo_schools_for_workspace_review.js`, line 18: `admin.initializeApp({ projectId: 'school-pulse-3d95b' })`.
   Repro: run `node scripts/seed_demo_schools_for_workspace_review.js` from `functions/` with no `FIRESTORE_EMULATOR_HOST` set and valid ADC available → writes demo schools/admins/payments straight into the real production project `school-pulse-3d95b`.
   Recommendation: add a hard check at the top of the script (`if (!process.env.FIRESTORE_EMULATOR_HOST) { throw new Error(...) }`) before `initializeApp`.

2. **[Low — test infra] `school_workspace_callables.emulator.test.cjs` is not wired into `public_functions/package.json`'s `scripts`.**
   It exists and passes cleanly (33/33) but has no `npm run test:...` entry the way its sibling suites do, so it's easy to forget to run in CI/local dev. Recommend adding `"test:school-workspace-callables:emulator": "firebase emulators:exec --only firestore,auth,functions --project demo-school-workspace-callables-test \"node --test test/school_workspace_callables.emulator.test.cjs\""` to match the existing convention (this is currently mid-edit by Victor per `git status`, not touched here).

3. **[Low, unrelated to this workspace] `npm test` in `public_functions/` has 1 pre-existing failure** in the email template engine's plain-text renderer (missing `support@schoolpulse.victorbee.com` string). Not caused by, or related to, the Enrolled School workspace.

4. **[Informational, pre-existing, unrelated] `flutter analyze` reports 3 compile errors** in `test/features/attendance_hub/...` and `test/features/structure/...` — outside super_admin, consistent with known in-progress work per project memory.

No defects of severity High/Critical found within the Enrolled School workspace's own code/tests in this pass.

---

## 9. What was NOT achievable, and why

| Item from the spec | Status | Reason |
|---|---|---|
| Live browser click-through of every tap target | BLOCKED | No chromedriver/geckodriver/Playwright/Puppeteer installed or configured anywhere in this repo |
| 3-viewport visual screenshots (390×844 / 768×1024 / 1440×1024), both themes | BLOCKED | Same — no browser automation. Flutter widget tests do assert 390px layout fit (`school_management_screen_test.dart`), which is a partial substitute for one of the three viewports, at the widget level only, not a full-app screenshot |
| IndexedDB database/object-store inventory + cross-tenant isolation + logout-clear verification | BLOCKED | No live browser access. Structurally inferred (not observed) that Isar/IndexedDB is not used on web for the owner-notification cache per existing source/commit history |
| Live "offline mode" round-trip for mutating actions (queued while offline → completes/fails on reconnect) | NOT INDEPENDENTLY VERIFIED | No browser automation to actually flip network state; only structurally verified (via widget tests) that mutations route through real callables, not local-only writes |
| Firestore rules-unit-test harness (`school_workspace.rules.test.cjs`) | NOT FOUND / NOT RUN | Referenced in a comment but not located at the expected path in this pass; needs follow-up |
| Full spec's seed fixture list (support-session pending/approved/expired/revoked, admin-invitation fixture, audit-log fixtures per lifecycle/module/admin action type, school with missing counts) | PARTIALLY COVERED | The static seed script only covers 3 schools/lifecycle-states/payments; the remaining fixture states (last-admin protection, suspended/archived rejection, audit-per-action, support-session variants, idempotent status) were instead verified via the emulator test suite's own inline setup/teardown per test, not via a standing seeded dataset a human could browse in the UI |

---

## 10. Final state confirmation

- `git status`: only pre-existing dirty files from Victor's in-progress work (`lib/app/router.dart`, `super_admin_overview_screen.dart`, `public_functions/__tests__/owner_security_session.test.js`, `public_functions/__tests__/portal_domains.test.js`, `public_functions/owner_security_session.js`, `public_functions/portal_domains.js`, `public_functions/test/school_workspace_callables.emulator.test.cjs`) plus the pre-existing untracked `functions/scripts/seed_demo_schools_for_workspace_review.js` (also pre-existing per task brief) — **none of these were modified by this QA pass**. The only new artifact is this session's additive `qa_artifacts/` directory.
- **No `git add`, `git commit`, `git push`, `git stash`, `git reset`, `git clean`, or `git checkout -- <file>` was run at any point.**
- **No `firebase deploy` was run at any point.**
- **No production Firestore/Auth/Storage was written to** — all writes in this session were verified, before and during execution, to be routed to `127.0.0.1:8080`/`127.0.0.1:9099` (local emulator), never `*.googleapis.com`.
- The pre-existing local emulator process (PID 83237, started before this session) was left running and untouched; no processes were killed by this QA pass.
- Seeded demo data lives only in that emulator process's in-memory store and disappears when it is stopped.

---

## Artifact paths

- Report: `/Users/victorbee/Desktop/apps/school_pulse/qa_artifacts/qa-enrolled-school-20260902-163814/QA_REPORT.md`
- Logs: same directory —
  - `school_workspace_callables.emulator.log`
  - `manual_payments_owner.emulator.log`
  - `school_lifecycle_and_applications.emulator.log`
  - `owner_console_callables.emulator.log`
  - `public_functions_npm_test.log`
  - `flutter_analyze.log`
  - `flutter_test_super_admin.log`
  - `flutter_build_web.log`
