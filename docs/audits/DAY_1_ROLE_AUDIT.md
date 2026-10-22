# Day 1 — School Pulse Forensic Role Audit and Release Baseline

**Audit type:** Read-only, evidence-based. No source files, rules, dependencies, or git state were modified. The only file created by this audit is this document.

---

## 1. Executive Verdict

**Day 2 correction:** Day 1 undercounted the role total by one and carried a literal duplicate row in the §7 matrix ("Super Admin" and "Platform Owner (superAdmin)" both referring to the same enum value). The canonical `UserRole` enum in `lib/core/user_roles.dart` has 27 values, not 26. The duplicate matrix row has been removed and all "26" role-count references below corrected to 27; no other Day 1 findings were altered.

School Pulse has a genuinely large, mostly-real role/permission architecture (27 roles in `UserRole`, ~457 named routes, a 3597-line Firestore rules file, 1600+ passing Flutter tests) and is **not** a hollow prototype — most staff-facing modules trace end-to-end from route guard to BLoC to repository to Firestore/Functions. However, it is **not release-ready as a whole**:

- The tree currently contains a **compile error** (`lib/features/auth/login_flow/platform_owner_access_screen.dart`) that breaks 5 test files from loading at all — this is Victor's in-progress uncommitted work, not a regression I introduced, but it means the true health of those 5 suites is **UNVERIFIED**, not passing.
- A **security-relevant router-guard test is failing**: `router_owner_staff_gate_test.dart` — "redirect callback rejects a superAdmin-authenticated session found on /staff/login or any /staff/* route" — **Expected: true, Actual: false**. This needs same-day triage before Day 2 work proceeds, since it is exactly the Super Admin/staff-tenant separation invariant the brief calls out as core to the security model.
- **Firestore/Storage rules-emulator tests could not run** in this environment (Java 17 installed; firebase-tools requires Java 21+). This is an environment blocker, not a code defect, and it means the previously-reported 189-passing/42-failing rules baseline is **UNVERIFIED this session** — I did not reproduce it and am not claiming either number holds.
- Several operational roles (Librarian, Gate/Security, Matron/Patron, HR, Discipline, Games, Religion, Catering, Store/Inventory) have real feature directories and Firestore-backed data flows but **little to no automated test coverage** (0-3 test files each) — these are FUNCTIONAL-by-code-reading, not VERIFIED.
- Report-card engine logic tests (non-emulator) reproduced cleanly at **59/59 passing**, matching the prior baseline exactly — the one baseline number I could fully reproduce and confirm unchanged.
- `flutter analyze lib/` is clean of errors (0 errors, 10 warnings, 250 info = 260 total issues), and `flutter build web --release` succeeded.

**Bottom line:** the codebase is substantially built, not fake, but Day 1 surfaced one compile error and one security-relevant test regression that must be resolved before any further module work, plus a large swath of operational roles that are architecturally present but empirically unverified.

---

## 2. Audit Metadata

- **Audit date:** 2026-09-01
- **Branch:** `structure-module`
- **HEAD:** `f8d5eb7c7e6dc2c8983a1e16e0c1ed4077344d1e`
- **Upstream:** `origin/structure-module` (branch reported "up to date with origin/structure-module")
- **Repository status:** dirty working tree — extensive uncommitted modifications (Victor's in-progress work), left untouched throughout this audit. Full listing in §20/§21.
- **Stash count:** 8 stashes present at both start and end of audit, none touched:
  - `stash@{Sat Aug 29 01:30:07 2026}` — WIP on structure-module: c2c205c9 chore(finance): remove dead screens + form-primitive tests (audit area 8)
  - `stash@{Sat Aug 22 00:29:30 2026}` — WIP on worktree-agent-abf93cab36b9ce451: 73b1c0c6 fix(router): use dean shell navigation
  - `stash@{Fri Aug 21 19:04:17 2026}` — On structure-module: WIP reports_dashboard_screen.dart before agent-branch merge
  - `stash@{Wed Aug 19 12:24:22 2026}` — On worktree-agent-a92e9e63389aabdec: admissions polish worktree wip
  - `stash@{Mon Aug 17 21:08:54 2026}` — On structure-module: temporary before NFC update
  - `stash@{Tue Aug 11 21:38:02 2026}` — On structure-module: victor's in-progress work (pre email-system build)
  - `stash@{Fri Aug 7 21:20:14 2026}` — On structure-module: pre-gate_ops-rebuild: in-progress loader/misc work
  - `stash@{Fri Aug 7 12:48:06 2026}` — On messaging-functionality: pre-rebuild-add-school-safety-snapshot
- **Worktrees:** numerous worktrees present under `.claude/worktrees/` and `/private/tmp/` (agent branches, `admin-fixes-rules`, `security-owner-settings`, `enrollment-followup`, `fee-plan-phase1`, etc.) — all left untouched, not enumerated exhaustively here since none were opened or modified.
- **Merge/rebase/cherry-pick state:** `git status` reports a clean, non-conflicted, non-mid-operation state ("up to date", no in-progress rebase/merge messaging). **Observation:** a stray `.git/REBASE_HEAD` file exists on disk (content: `0b2b6bf8c75d4fe88acf5f0ec98b4460100556c9`), but `.git/rebase-merge/` and `.git/rebase-apply/` do **not** exist. This is consistent with an orphaned artifact left behind by a past interrupted/aborted rebase, not an active one — `git status` does not report "rebase in progress." Left untouched per the read-only constraint; flagged here for Victor's awareness only.
- **Previous branch/HEAD comparison:** the brief's reference point was HEAD `f125655c` ("Regenerate native splash assets"). Current HEAD `f8d5eb7c` is 8 commits ahead of that (`f125655c → e6e4961f → c5a20c07 → 78c012c0 → f9785881(?) → 7af3d87d → f8d5eb7c`, see `git log -20` below), and commit `407af959` ("feat(health): finalise responsive clinic module") is confirmed still an ancestor in that log. This is expected forward progress, not a regression.

### `git log -20 --oneline --decorate`

```
f8d5eb7c (HEAD -> structure-module, origin/structure-module) feat(exam-factory): source series year/term/exam-type from Structure config
7af3d87d feat(exam-factory): add the Exam Factory module (questions, papers, print, ops, marking)
78c012c0 fix(security): close role-check gaps left by the hasAnyRole() staff-wide shim
c5a20c07 feat(health): route clinic visits + dispensing through the callables
fff009fb feat(health): clinic dispensing guard, attachments, closeout tests + CI
f9785881 Make staff designation optional
6f74e5cf test(health): complete clinic production readiness
e6e4961f fix(academics): enclose DOS dashboard loading guard in a block
f125655c Regenerate native splash assets
03126b7d feat(web): add School Pulse SEO and sitemap foundation
05d0cf93 Add logout action to nurse portal
2e5a6e21 Keep nurse navigation visible across clinic routes
856aa62b Remove legacy nurse dashboard module
407af959 feat(health): finalise responsive clinic module
dcc60875 Prevent nurse navigation from opening shared more portal
a7284451 Keep nurse more actions within clinic portal
1cf8fc74 Improve nurse navigation selected tab contrast
2fc21b38 Remove role selection from staff work step
f5dc3f7a Use roles instead of departments in staff onboarding
e23dc636 Align chat bubbles to conversation edges
```

---

## 3. Environment / Tool Versions

| Tool | Version | Notes |
|---|---|---|
| Flutter | 3.44.6 (stable channel) | revision ee80f08bbf |
| Dart | 3.12.2 (stable, macos_arm64) | |
| Node | v22.22.2 | |
| npm | 10.9.7 | |
| Java | OpenJDK 17.0.19 (Homebrew) | **firebase-tools rules-emulator tests require Java 21+; blocked** |
| Firebase CLI | 15.26.0 | |

`/usr/libexec/java_home -V` found **no other JDK installed** on this machine — Java 21+ is genuinely absent, not just unselected. This is an environment gap, not something this audit could work around without installing software (explicitly out of scope).

---

## 4. Role Inventory (from `lib/core/user_roles.dart`)

The canonical `UserRole` enum (27 values) is the single source of truth found in the codebase — I did not find a second, conflicting role enum. `UserRoleDisplay`, `UserRoleRouting`, and `NotificationGroups` (same file) derive display names, dashboard landing routes, and broadcast-group membership from it.

| Enum value | Display name | Dashboard route (`UserRoleRouting.dashboardPath`) |
|---|---|---|
| `parent` | Parent | `/parent/home` |
| `student` | Student | `/student/dashboard` |
| `director` | Director | `/staff/director` |
| `headTeacher` | Head Teacher | `/staff/admin` (shares admin console) |
| `deputyHead` | Deputy Head | `/staff/admin` (shares admin console) |
| `deanOfStudies` | Dean of Studies | `/staff/dean` |
| `schoolAdmin` | School Admin | `/staff/admin` (shares admin console) |
| `bursar` | Bursar | `/staff/bursar` |
| `classTeacher` | Class Teacher | `/staff/dashboard` (default; teacher module has its own shell) |
| `subjectTeacher` | Subject Teacher | `/staff/dashboard` (default; teacher module has its own shell) |
| `librarian` | Librarian | `/staff/librarian` |
| `nurse` | Nurse | `/staff/nurse` |
| `boardingMatron` | Matron (Girls) | `/staff/matron` |
| `boardingPatron` | Patron (Boys) | `/staff/patron` |
| `transportCoordinator` | Transport | `/staff/transport` |
| `guidanceDiscipline` | Guidance & Discipline | `/staff/discipline` |
| `storeInventory` | Store Inventory | `/staff/inventory` |
| `gatekeeper` | Gatekeeper | `/staff/security` (shared with securityHead/receptionist) |
| `securityHead` | Head of Security | `/staff/security` |
| `gamesMaster` | Games Master | `/staff/games` |
| `cateringManager` | Catering Manager | `/staff/catering` |
| `religiousLeader` | Religious Leader | `/staff/religious-leader` |
| `receptionist` | Receptionist | `/staff/security` |
| `hrOfficer` | HR Officer | `/staff/hr` |
| `admissions` | Admissions | `/staff/dashboard` (default — no dedicated dashboard route found) |
| `registrar` | Registrar | `/staff/dashboard` (default — no dedicated dashboard route found) |
| `superAdmin` | Platform Owner | `/super-admin` |

**Role-family disambiguation (explicitly checked, not assumed):**
- **"Dean" vs "Dean of Studies" vs "Discipline":** the enum has exactly one dean-shaped role, `deanOfStudies`, routed to `/staff/dean` with its own `lib/features/dean/` directory. `guidanceDiscipline` is a **separate** role routed to `/staff/discipline` with its own `lib/features/discipline/` directory. There is no separate "Dean" (non-of-Studies) role or "discipline" alias of DOS in source — they are architecturally distinct, confirmed via `rg -n "deanOfStudies|guidanceDiscipline" lib/core/user_roles.dart` (hits at lines 6/16/44/64/198/210) and directory existence checks.
- **Matron/Patron:** `UserRoleDisplay.matronGenderScope()` (user_roles.dart:116-125) explicitly scopes `boardingMatron → 'Female'` and `boardingPatron → 'Male'`, confirming these are gender-segregated dormitory roles, not aliases of one "boarding staff" role.
- **`adminConsoleRoles`** (director, headTeacher, schoolAdmin, deputyHead) share the `/staff/admin` shell UI, but **`adminRoles`** (director, headTeacher, schoolAdmin only — deputyHead excluded) is the narrower set server-verified for staff-invite privileges. The in-code comment at user_roles.dart:101-105 states this distinction explicitly and warns that a role in `adminConsoleRoles` but not `adminRoles` "shares the admin console UI but isn't permitted to invite staff server-side" — i.e., Deputy Head sees the invite-staff UI but the Cloud Function will reject the call. This is a legitimate architectural gap the code itself documents, not a defect I'm inferring — **worth a Day 2 check on whether the UI actually hides/disables the invite action for Deputy Head, or lets them attempt and fail server-side** (UNVERIFIED — I did not trace the invite screen's role gating in this pass).

Roles NOT found as a separate enum value despite being named in the brief's "expected role families": Headteacher and Director are distinct values (not merged); no separate "Secondary Nurse" value exists (only one `nurse` role); Admissions and Registrar exist as roles but have no dedicated dashboard route (fall through to `/staff/dashboard` default) — see §8 routing gaps.

---

## 5. Role Feature-Directory Footprint (breadth evidence)

Using `rg -l "UserRole.<role>\b" lib/features --type dart`, mapped to the top-level feature directory referencing each role. This shows where each role is *referenced*, not that every reference is a complete, working chain — full 8-layer tracing was performed only for a sample of roles (see §6); the rest are recorded here as breadth evidence and marked accordingly in the matrix.

| Role | Feature directories referencing it |
|---|---|
| parent | admin, appointments, auth, communication_center, messages, notifications, parent, shared, structure |
| director | admin, appointments, approvals, attendance_hub, finance, hr, inventory, messages, notifications, shared, student |
| headTeacher | admin, appointments, approvals, attendance_hub, finance, hr, inventory, messages, notifications, parent, shared, student |
| deputyHead | admin, appointments, attendance_hub, inventory, messages, notifications, parent, shared, student |
| deanOfStudies | admin, dean, notifications, parent, shared |
| schoolAdmin | admin, appointments, approvals, attendance_hub, auth, finance, hr, institution, inventory, messages, notifications, parent, shared, student |
| bursar | admin, approvals, finance, hr, inventory, notifications, parent, shared, student |
| classTeacher | admin, discipline, notifications, parent, shared, teacher |
| subjectTeacher | admin, notifications, parent, shared, teacher |
| librarian | admin, notifications, shared |
| nurse | admin, notifications, parent, shared, student |
| boardingMatron | admin, attendance_hub, notifications, shared, structure |
| boardingPatron | admin, attendance_hub, notifications, shared, structure |
| transportCoordinator | admin, notifications, shared |
| guidanceDiscipline | admin, notifications, parent, shared |
| storeInventory | admin, inventory, notifications, shared |
| gatekeeper | admin, notifications, shared |
| securityHead | admin, appointments, notifications, shared |
| gamesMaster | admin, notifications, shared |
| cateringManager | admin, notifications, shared |
| religiousLeader | admin, notifications, shared |
| receptionist | admin, appointments, notifications, parent, shared |
| hrOfficer | admin, notifications, shared |
| admissions | admin, shared, student |
| registrar | admin, shared, student |
| superAdmin | admin, auth, branding, institution, notifications, profile, shared, super_admin |
| student | admin, appointments, communication_center, messages, notifications, shared, structure |

**Note on `librarian`:** despite a dedicated `lib/features/librarian/` directory existing and a dedicated dashboard route (`/staff/librarian`), the role-string search above did not surface `lib/features/librarian` itself in the hit list — meaning the librarian screens likely don't gate individual widgets by `UserRole.librarian` checks inline (gating happens at the router level instead). This is architecturally normal (route-level gating is often sufficient) but means role-level UI gating *within* the librarian screens is UNVERIFIED without deeper reading.

Test-file coverage per operational feature directory (`find test/features/<dir> -type f | wc -l`):

| Feature dir | Test files |
|---|---|
| librarian | 0 |
| gate_ops | 1 |
| matron | 0 |
| patron | 1 |
| transport | 1 |
| hr | 0 |
| discipline | 0 |
| catering | 1 |
| games | 0 |
| religion | 0 |
| inventory | 0 |

This is a real, evidence-based gap: **7 of 11 checked operational feature directories have zero automated tests.** Combined with BLoC/Cubit presence counts (`find lib/features/<dir> -iname '*bloc*' -o -iname '*cubit*'`): librarian=0, gate_ops=0 (dedicated bloc naming may differ — gate_ops has substantial code but not matching this naming grep, see caveat below), matron=2, patron=2, transport=3, hr=3, discipline=2. Note: gate_ops showing 0 for the bloc/cubit filename grep is very likely a **false negative** from naming convention (gate_ops has its own `movement_verification_policy_test.dart` which passed inside the full flutter test run, proving real domain logic exists there) — flagged as a grep artifact, not a claim that gate_ops has no state management.

---

## 6. Detailed Role Chain Evidence (sample-traced roles)

Full 8-layer chain tracing (definition → claims → dashboard → router guard → shell → screen → BLoC → repository → data source → Firestore/Functions → rules → notifications → tests) was performed for a representative sample given time constraints; the remainder are recorded at the breadth level in §5 and marked UNVERIFIED for full-chain completeness in the matrix (§ below is a separate file section, see "Role Release Matrix").

### Super Admin (`UserRole.superAdmin`)
- Definition: `lib/core/user_roles.dart:27`. Dashboard: `/super-admin`.
- Router guard: `lib/app/router.dart` has explicit superAdmin checks (lines 484, 520, 647) plus a **dedicated router test file**, `test/app/router_owner_staff_gate_test.dart`, whose stated purpose (from its own test name) is exactly the brief's "super admin is not a normal school-tenant user" invariant: reject a superAdmin-authenticated session found on `/staff/login` or any `/staff/*` route.
- **Test result: FAILING.** `redirect callback rejects a superAdmin-authenticated session found on /staff/login or any /staff/* route` — **Expected: true, Actual: false**. This is the single most security-relevant test failure found in this audit — see §14 Critical findings.
- Feature directory: `lib/features/super_admin/` — substantial code (owner auth, recovery codes, security center, sign-in events, device registry — see `public_functions/owner_*.js` backing it).
- Backend: `public_functions/owner_auth.js`, `owner_security_session.js`, `owner_recovery_codes.js`, `owner_sign_in_events.js`, `owner_device_registry.js`, `owner_rate_limit.js`, `owner_first_factor_verify.js` — a large, dedicated platform-owner auth stack separate from tenant staff auth, consistent with the brief's "super admin is not a normal school-tenant user" requirement.
- Status: **PARTIAL** (architecturally separated as required, but the specific router-guard test proving that separation is currently red).

### Bursar (`UserRole.bursar`)
- Dashboard: `/staff/bursar`. Feature dir: `lib/features/finance/` (plus `admin`, `approvals`, `hr`, `inventory`, `notifications`, `parent`, `shared`, `student` cross-references per §5).
- Backend: dedicated Functions files — `finance_governance.js`, `finance_operations.js`, `finance_reconciliation.js`, `financial_entitlements.js` (+ `.test.js`), plus report-card release wiring (`report_card_release.js`, modified in Victor's current WIP).
- Tests: `financial_entitlements.test.js` exists at the Functions layer; `test/features/finance/` exists at the Flutter layer (not exhaustively counted here). `test:report-card-engine` (pure logic, no emulator) reproduced at **59/59 passing** in this session, matching the prior baseline exactly — the one number in this audit fully reproduced and confirmed unchanged.
- `integration_test/bursar_flows_test.dart` exists — an integration test file specifically for Bursar flows, though it requires a device/emulator to execute and was **not run** in this pass (no simulator/emulator target was driven for integration tests; classified as UNVERIFIED / missing environment for this specific check, see §12).
- Status: **PARTIAL-to-FUNCTIONAL** by code-reading; report-card-engine logic layer is VERIFIED (59/59 reproduced); full emulator/rules layer is UNVERIFIED this session (Java blocker).

### Class Teacher / Subject Teacher (`UserRole.classTeacher` / `UserRole.subjectTeacher`)
- Both route into the large `lib/features/teacher/` module (also cross-referencing `discipline`, `admin`, `parent`, `shared`, `notifications`).
- Uncommitted WIP evidence: `git status` shows `lib/features/teacher/presentation/bloc/class_tasks/class_tasks_bloc.dart` and `lib/features/teacher/presentation/screens/class_teacher_tasks_screen.dart` **deleted**, with a new untracked `lib/features/teacher/presentation/screens/class_teacher_more_screen.dart` — Victor is mid-refactor of the Class Teacher "More" navigation, consistent with the user's own memory note ("Class Teacher panel build ... only Resources/timetable/More outstanding"). This audit did not evaluate whether the refactor is internally consistent (out of scope — it's in-progress, uncommitted work).
- Test evidence: teacher module tests ran heavily in the full `flutter test` pass (class_task_policy_test.dart, class_work_policy_test.dart, subject_sync_service_test.dart, lesson_attendance_repository_test.dart, class_work_repository_test.dart, report_card_body_test.dart all executed and are visible passing in the captured output near the end of the run). `integration_test/class_teacher_flows_test.dart` exists but was not executed (no device/emulator driven).
- Status: **FUNCTIONAL** (large, tested, real implementation); the "More" screen refactor is **PARTIAL/in-flight** and its correctness is UNVERIFIED since it's uncommitted WIP outside audit scope to evaluate deeply.

### Nurse (`UserRole.nurse`)
- Dashboard `/staff/nurse`. Feature dir `lib/features/nurse/` + `health_clinic.js` backend + `institution_health.js`.
- Test evidence: `test/features/nurse/` exists; in the full `flutter test` run, `nurse_home_screen_test.dart` and `dispense_medicine_sheet_test.dart` **passed**, but `nurse_clinic_visits_screen_test.dart` **failed to load** (compile error, cascading from the same `platform_owner_access_screen.dart` defect noted above — not a nurse-module-specific defect).
- Recent commit history (`git log`) shows heavy, recent nurse-module work: "feat(health): route clinic visits + dispensing through the callables", "feat(health): clinic dispensing guard, attachments, closeout tests + CI", "feat(health): finalise responsive clinic module" — consistent with the user's memory notes describing this as a maturing module.
- Status: **FUNCTIONAL**, with one test file currently UNVERIFIED due to the unrelated compile error blocking it from loading (not a nurse-specific regression).

### Parent
- Dashboard `/parent/home`. Very large route surface under `/parent/*` (health, library, discipline, transport, appointments, boarding, security, calendar, announcements — 20+ distinct routes found in router.dart).
- Offline: `ParentOfflineCacheService` / `ParentOfflineQueueService` confirmed referenced in `auth_bloc.dart:291,297` with explicit `clearAllForParent()` calls on logout — direct evidence of per-user offline-cache cleanup on logout for this role specifically, matching the brief's required policy ("parent mobile may use scoped Isar caching + idempotent queues... logout/account switching must clear user-scoped local data").
- Status: **FUNCTIONAL**, offline logout-cleanup **VERIFIED** by direct code read (not inferred).

### Admissions / Registrar
- Both roles exist in the enum but have **no dedicated dashboard route** in `UserRoleRouting.dashboardPath` — both fall through to the generic `/staff/dashboard` default case. This is a genuine routing gap: a staff member whose only role is `admissions` or `registrar` lands on the generic staff dashboard rather than a role-specific one.
- Status: **SKELETON at the routing layer** — role exists, is referenced in `admin`/`shared`/`student` feature code, but has no dedicated landing experience. Flagged as a Day 2 routing gap (§8).

---

## 7. Role Release Matrix (status summary)

Status labels used strictly per the brief's definitions — **VERIFIED/RELEASE-READY require test or build evidence actually observed in this session**, not inference from a screen rendering.

| Role | Dashboard route | Directory footprint | Automated test evidence this session | Status |
|---|---|---|---|---|
| Super Admin | `/super-admin` | Deep (owner_* Functions stack) | 1 router-guard test **FAILING** | **BLOCKED** (security-relevant test regression) |
| Director | `/staff/director` | 11 cross-referenced dirs | Present in full suite run, not isolated-verified here | PARTIAL |
| Head Teacher | `/staff/admin` (shared) | 12 dirs | Present in full suite run | PARTIAL |
| Deputy Head | `/staff/admin` (shared) | 9 dirs | Present in full suite run | PARTIAL |
| Dean of Studies | `/staff/dean` | 5 dirs (dedicated `dean/`) | Present in full suite run | PARTIAL |
| School Admin | `/staff/admin` (shared) | 14 dirs | Present in full suite run | PARTIAL |
| Bursar | `/staff/bursar` | 9 dirs, dedicated Functions | report-card-engine 59/59 **VERIFIED**; rest UNVERIFIED (Java blocker) | FUNCTIONAL |
| Class Teacher | `/staff/dashboard` (default) | Large `teacher/` module | Many passing tests observed; module mid-refactor (uncommitted) | FUNCTIONAL (in-flight WIP) |
| Subject Teacher | `/staff/dashboard` (default) | Large `teacher/` module | Many passing tests observed | FUNCTIONAL |
| Librarian | `/staff/librarian` | 3 dirs, thin | 0 dedicated test files found | SKELETON-to-PARTIAL |
| Nurse | `/staff/nurse` | 5 dirs + dedicated Functions | 2/3 checked test files passing, 1 blocked by unrelated compile error | FUNCTIONAL |
| Matron (Girls) | `/staff/matron` | 5 dirs | 0 dedicated test files found | PARTIAL |
| Patron (Boys) | `/staff/patron` | 5 dirs | 1 test file found | PARTIAL |
| Transport | `/staff/transport` | 3 dirs | 1 test file found | SKELETON-to-PARTIAL |
| Guidance & Discipline | `/staff/discipline` | 4 dirs (dedicated `discipline/`) | 0 dedicated test files found | PARTIAL |
| Store Inventory | `/staff/inventory` | 4 dirs (dedicated `inventory/`) | 0 dedicated test files found | PARTIAL |
| Gatekeeper | `/staff/security` (shared) | 3 dirs | shares `gate_ops` module tests (movement_verification_policy_test passed) | PARTIAL |
| Head of Security | `/staff/security` (shared) | 4 dirs | shares `gate_ops` module tests | PARTIAL |
| Games Master | `/staff/games` | 3 dirs, thin | 0 test files found | SKELETON |
| Catering Manager | `/staff/catering` | 3 dirs, thin | 1 test file found | SKELETON-to-PARTIAL |
| Religious Leader | `/staff/religious-leader` | 3 dirs, thin | 0 test files found | SKELETON |
| Receptionist | `/staff/security` (shared) | 5 dirs | shares gate_ops/security tests | PARTIAL |
| HR Officer | `/staff/hr` | 3 dirs | 0 dedicated Flutter test files; some HR-adjacent logic covered elsewhere | SKELETON-to-PARTIAL |
| Admissions | `/staff/dashboard` (**no dedicated route**) | 3 dirs | not isolated | SKELETON (routing gap) |
| Registrar | `/staff/dashboard` (**no dedicated route**) | 3 dirs | not isolated | SKELETON (routing gap) |
| Student | `/student/dashboard` | 7 dirs, large route surface (14+ `/student/*` routes) | present in suite run | PARTIAL |
| Parent | `/parent/home` | 9 dirs, 20+ routes | offline logout cleanup VERIFIED by code read | FUNCTIONAL |

**Important honesty note:** "PARTIAL" above for many staff roles reflects that I confirmed *code presence and directory footprint* but did **not** individually re-run each role's isolated test subset or manually re-derive full 8-layer chains for all 27 roles within this session's time budget — that deeper per-role verification (especially rules-emulator coverage, which is entirely blocked by the Java version gap) is explicitly flagged as **UNVERIFIED**, not claimed as passing. Where I state VERIFIED (report-card-engine 59/59, `flutter analyze` 0 errors, `flutter build web --release` success, parent logout cache cleanup, super-admin/staff router guard test failure), those are things I personally ran or read this session.

---

## 8. Routing and Navigation Gaps

- **Admissions and Registrar have no dedicated dashboard route** — both fall through to `/staff/dashboard` in `UserRoleRouting.dashboardPath` (user_roles.dart:220-221 default case). Confirmed by reading the full switch statement; neither role has an explicit case.
- **Deputy Head shares the `/staff/admin` console UI** with Director/HeadTeacher/SchoolAdmin (`adminConsoleRoles`) but is **excluded** from `adminRoles` (the server-verified staff-invite permission set). The code's own comment (user_roles.dart:101-105) flags this as an intentional-but-risky split: "a role here that the Cloud Function doesn't also allow will see an 'invite staff' UI that fails server-side" if the two lists drift. Whether the current UI actually disables/hides the invite action for Deputy Head specifically was **not verified** in this pass — recommended as an explicit Day 2 check.
- **Class Teacher module mid-refactor**: `class_tasks_bloc.dart` and `class_teacher_tasks_screen.dart` deleted in the working tree, replaced by an untracked `class_teacher_more_screen.dart` — router wiring for this in-flight change was not deeply traced (it's uncommitted, active work, appropriately out of scope for a snapshot audit beyond flagging its existence).
- Router file is large (4121 lines) with ~457 named route declarations; a full manual enumeration of every route-to-role permission mapping was not completed within this session's time budget — recommend a Day 2 or dedicated follow-up pass using automated extraction (e.g., a script cross-referencing every `GoRoute` against its guard clause) rather than manual reading, given the file's size.

---

## 9. Backend / Functions / Rules Gaps

- `functions/index.js` and `public_functions/index.js` both pass a plain `node -c` syntax check (no syntax errors). Neither `functions/package.json` nor `public_functions/package.json` defines a `lint` script, so no ESLint-equivalent check was run — this is a **missing tooling** gap (no lint config to invoke), not a code failure.
- Server-side role gating in `functions/index.js` is real and layered: `ADMIN_ROLES`, `APPROVAL_ADMIN_ROLES`, `SECURITY_ADMIN_ROLES`, `PARENT_INVITE_ADMIN_ROLES`, `STUDENT_CARE_ADMIN_ROLES`, `ACADEMIC_ADMIN_ROLES`, plus a generic `requireRole(auth, roles, action)` helper (index.js:3519) — confirms server-verified role checks exist beyond client-side UI gating, addressing the brief's "Functions accepting client-supplied role... without server verification" concern for at least these call sites. A full audit of *every* callable Function for this pattern was not completed (index.js and its companions are large; spot-checked, not exhaustively read).
- Firestore rules: 3597 lines, 316 `schoolId`-referencing lines, 316 `match /` blocks. No `allow read, write: if true` broad-allow patterns found in a targeted grep. `parent_learner_links` collection is fully locked (`allow read, write: if false`) — consistent with the brief's "only a school administrator can reallocate an existing parent-learner relationship" requirement being enforced via Cloud Functions rather than direct client writes (the actual reallocation Function itself was not located by a `reallocat` grep across `functions/*.js` — **worth a Day 2 follow-up** to confirm which specific callable performs this and that it truly requires admin role server-side, since the rules lockdown alone proves clients can't write directly but doesn't prove the Function that *can* write enforces the same admin-only rule).
- **Rules-emulator tests entirely blocked** this session by the Java 17-vs-21 gap (`firebase-tools no longer supports Java version before 21`). This affects: `test:rules` (firestore.rules.test.cjs), `test:storage-rules`, and every `*:emulator` script in `functions/package.json` (report-card workflow/bursar/release-exceptions, student-fee-billing, payment-codes, finance-governance/operations/reconciliation, health-clinic, financial-entitlements, create-staff-account). None of these could be reproduced or refuted this session — the previously-reported 189/42 rules baseline and 11/11 storage baseline are **UNVERIFIED**, not confirmed passing or failing.
- Attribution-field protection pattern found in rules (`request.resource.data.createdBy == request.auth.uid` at firestore.rules:351,573,578) — a real pattern preventing a client from writing an arbitrary `createdBy` value, spot-checked at 3 locations, not exhaustively verified across every mutable collection.

---

## 10. Offline and Synchronization

- **Parent (mobile):** confirmed real offline architecture — `ParentOfflineCacheService`/`ParentOfflineQueueService`, with explicit `clearAllForParent()` on logout (`auth_bloc.dart:291,297`) — matches required policy.
- **Class/Subject Teacher:** offline queue tests are extensive and passed in the full suite run — `subject_sync_service_test.dart` includes idempotency-shaped test names ("keeps a failed operation queued and counts the retry", "flags two devices submitting the same register", "replays audit rows only after the actions they describe") — strong evidence of a deliberate, tested idempotent-queue design for class register/task/homework/behaviour sync, though the underlying idempotency-key mechanism itself was not independently re-derived from source in this pass (relying on the passing tests as evidence, which is a legitimate but indirect form of verification).
- **Attendance offline queue:** `attendance_offline_queue_test.dart` largely **FAILED** in this run — but the failure mode (`type 'Null' is not a subtype of type 'Future<Either<Failure, List<Student>>>'`) is a **test-double/mock setup defect** (a `_MockStudentRepository.getAllStudents` stub not returning a value), not evidence the production offline-queue logic itself is broken — this reads as a test-fixture regression, likely from the same in-flight WIP touching `attendance_hub` (visible in `git status`), rather than a genuine attendance-duplication risk. Flagged as **needs Day 2 triage**, not assumed either way.
- **Isar logout scoping beyond parent/teacher:** not exhaustively checked for every role — recorded as UNVERIFIED for roles other than Parent and (partially) Subject Teacher.
- **Web (parent or otherwise):** the brief requires "parent web must stay online-only for sensitive data" — this specific constraint (i.e., that the web build path does not compile in Isar/local-caching code for parent financial/health data) was **not directly verified**; `flutter build web --release` succeeded, and the build log shows Isar's native FFI backend is correctly excluded from the wasm-dry-run analysis (expected — Isar has a web-specific implementation path), but whether *parent-specific sensitive screens* specifically avoid any local persistence on web was not traced screen-by-screen. UNVERIFIED.
- Per the brief's explicit list of offline-unsafe operations (payments, approvals, stock dispensing, identity reassignment, permission changes) — none of these were found wrapped in an offline-queue pattern during the checks performed (bursar/finance and nurse-dispensing code was read for role/directory structure, not deeply re-read line-by-line for offline-queue wrapping in this pass). Recorded as UNVERIFIED rather than claiming either safe or unsafe.

---

## 11. Responsive / Accessibility

Given the time budget consumed by Phases 1–8 (baseline command execution, especially the ~48-minute full `flutter test` run), a systematic LayoutBuilder/MediaQuery breakpoint sweep across all role shells at the three target sizes (390×844 / 768×1024 / 1440×900) was **not completed** in this session. Partial evidence: `test/features/school_calendar/month_calendar_grid_test.dart` includes an explicit test named "renders without overflow at narrow (320px) width" which **passed**, showing at least one screen has deliberate narrow-width overflow testing in place — a positive, if isolated, signal. This entire phase should be treated as **largely UNVERIFIED** and is a legitimate Day 2/Day 3 follow-up rather than something safely claimed complete here.

---

## 12. Test and Build Baseline — Commands and Actual Results

All commands below were run from the repository root (or `functions/` where noted) with no dependency upgrades, no production Firebase connection, and no rules weakening.

| Command | Result | Classification |
|---|---|---|
| `flutter --version` | Flutter 3.44.6 / Dart 3.12.2 | Recorded |
| `dart format --output=none --set-exit-if-changed lib/ test/` | Exit non-zero; 96 files would be reformatted (list captured); **no files modified** (`--output=none`) | Formatting drift exists in current WIP, not a failure — informational |
| `flutter analyze lib/` | **0 errors, 10 warnings, 250 info = 260 total issues** (5.3s) | PASS (no errors) |
| `flutter test` (full suite) | **1607 passed, 26 failed** (~48 min wall time); 5 test files failed to *load* due to a compile error in `lib/features/auth/login_flow/platform_owner_access_screen.dart` (duplicated named argument `color`, non-constant expression at lines 148/246/303) | **FAIL** — real compile defect + 1 security-relevant router-guard test failure (see §14) + attendance offline-queue mock-setup failures (see §10) |
| `cd functions && npm run test:rules` | `Error: firebase-tools no longer supports Java version before 21` | **BLOCKED — missing environment (Java 21+ not installed)** |
| `cd functions && npm run test:storage-rules` | Same Java 21+ error | **BLOCKED — missing environment** |
| `cd functions && npm run test:report-card-engine` | **59 passed, 0 failed** (pure-logic, non-emulator) | **PASS — reproduced, matches prior baseline exactly** |
| All other `*:emulator` scripts in `functions/package.json` | Not run (same Java 21+ blocker would apply; not attempted individually to conserve time given the confirmed root cause) | BLOCKED — missing environment |
| `node -c functions/index.js` | Syntax OK | PASS (syntax only, not full lint — no lint script exists) |
| `node -c public_functions/index.js` | Syntax OK | PASS (syntax only) |
| `flutter build web --release` | **`✓ Built build/web`** (~60.5s compile) | **PASS — reproduced, matches prior baseline** |
| Android build check | **Not attempted** — no explicit Android SDK/device check was run in this session; recorded as UNVERIFIED rather than assumed working | UNVERIFIED / not attempted |
| Integration tests (`integration_test/*.dart`) | **Not run** — no simulator/emulator device was driven in this session (this differs from the user's own stated simulator-testing preference in memory, which was not invoked because this is a source-level audit, not an app-launch session) | UNVERIFIED / no device driven |
| `java -version` | OpenJDK 17.0.19 (Homebrew); `/usr/libexec/java_home -V` shows no other JDK installed | Recorded — root cause of all emulator blockers |

### Comparison with previous known baselines

| Metric | Previously reported | This session | Comparison |
|---|---|---|---|
| `flutter analyze lib/` errors | 0 | 0 | **Unchanged** |
| `flutter analyze lib/` warnings | ~230 | 10 warnings + 250 info = 260 total | Not a clean apples-to-apples number (likely the prior report combined info+warnings into one "warnings" bucket); **roughly comparable, slightly higher**, not a regression to errors |
| Firestore rules tests | 189 passing / 42 failing | **Could not run** (Java 21+ missing) | **UNVERIFIED this session** — neither confirmed nor refuted |
| Nurse focused tests | 35/35 | Not isolated as a standalone 35-test run in this session (nurse tests ran as part of the full suite; 2 of 3 spot-checked nurse test files passed, 1 blocked by the unrelated compile error) | **Partially reproduced, not exactly matched** |
| Storage rules tests | 11/11 | **Could not run** (Java 21+ missing) | **UNVERIFIED this session** |
| Health Function test | 1/1 | Not isolated separately; health/clinic tests ran within the full suite | Not independently reproduced as a discrete 1/1 |
| DOS/dean/academic tests | 42/42 | Not isolated as a standalone run | Not independently reproduced |
| Report-card suites (26/26, 8/8, 14/14, 11/11, engine 59/59, finance shell 25/25) | as listed | **engine 59/59 reproduced exactly**; the other discrete suite numbers (26/26, 8/8, etc.) were not isolated and re-run as standalone commands in this session (they ran as part of the full `flutter test`, but I did not cross-reference each named suite's pass count individually against the full-suite output within the time available) | **Partially reproduced** (engine confirmed; others not individually confirmed) |
| Web release build | succeeded previously | **succeeded again** | **Unchanged — reproduced** |

---

## 13. Security Findings (ranked)

### Critical
1. **Super Admin/staff route-separation guard test is failing.** `test/app/router_owner_staff_gate_test.dart` — "redirect callback rejects a superAdmin-authenticated session found on /staff/login or any /staff/* route" — Expected `true`, Actual `false`. This directly maps to the brief's core invariant "the super admin is the platform owner and is not a normal school-tenant user." A failing test here does not by itself prove the production redirect is broken (the router code itself was not independently re-derived from first principles in this pass to confirm whether the *test* or the *implementation* is wrong), but it must be triaged before Day 2 proceeds, since it is exactly the kind of regression this audit exists to catch. **File:** `test/app/router_owner_staff_gate_test.dart`; guard logic under test lives in `lib/app/router.dart` (superAdmin checks at lines 484, 520, 647).

### High
2. **Rules-emulator test suite entirely unverifiable in this environment** (Java 17 vs required 21+). Every tenant-isolation, role-injection, parent-linkage, and financial/health-record security invariant that the brief asks to be "explicitly verified via... rules-emulator tests where feasible" could not be exercised. This is an environment gap, not a code defect, but it means **no security-rules regression from the prior 189/42 baseline can be ruled out** until a JDK 21+ environment is available.
3. **Parent-learner reallocation Function not located.** `parent_learner_links` is locked down client-side (`allow read, write: if false`), which is good, but the specific Cloud Function callable that *does* perform admin-only reallocation was not found via a direct `reallocat` grep across `functions/*.js`. Either the naming differs from what was searched, or this flow is implemented differently than expected — needs a Day 2 follow-up to confirm the write path exists and is genuinely admin-gated server-side, not just client-blocked.

### Medium
4. **Deputy Head admin-console/invite-privilege split is unverified in the UI.** The code comments openly flag the risk of drift between `adminConsoleRoles` and `adminRoles`; whether the invite-staff button is actually hidden/disabled for Deputy Head (rather than visible-but-failing) was not verified.
5. **Attendance offline-queue test failures** (`type 'Null' is not a subtype of...`) — read as a test-fixture/mock defect rather than a production duplicate-record risk, but this reading was not independently proven by tracing the production `AttendanceRepositoryImpl._validateStudentPlacement` logic outside of the test failure trace itself. Given the brief's explicit concern about "queues that can duplicate... attendance," this deserves direct Day 2 confirmation rather than resting on my read of the stack trace alone.

### Low
6. **Operational roles with zero test coverage** (Librarian, Matron, HR, Discipline, Games, Religion, Inventory — 0 test files each per §5) are a data-integrity/regression-risk gap rather than an active vulnerability, but they mean any future change to these modules has no automated safety net.
7. **No lint script configured** for either `functions/` or `public_functions/` — reduces the chance of catching accidental server-side issues (e.g., a missing role check) before they reach code review.

---

## 14. Dead Code, Duplicates, Mocks, Placeholders, Unreachable Features

Evidence gathered via targeted `rg` passes (not exhaustive — large codebase, time-boxed):

- **`MockBiometricDeviceService` registered in production DI** (`lib/injection_container.dart:2280`, `sl.registerLazySingleton<BiometricDeviceService>(() => MockBiometricDeviceService())`). This is **honestly self-documented** in the surrounding comments and in `lib/features/biometrics/presentation/screens/biometric_enrollment_screen.dart:18` ("MockBiometricDeviceService today, pending real hardware/SDK integration") — not a hidden false-completion, but it does mean the Biometric Enrollment feature is **not real** in production today, only simulated. Anyone believing fingerprint enrollment "works" because the screen renders would be wrong.
- **17 TODO markers found in `lib/`** (via `rg -n "TODO|FIXME|HACK"`), concentrated heavily in `lib/features/director/presentation/screens/*` (academic_overview, school_performance, student_analytics, financial_overview, director_reports, finance_analytics, communication, incidents — 8 of the 9 Director analytics/reports screens have at least one TODO marking a chart/data source as not yet wired to real data). The Director module's own code comments are explicit and honest about this ("left as an honest empty state (see TODO) rather than inventing numbers" — `financial_overview_screen.dart:17`), which is good practice, but functionally means **Director's analytics/reporting screens are UI-only/placeholder for several data series**, not FUNCTIONAL, despite the screens themselves rendering.
- **"Coming soon" labels found in 10 locations**, notably: Boarding Settings (`boarding_more_screen.dart`), Message Templates (`director/communication_screen.dart`), Live GPS tracking (`parent/transport_screen.dart`), Pickup release (`gate_ops/pickup_release_screen.dart` — entire screen body is just a "coming soon" placeholder, not a partial feature), Gate operations dashboard (`gate_ops_minimal_dashboard_screen.dart` — also a full placeholder body), Document upload (`dean/documents_screen.dart`), several Teacher "coming soon" snackbars for sibling info / notes / marks-dashboard sub-features.
- **Gate Ops has at least two entirely placeholder screens** (`pickup_release_screen.dart`, `gate_ops_minimal_dashboard_screen.dart`) despite the module having real, tested domain logic elsewhere (`movement_verification_policy_test.dart` passed) — this is a genuinely mixed module: real security-critical verification logic coexists with unbuilt UI surfaces for the same feature area. The user's own memory notes reference a "Gate Ops rebuild" in progress via a stash, consistent with this being mid-flight work rather than abandoned.
- **Director's Incidents screen has no backing repository at all** — its own top-of-file comment states plainly: "No incident-tracking repository exists yet for the Director module" (`director/presentation/screens/incidents_screen.dart:9`).
- No `allow read, write: if true` broad-allow rules found in `firestore.rules` in the patterns checked (spot-check, not exhaustive).
- No hardcoded school IDs found in a targeted `schoolId = '...'` literal-string grep across `lib/features` (spot-check, not exhaustive; the absence of hits is meaningful but not proof of zero occurrences under different variable names).

---

## 15. External Limitations and Policy Decisions Still Required

Per the brief's explicit guidance, these are preserved as known limitations, not re-litigated:
- iOS push notification delivery cannot be claimed verified without a paid Apple Developer membership, real bundle ID, provisioning, APNs configuration, and a physical supported test environment — none of that was exercised or claimed here.
- Web App Check remains intentionally disabled pending a real reCAPTCHA v3 key (not independently re-verified this session, but no evidence contradicting this was found either).
- Notification digest scheduling, an email/SMS delivery worker, and a template-editing UI remain known-outstanding items per prior context; this session found nothing in source that proves otherwise (the "Message Templates... coming soon" finding in §14 is consistent with this still being outstanding).
- **New this session:** the Java 21+ requirement for `firebase-tools` rules-emulator testing is a hard environment blocker on this machine that needs a policy decision — either install a JDK 21+ (e.g., via a version manager so it doesn't disturb the existing JDK 17 used elsewhere) or accept that rules-emulator regression testing is simply not possible in this dev environment until that's resolved.

---

## 16. Top Shared Blockers Affecting Multiple Roles

1. **The `platform_owner_access_screen.dart` compile error** blocks 5 test files across unrelated modules (attendance_hub, nurse, student enrollment ×2, structure) from loading at all — this single defect is currently degrading the visibility of test health across roles that have nothing to do with the platform-owner login screen itself, purely because Dart's test compiler treats the whole tree as one compilation unit.
2. **Java 21+ absence** blocks all rules-emulator and Functions-emulator tests — affects every role whose security model depends on Firestore/Storage rules (i.e., every role).
3. **Director module's placeholder analytics** affect the Director/Headteacher approval-and-oversight workflow (Cross-Role Workflow #7 in the brief) since real financial/academic/discipline trend data isn't wired yet — Director's oversight role is architecturally present but functionally shallow in its reporting surface.
4. **Gate Ops placeholder screens** affect both the Gatekeeper/Security-Head/Receptionist roles and the cross-role Gate/Security → parent-alert workflow (#13).

---

## 17. Day 2 Repair Queue (dependency order, per the brief's stated priorities)

1. **Fix the `platform_owner_access_screen.dart` compile error** (duplicated `color` named argument, non-constant expressions at lines 148/246/303) — this is blocking accurate test visibility for 5 unrelated test files and should be the very first fix, since nothing else can be reliably measured until the suite compiles cleanly.
2. **Triage the failing `router_owner_staff_gate_test.dart` superAdmin/staff-route-separation test** — determine whether the test or the router redirect logic is wrong, and fix whichever is incorrect. This is the highest-priority *security* item since it's the platform-owner/tenant-isolation boundary.
3. **Resolve the Java 21+ gap** (install a compatible JDK, ideally without disturbing the existing JDK 17 toolchain) so that Firestore/Storage rules-emulator tests and every Functions `*:emulator` script can actually run — until this is fixed, no rules regression can be detected.
4. **Re-run the full rules-emulator suite once Java is fixed**, and compare against the prior 189-passing/42-failing baseline to establish whether those 42 pre-existing failures are still present, worse, or improved.
5. **Investigate the attendance offline-queue test failures** (`_MockStudentRepository.getAllStudents` returning `Null`) — confirm this is purely a test-fixture defect and not a symptom of a real change to `AttendanceRepositoryImpl._validateStudentPlacement`'s contract.
6. **Locate and verify the parent-learner reallocation Cloud Function** — confirm it exists, is admin-role-gated server-side, and is audited, closing the one workflow (#9 in the brief, parent-child linkage) where this audit could not find direct evidence of the write path.
7. **Verify the Deputy Head invite-staff UI gating** — confirm the UI hides/disables staff invitation for Deputy Head rather than presenting a control that fails only at the server.
8. **Add test coverage for the zero-test operational roles** (Librarian, Matron, HR, Discipline, Games, Religion, Inventory) — prioritize Librarian and HR first since they involve records/financial-adjacent data (fines, payroll handoff).
9. **Decide and implement dedicated dashboard routes for Admissions and Registrar**, or explicitly document that the shared `/staff/dashboard` is the intended experience for these roles.
10. **Build out Gate Ops' two placeholder screens** (`pickup_release_screen.dart`, `gate_ops_minimal_dashboard_screen.dart`) given the module's real underlying verification logic is already tested and ready to be surfaced.
11. **Wire Director's analytics/reporting screens to real data sources** (8 screens with TODO-marked placeholder series) — lower priority than the above per the brief's "UI polish only after functionality is proven" rule, but tracked here since it's a known, self-documented gap.

---

## 18. Explicit List of Items That Must Not Be Touched Yet

- Victor's entire uncommitted working-tree diff (splash assets, firestore.rules/indexes WIP, functions/index.js + report_card_release.js WIP, router.dart, dean/teacher/notifications feature WIP, injection_container.dart, main.dart, pubspec.lock/yaml, the deleted class_tasks_bloc/class_teacher_tasks_screen + new class_teacher_more_screen.dart) — left completely untouched throughout this audit.
- All 8 stashes — untouched.
- All worktrees under `.claude/worktrees/` and `/private/tmp/` — untouched, not opened.
- The stray `.git/REBASE_HEAD` artifact — left as-is; not cleaned up (out of scope, and its removal is a git-state mutation this audit is not authorized to perform).
- `firestore.rules`, `storage.rules`, and all dependency lockfiles — read only, never weakened or upgraded.
- No `git add`, `commit`, `push`, `deploy`, `stash push/pop/apply/drop`, `reset`, `checkout` (except read-only `git show`), `switch`, `clean`, `restore`, `merge`, `rebase`, or `pull` was run at any point.

---

## 19. Files Changed During This Audit

- **Created:** `docs/audits/DAY_1_ROLE_AUDIT.md` (this file) and the `docs/audits/` directory.
- **Generated but not staged (build/test artifacts, safe to ignore or clean at Victor's discretion):** `build/web/` (from `flutter build web --release`), any `.dart_tool/` incremental-compiler caches touched by `flutter test`/`flutter analyze`, `functions/firestore-debug.log` / `public_functions/firebase-debug.log` if newly written by the attempted (and failed) emulator commands. None of these were staged or committed.
- **Nothing else in the repository was modified.**

---

## 20. Final Git Status (proving existing work and stashes were preserved)

`git status --short --branch` (re-run at the end of this audit):

```
## structure-module...origin/structure-module
 M android/app/src/main/res/drawable-hdpi/splash.png
 M android/app/src/main/res/drawable-mdpi/splash.png
 M android/app/src/main/res/drawable-night-hdpi/splash.png
 M android/app/src/main/res/drawable-night-mdpi/splash.png
 M android/app/src/main/res/drawable-night-xhdpi/splash.png
 M android/app/src/main/res/drawable-night-xxhdpi/splash.png
 M android/app/src/main/res/drawable-night-xxxhdpi/splash.png
 M android/app/src/main/res/drawable-xhdpi/splash.png
 M android/app/src/main/res/drawable-xxhdpi/splash.png
 M android/app/src/main/res/drawable-xxxhdpi/splash.png
 M assets/splash/splash_dark_mode.png
 M assets/splash/splash_light_mode.png
 M firestore.indexes.json
 M firestore.rules
 M functions/index.js
 M functions/report_card_release.js
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark@2x.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark@3x.png
 M lib/app/router.dart
 M lib/core/platform/isar_bootstrap_mobile.dart
 M lib/design_system/components/google_glyph.dart
 M lib/features/attendance_hub/presentation/widgets/attendance_sync_lifecycle_gate.dart
 M lib/features/auth/data/models/user_model.dart
 M lib/features/auth/data/services/app_role_session_service_impl.dart
 M lib/features/branding/presentation/screens/splash_screen.dart
 M lib/features/dean/data/datasources/dean_remote_data_source.dart
 M lib/features/dean/domain/entities/assessment_moderation.dart
 M lib/features/dean/presentation/screens/assessments/assessments_overview_screen.dart
 M lib/features/dean/presentation/screens/more/dean_more_screen.dart
 M lib/features/dean/presentation/screens/operations/todays_operations_screen.dart
 M lib/features/dean/presentation/screens/workload/teacher_workload_screen.dart
 M lib/features/dean/presentation/shell/dean_shell.dart
 M lib/features/notifications/data/models/notification_isar.g.dart
 M lib/features/notifications/data/models/notification_token_isar.g.dart
 M lib/features/notifications/domain/entities/notification_category_config.dart
 M lib/features/notifications/domain/entities/notification_model.dart
 M lib/features/notifications/presentation/screens/notification_list_screen.dart
 M lib/features/notifications/routing/authorization/notification_authorization.dart
 M lib/features/notifications/routing/deep_link_router/notification_deep_link_router.dart
 M lib/features/notifications/routing/deep_link_router/notification_destination.dart
 M lib/features/shared/shell_screen.dart
 M lib/features/student/presentation/screens/admin_student_directory_screen.dart
 M lib/features/teacher/attendance_screen.dart
 M lib/features/teacher/class_analytics_screen.dart
 M lib/features/teacher/dashboard_screen.dart
 M lib/features/teacher/data/datasources/teacher_remote_data_source.dart
 M lib/features/teacher/data/repositories/class_work_repository_impl.dart
 M lib/features/teacher/homework_screen.dart
 D lib/features/teacher/presentation/bloc/class_tasks/class_tasks_bloc.dart
 M lib/features/teacher/presentation/bloc/class_timetable/class_timetable_bloc.dart
 M lib/features/teacher/presentation/bloc/class_work/class_work_bloc.dart
 M lib/features/teacher/presentation/bloc/teacher_timetable/teacher_timetable_bloc.dart
 D lib/features/teacher/presentation/screens/class_teacher_tasks_screen.dart
 M lib/features/teacher/presentation/screens/classes/class_students_list_screen.dart
 M lib/features/teacher/presentation/screens/report_making/reports_dashboard_screen.dart
 M lib/features/teacher/presentation/screens/resources/folders_screen.dart
 M lib/features/teacher/presentation/widgets/responsibility_switcher_sheet.dart
 M lib/features/teacher/teacher_student_profile_screen.dart
 M lib/injection_container.dart
 M lib/main.dart
 M pubspec.lock
 M pubspec.yaml
 M test/features/auth/domain/services/app_role_session_service_impl_test.dart
 M web/index.html
 M web/splash/img/dark-1x.png
 M web/splash/img/dark-2x.png
 M web/splash/img/dark-3x.png
 M web/splash/img/dark-4x.png
 M web/splash/img/light-1x.png
 M web/splash/img/light-2x.png
 M web/splash/img/light-3x.png
 M web/splash/img/light-4x.png
?? docs/audits/
?? lib/features/teacher/presentation/screens/class_teacher_more_screen.dart
```

(The only new entry versus the audit's starting state is `?? docs/audits/`, containing this one file, plus whatever untracked build artifacts `flutter build web`/`flutter test` may have left under `build/` — those are gitignored build outputs, not shown by `git status` as tracked changes beyond what's listed above, confirming no source file was altered.)

`git stash list --date=local` (re-run at the end):

```
stash@{Sat Aug 29 01:30:07 2026}: WIP on structure-module: c2c205c9 chore(finance): remove dead screens + form-primitive tests (audit area 8)
stash@{Sat Aug 22 00:29:30 2026}: WIP on worktree-agent-abf93cab36b9ce451: 73b1c0c6 fix(router): use dean shell navigation
stash@{Fri Aug 21 19:04:17 2026}: On structure-module: WIP reports_dashboard_screen.dart before agent-branch merge
stash@{Wed Aug 19 12:24:22 2026}: On worktree-agent-a92e9e63389aabdec: admissions polish worktree wip
stash@{Mon Aug 17 21:08:54 2026}: On structure-module: temporary before NFC update
stash@{Tue Aug 11 21:38:02 2026}: On structure-module: victor's in-progress work (pre email-system build)
stash@{Fri Aug 7 21:20:14 2026}: On structure-module: pre-gate_ops-rebuild: in-progress loader/misc work
stash@{Fri Aug 7 12:48:06 2026}: On messaging-functionality: pre-rebuild-add-school-safety-snapshot
```

All 8 stashes present, unchanged, in the same order — confirmed preserved.

---

## Day 2 — Release-Gate Repair

**Role-count correction (confirmed made):** the Day 2 correction note added near the top of §1 reads: *"Day 1 undercounted the role total by one and carried a literal duplicate row in the §7 matrix ("Super Admin" and "Platform Owner (superAdmin)" both referring to the same enum value). The canonical `UserRole` enum in `lib/core/user_roles.dart` has 27 values, not 26. The duplicate matrix row has been removed and all "26" role-count references below corrected to 27; no other Day 1 findings were altered."* All three stray "26 role(s)" occurrences (§1, §4, §7's honesty note) were corrected to 27. Verified: §4's role inventory table has exactly 27 rows (`parent` through `superAdmin`); §7's Role Release Matrix has exactly 27 rows (231–257), no duplicate.

### Items 1–8 status

1. **Fix `platform_owner_access_screen.dart` compile errors — ALREADY DONE, not by me.** On inspection the file (now at `lib/features/super_admin/presentation/login_flow/platform_owner_access_screen.dart` after Victor's own in-progress move) already compiled cleanly (`flutter analyze` on it: 0 issues). It was part of Victor's uncommitted WIP, already fixed there before this session started. No edit needed or made.
2. **Run the 5 previously-blocked test files, then full suite — DONE, with a correction to Day 1's diagnosis.** Only one of the five files Day 1 implicated (`test/features/attendance_hub/presentation/widgets/attendance_sync_lifecycle_gate_test.dart`) and the nurse file (`nurse_clinic_visits_screen_test.dart`) were actually blocked by the platform-owner compile error, and both now pass standalone (3/3 and 13/13). The two enrollment-setup files (`enrollment_setup_wizard_bloc_test.dart`, `enrollment_setup_wizard_integration_test.dart`) fail to load for an **unrelated, independent, pre-existing compile error**: they reference `ParentLinkRequested` and a `parentLinkSkippedFlag` parameter that do not exist anywhere in `lib/features/student/presentation/enrollment_setup/bloc/enrollment_setup_wizard_state.dart` — Day 1's attribution of this to the platform-owner defect was incorrect. `structure_setup_theme_layout_test.dart` compiles fine but has 2 genuine content-assertion failures (`"Institution Settings"` text not found) unrelated to the platform-owner defect. None of these three files are named in items 1–8, so per scope they were left untouched (reported as findings, not fixed).
3. **`test/app/router_owner_staff_gate_test.dart` — DONE, test fixed (not the router).** The router guard at `lib/app/router.dart:519-524` is correct and safe: it redirects a superAdmin session away from `/staff/login` and every `/staff/*` route, positioned before the `/super-admin` protection block (line 527) exactly as required. The test's own assertion string was stale — it checked for `return '/school-bootstrap'`, a route that does not exist anywhere in `router.dart` (only `/school-splash` does, and the router's own comment at line 518 documents the `/school-splash -> /super-admin` path). Fixed the test's expected string from `/school-bootstrap` to `/school-splash`. Before: 1/2 passing. After: 2/2 passing.
4. **JDK 21 — DONE, no install needed.** `openjdk@21` (21.0.12.1) was already present via Homebrew at `/opt/homebrew/opt/openjdk@21`, alongside `openjdk@17` (untouched) and a default `openjdk` (26.0.1, also untouched — `/usr/libexec/java_home -V` reports no JDK registered at the system level, confirming nothing was changed system-wide). No `brew install`, no sudo, no privilege escalation was needed or attempted. `JAVA_HOME` was exported only within the shell invocations used to run `firebase emulators:exec`/`npm run test:*:emulator` commands in this session — never set globally, never written to any dotfile or system config.
5. **Rules + storage + Functions emulator suites — DONE (unblocked by item 4).**
   - `npm run test:rules` (Firestore rules): **233 passed, 0 failed** (vs. Day 1's historical baseline of 189/42 and Day 1's own fully-blocked attempt — this is a large improvement, not a regression).
   - `npm run test:storage-rules`: **18 passed, 0 failed** (vs. historical baseline 11/11 — suite has grown, still fully green).
   - All 12 Functions emulator suites (`test:report-card-engine`, `test:report-card-workflow`, `test:report-card-bursar`, `test:report-card-release-exceptions`, `test:student-fee-billing`, `test:payment-codes`, `test:finance-governance`, `test:finance-operations`, `test:finance-reconciliation`, `test:health-clinic`, `test:financial-entitlements`, `test:create-staff-account`, plus the new `test:create-parent-access-code` from item 6): **197 tests, 197 passed, 0 failed** combined across all twelve. No rule or Cloud Function logic was weakened to pass anything — all passed as-is.
6. **Parent–learner reallocation write path — DONE, found and tested, with a scope finding.** The write path is `exports.createParentAccessCode` in `functions/index.js:2283`, the only Cloud Function that writes to `parent_learner_links` (confirmed via `rg -i "parent.?learner|reassign|relink|reallocat"` across `functions/*.js`, excluding `node_modules`). It enforces the max-two-parents invariant in a transaction (`functions/index.js:2319-2322`, `"failed-precondition"` if `active.length >= 2`, correctly excluding `revoked` links from the count) and gates on `PARENT_INVITE_ADMIN_ROLES`. **Finding:** this set is `{director, headTeacher, deputyHead, schoolAdmin, admissions, registrar}` (`functions/index.js:2240-2242`) — six roles, not just School Admin as the brief's stated security model says ("Only a school administrator can reallocate an existing parent–learner relationship"). This is a genuine discrepancy between the stated policy and the implemented one; I did not narrow the server-side role set myself since that's a policy decision outside item 6's "confirm and test" instruction, not a "fix this" instruction — flagging for Victor's explicit decision rather than silently changing production authorization. Added `functions/test/create_parent_access_code.emulator.test.cjs` (5 tests: non-admin caller rejected, unauthenticated caller rejected, admin caller succeeds and writes a `pending` link, third parent on a learner with two active links rejected, a revoked link does not count toward the cap) and the `test:create-parent-access-code:emulator` npm script. Result: **5/5 passing**.
7. **Deputy Head invite-staff UI gating — DONE.** Found three unconditional entry points into `/staff/admin/users/add-staff` that had no role check at all: the FAB and empty-state CTA in `lib/features/admin/presentation/pages/staff_list_page.dart`, the "Add Staff" quick-add tile in `lib/features/admin/presentation/widgets/admin_quick_add_sheet.dart`, and the "Add Staff" quick-action tile in `lib/features/admin/presentation/pages/user_management_page.dart`. All three now check `authState.user.roles.any(UserRoleDisplay.adminRoles.contains)` (the same narrow, server-verified set already used correctly inside the wizard's own Confirm-step gate, `AddStaffWizardController.canSubmit`, and in `staff_detail_screen.dart`'s edit-staff icon) and hide/omit the action for Deputy Head rather than let it navigate into a wizard that always fails at the end. Updated `test/admin_quick_add_sheet_test.dart` (it previously had no `AuthBloc` provider at all, which would have thrown once the widget started reading auth state) with two tests: schoolAdmin sees all 5 quick-add actions; Deputy Head sees all of them except "Add Staff". Result: **2/2 passing**. Server-side permissions were not touched.
8. **Attendance offline-queue failures — DONE, confirmed a pure test-fixture defect, mock fixed, production code verified sound.** `_MockStudentRepository` in `test/features/attendance_hub/data/attendance_offline_queue_test.dart` was instantiated with no stub for `getAllStudents`, but `AttendanceRepositoryImpl.markAttendance` unconditionally calls `_validateStudentPlacement`, which calls `studentRepository.getAllStudents(schoolId: ...)` on every write for student-category records (`lib/features/attendance_hub/data/repositories/attendance_repository_impl.dart:109,165,201-202`) — exactly the Day 1 diagnosis. Added a `rosterStudent` fixture matching the test's canonical record (`personId: student-a`, `classId: class-a`, `status: active`) and stubbed `getAllStudents` to return it in `setUp`. No production code was touched. Separately verified (by reading, not just trusting tests): tenant scoping is preserved on queued writes (`getPending(schoolId)`, `watchRecords(schoolId, ...)`, remote doc path scoped by `record.schoolId`); the idempotency key `buildAttendanceRecordId` = `category_scopeId_sessionType_date_personId` (`attendance_remote_data_source.dart:8-18`) is scoped by learner+scope+action-type and deterministic, preventing duplicates both locally (`cacheIfAbsent` throws `LocalDuplicateAttendanceException` on an existing id) and remotely (`DuplicateAttendanceException`); and Parent/web attendance access stays online-only with zero persistent caching — `AttendanceLocalDataSourceWeb` (`attendance_local_data_source_web.dart`) never actually caches anything, matching the stated no-persistent-sensitive-caching-on-web-for-parents policy. **Finding, not fixed:** no stale/revoked-queue-entry eviction mechanism exists anywhere in `lib/features/attendance_hub/` (`rg` for `removeStale|evict|expire|TTL|maxRetries|revoked` in that directory returns nothing) — a pending record that becomes stale or is tied to a revoked session is never purged, only ever retried on the next sync sweep. This is a real gap against the brief's stated requirement, but building an eviction mechanism is new infrastructure, not a narrow fix, so it was left as a finding rather than built. Before: largely failing with `type 'Null' is not a subtype of type 'Future<Either<Failure, List<Student>>>'`. After: **13/13 passing**.

### Files changed

- `docs/audits/DAY_1_ROLE_AUDIT.md` — role-count correction (26→27) + this Day 2 section.
- `test/app/router_owner_staff_gate_test.dart` — fixed a stale route-name assertion (`/school-bootstrap` → `/school-splash`); the router guard itself needed no change.
- `functions/test/create_parent_access_code.emulator.test.cjs` — new file; tests the actual parent-learner-links write path (item 6).
- `functions/package.json` — added the `test:create-parent-access-code:emulator` script.
- `lib/features/admin/presentation/widgets/admin_quick_add_sheet.dart` — hide "Add Staff" for roles outside `UserRoleDisplay.adminRoles` (item 7).
- `lib/features/admin/presentation/pages/staff_list_page.dart` — hide the "Add Staff" FAB and empty-state CTA for the same roles (item 7).
- `lib/features/admin/presentation/pages/user_management_page.dart` — omit the "Add Staff" quick-action tile for the same roles (item 7).
- `test/admin_quick_add_sheet_test.dart` — rewritten to provide a real `AuthBloc` (it had none) and assert the new Deputy Head gating (item 7).
- `test/features/attendance_hub/data/attendance_offline_queue_test.dart` — stubbed the previously-unstubbed `_MockStudentRepository.getAllStudents` (item 8); no production file changed.

No other file was edited. Every other modified/deleted/renamed path shown in `git status` below was already part of Victor's pre-existing uncommitted work before this session began (splash assets, teacher module refactor, notifications, dean module, super_admin move, etc.) and was read at most, never written, during this session.

### Before/after test results

| Fix | Command | Before | After |
|---|---|---|---|
| Item 3 (router test) | `flutter test test/app/router_owner_staff_gate_test.dart` | 1 passed, 1 failed | **2 passed, 0 failed** |
| Item 6 (parent-learner-links) | `cd functions && npm run test:create-parent-access-code:emulator` | (test file did not exist) | **5 passed, 0 failed** |
| Item 7 (Deputy Head gating) | `flutter test test/admin_quick_add_sheet_test.dart` | 1 test, no role coverage, would now throw `ProviderNotFoundException` once role-aware | **2 passed, 0 failed** |
| Item 8 (attendance offline queue) | `flutter test test/features/attendance_hub/data/attendance_offline_queue_test.dart` | Multiple failures: `type 'Null' is not a subtype of type 'Future<Either<Failure, List<Student>>>'` | **13 passed, 0 failed** |

### Final full-suite results

- **`flutter analyze lib/`**: **0 errors, 10 warnings, 250 info = 260 total issues** (same total as Day 1's baseline — no new issues introduced by this session's edits).
- **`flutter test` (full suite)**: **1631 passed, 17 failed** (vs. Day 1's 1607 passed / 26 failed — net +24 passing, −9 failing). All 17 remaining failures are pre-existing and unrelated to items 1–8: `structure_setup_engine_extended_test.dart` (fails to load, pre-existing), `enrollment_setup_wizard_bloc_test.dart` / `enrollment_setup_wizard_integration_test.dart` (fail to load — independent `ParentLinkRequested`/`parentLinkSkippedFlag` compile defect described under item 2 above, not in scope), `structure_setup_theme_layout_test.dart` (2 content-assertion failures, not in scope), plus scattered pre-existing content/rendering-assertion failures in `attendance_repository_impl_test.dart`, `notification_list_screen_test.dart`, `month_calendar_grid_test.dart`, and others not named in items 1–8. None of these were introduced by this session; all touch modules/files this brief explicitly did not authorize editing.
- **Firestore rules tests** (`npm run test:rules`): **233 passed, 0 failed**.
- **Storage rules tests** (`npm run test:storage-rules`): **18 passed, 0 failed**.
- **Functions emulator suites** (12 suites): **197 tests, 197 passed, 0 failed** combined.
- **`flutter build web --release`**: **succeeded** (`✓ Built build/web`, ~99s compile).

### Remaining blockers

- **None for items 1–8 as scoped.** Item 4 (JDK 21) succeeded without any real blocker — it was already installed.
- **Out-of-scope findings surfaced, not fixed** (see items 2, 6, 8 above for detail): (a) `enrollment_setup_wizard_bloc_test.dart`/`enrollment_setup_wizard_integration_test.dart` reference a `ParentLinkRequested` bloc event and `parentLinkSkippedFlag` state field that don't exist in the current enrollment-setup bloc/state — a real, separate compile defect Day 1 misattributed to the platform-owner screen; (b) `structure_setup_theme_layout_test.dart` has 2 genuine content-assertion failures ("Institution Settings" text not found); (c) `createParentAccessCode`'s admin gate is 6 roles wide, not School-Admin-only as the stated security brief describes — a policy question for Victor, not something I resolved unilaterally; (d) no stale/revoked attendance-queue eviction mechanism exists in `lib/features/attendance_hub/` — a real gap against the offline-queue brief, left unbuilt since it's new infrastructure, not a narrow fix.

### Final git status

```
## structure-module...origin/structure-module
 M android/app/src/main/res/drawable-hdpi/splash.png
 M android/app/src/main/res/drawable-mdpi/splash.png
 M android/app/src/main/res/drawable-night-hdpi/splash.png
 M android/app/src/main/res/drawable-night-mdpi/splash.png
 M android/app/src/main/res/drawable-night-xhdpi/splash.png
 M android/app/src/main/res/drawable-night-xxhdpi/splash.png
 M android/app/src/main/res/drawable-night-xxxhdpi/splash.png
 M android/app/src/main/res/drawable-xhdpi/splash.png
 M android/app/src/main/res/drawable-xxhdpi/splash.png
 M android/app/src/main/res/drawable-xxxhdpi/splash.png
 M assets/splash/splash_dark_mode.png
 M assets/splash/splash_light_mode.png
 M firestore.indexes.json
 M firestore.rules
 M functions/index.js
 M functions/package.json
 M functions/report_card_release.js
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark@2x.png
 M ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark@3x.png
 M lib/app/router.dart
 M lib/core/platform/isar_bootstrap_mobile.dart
 M lib/design_system/components/google_glyph.dart
 M lib/features/admin/presentation/pages/staff_list_page.dart
 M lib/features/admin/presentation/pages/user_management_page.dart
 M lib/features/admin/presentation/widgets/admin_quick_add_sheet.dart
 M lib/features/attendance_hub/presentation/widgets/attendance_sync_lifecycle_gate.dart
 M lib/features/auth/data/models/user_model.dart
 M lib/features/auth/data/services/app_role_session_service_impl.dart
 M lib/features/branding/presentation/screens/splash_screen.dart
 M lib/features/dean/data/datasources/dean_remote_data_source.dart
 M lib/features/dean/domain/entities/assessment_moderation.dart
 M lib/features/dean/presentation/screens/assessments/assessments_overview_screen.dart
 M lib/features/dean/presentation/screens/more/dean_more_screen.dart
 M lib/features/dean/presentation/screens/operations/todays_operations_screen.dart
 M lib/features/dean/presentation/screens/workload/teacher_workload_screen.dart
 M lib/features/dean/presentation/shell/dean_shell.dart
 M lib/features/notifications/data/models/notification_isar.g.dart
 M lib/features/notifications/data/models/notification_token_isar.g.dart
 M lib/features/notifications/domain/entities/notification_category_config.dart
 M lib/features/notifications/domain/entities/notification_model.dart
 M lib/features/notifications/presentation/screens/notification_list_screen.dart
 M lib/features/notifications/push/handlers/notification_push_handler.dart
 M lib/features/notifications/routing/authorization/notification_authorization.dart
 M lib/features/notifications/routing/deep_link_router/notification_deep_link_router.dart
 M lib/features/notifications/routing/deep_link_router/notification_destination.dart
 M lib/features/shared/shell_screen.dart
 M lib/features/student/presentation/screens/admin_student_directory_screen.dart
RM lib/features/auth/login_flow/platform_owner_access_screen.dart -> lib/features/super_admin/presentation/login_flow/platform_owner_access_screen.dart
 M lib/features/super_admin/presentation/pages/super_admin_overview_screen.dart
 M lib/features/teacher/attendance_screen.dart
 M lib/features/teacher/class_analytics_screen.dart
 M lib/features/teacher/dashboard_screen.dart
 M lib/features/teacher/data/datasources/teacher_remote_data_source.dart
 M lib/features/teacher/data/repositories/class_work_repository_impl.dart
 M lib/features/teacher/homework_screen.dart
 D lib/features/teacher/presentation/bloc/class_tasks/class_tasks_bloc.dart
 M lib/features/teacher/presentation/bloc/class_timetable/class_timetable_bloc.dart
 M lib/features/teacher/presentation/bloc/class_work/class_work_bloc.dart
 M lib/features/teacher/presentation/bloc/teacher_timetable/teacher_timetable_bloc.dart
 D lib/features/teacher/presentation/screens/class_teacher_tasks_screen.dart
 M lib/features/teacher/presentation/screens/classes/class_students_list_screen.dart
 M lib/features/teacher/presentation/screens/report_making/reports_dashboard_screen.dart
 M lib/features/teacher/presentation/screens/resources/folders_screen.dart
 M lib/features/teacher/presentation/widgets/responsibility_switcher_sheet.dart
 M lib/features/teacher/teacher_student_profile_screen.dart
 M lib/injection_container.dart
 M lib/main.dart
 M pubspec.lock
 M pubspec.yaml
 M test/admin_quick_add_sheet_test.dart
 M test/app/router_owner_staff_gate_test.dart
 M test/features/attendance_hub/data/attendance_offline_queue_test.dart
 M test/features/auth/domain/services/app_role_session_service_impl_test.dart
 M web/index.html
 M web/splash/img/dark-1x.png
 M web/splash/img/dark-2x.png
 M web/splash/img/dark-3x.png
 M web/splash/img/dark-4x.png
 M web/splash/img/light-1x.png
 M web/splash/img/light-2x.png
 M web/splash/img/light-3x.png
 M web/splash/img/light-4x.png
?? docs/audits/
?? functions/test/create_parent_access_code.emulator.test.cjs
?? lib/features/teacher/presentation/screens/class_teacher_more_screen.dart
```

All 8 pre-existing stashes (`git stash list`) confirmed present, unchanged, in the same order as Day 1.

### Explicit confirmation

- **No deployment occurred** — `firebase deploy` was never run.
- **No commit was made** — `git commit` was never run.
- **No push was made** — `git push` was never run.
- **No stash was pushed, popped, applied, or dropped** — `git stash` (beyond the read-only `git stash list`) was never run.
- **No rebase, reset, merge, pull, or checkout/switch was run** — only read-only `git status`, `git diff`, `git log`, and `git stash list` were used for git operations throughout this session.
