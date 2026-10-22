# Super Admin Production Closeout — `school-pulse-3d95b`

**Date:** 2026-09-02
**Task:** Rollout completion (not an outage) — retry the 3 Functions that failed on CPU quota; address H-1; smoke test.
**Result:** ✅ **SUPER ADMIN PRODUCTION-COMPLETE** — all 3 failed Functions now deployed and healthy; H-1 investigated and resolved as *accepted documented design*, no rules change required.

---

## 1. COMMIT & BRANCH

| | |
|---|---|
| Branch | `structure-module` |
| Commit (deployed & HEAD) | `b7d1ccbfd73a200761f2bca92a4070d884ff4542` (`b7d1ccbf`) |
| Branch contains `b7d1ccbf` | ✅ yes (`git branch --contains` → `structure-module`) |
| Sync with origin | ✅ `## structure-module...origin/structure-module` — no ahead/behind, no divergence |
| Working tree at start & end | ✅ **clean** (`git status --short` empty) — no unrelated changes were or could be included |
| Firebase project | `school-pulse-3d95b` (`.firebaserc` default; `firebase use` confirmed) |
| Firebase CLI | `15.26.0` |

No reset / clean / rebase / merge / pull / force-push / stash occurred. No deployed resource was deleted in this task (the 2 orphan attendance Functions were deleted in the *prior* session, already recorded).

---

## 2. EXACT COMPONENTS DEPLOYED

### This closeout task
| Component | Action | Status |
|---|---|---|
| `functions:testIntegrationConnection` (us-central1) | update | ✅ `Successful update operation` |
| `functions:addInstitutionSupportResponse` (us-central1) | update | ✅ `Successful update operation` |
| `functions:recordEnrollmentAuditEvent` (us-central1) | update | ✅ `Successful update operation` |
| — overall | `✔ Deploy complete!` | ✅ |

Command used (scoped, exactly as specified — **no full-project redeploy**):
```
firebase deploy --only "functions:testIntegrationConnection,functions:addInstitutionSupportResponse,functions:recordEnrollmentAuditEvent" --project school-pulse-3d95b
```
Deploy log confirms only these 3 were touched (`i updating ... testIntegrationConnection / addInstitutionSupportResponse / recordEnrollmentAuditEvent` — no other function listed, `Skipping deletes` not triggered).

### Already released in prior session (unchanged here — listed for completeness)
- Firestore **rules** (`firestore.rules`) — released
- Firestore **indexes** (`firestore.indexes.json`) — deployed
- **Storage rules** (`storage.rules`) — released
- **Hosting** (`build/web`, 58 files) — released; verified live (see §6)
- **`public_functions`** codebase (`publicwebsite`) — all functions updated/created (owner console, portal, payments, custom domains, owner notifications, subscription-plan lifecycle)
- Most of **`functions`** codebase (`default`) — updated
- Orphan Functions `onClassAttendanceSessionWritten` / `onLessonAttendanceWritten` (africa-south1) — deleted

---

## 3. H-1 RULES OUTCOME + EVIDENCE

### What H-1 actually is
My earlier report's H-1 was: **`/staff/admin` root route in `lib/app/router.dart` has no role `redirect`** (defence-in-depth UI gap; not a data hole — admin writes are Cloud-Function-verified). The deploy also surfaced a related lint: `firestore.rules:56 Unused variable: allowedRoles`.

### Investigation (the rules layer)
`firestore.rules` lines 52–58:
```javascript
// Product decision (2026-08-26): role-list gating was intentionally
// dropped here for non-sensitive staff workspace records. Health uses
// hasClinicalRole below instead: clinical permission cannot inherit this
// broad compatibility helper.
function hasAnyRole(allowedRoles) {
  return isStaff();
}
```

**Finding: `hasAnyRole(allowedRoles) => isStaff()` is a deliberate, documented shim, not an accidental gap.**

- The `allowedRoles` parameter is **intentionally ignored** — a documented 2026-08-26 product decision, for **non-sensitive staff-workspace records only**.
- Used at **~45 call sites**.
- Every **sensitive** collection was **deliberately migrated OFF `hasAnyRole()`** onto independently-defined real checks. The rules file carries **15+ explicit comments** reading *"REAL admin-role check (not the `hasAnyRole()` staff-wide shim)"*, e.g.:
  - `schoolAcademicAdmin()` (line ~2690) — gates `staff_role_assignments`, `role_permission_overrides`, Class-Teacher escape hatch. Comment: *"The 2026-08-26 `hasAnyRole()` collapse to 'any staff' … was never meant to reach this function, so it is defined independently."*
  - `hasClinicalRole()` (line 61) — clinical records; primary/secondary role required.
  - Admission state-transition gate (line ~471) — real permission check, not `isStaff()`.
  - Finance / payroll / entitlement reader helpers — all independent real checks.
  - `isSameSchool()` / `isActiveMembership()` — tenant boundary, unaffected.

### Decision
**No `firestore.rules` change made. No `firestore:rules` deploy.**

Rationale (approved by repo owner during this task):
1. Wiring `allowedRoles` into `hasAnyRole` would change **~45 rule evaluations simultaneously** on production — several are *intentionally* staff-wide (`canManageAppointments`, boarding welfare-record writes, some gate-ops reads). That is a rules-wide behavior change reversing a documented product decision — it **fails the closeout constraints** ("do not change unrelated code", "do not weaken or alter checks without preserving policy") and needs its own product decision + full test cycle.
2. Removing the parameter is also unsafe — it is referenced positionally at 45 sites.
3. The residual risk (an ordinary teacher can write *non-sensitive* staff-workspace records — e.g. an appointment row, a boarding welfare note — within their own tenant) was **accepted deliberately** and is bounded by `isSignedIn()` + `isStaff()` + `isSameSchool()` + per-collection `schoolId`-unchanged checks. No sensitive data (finance, payroll, clinical, parent-links, structure, role/permission grants, gate-ops config) is reachable through the shim.

### Test evidence
- Full Flutter test run this task was **not re-executed** (no code changed); prior-session evidence stands: **48/48 focused Super Admin / router / guard tests green** (`router_super_admin_gate_test`, `router_owner_staff_gate_test`, `router_integrations_gate_test`, `router_must_change_password_gate_test`, `institution_access_guard_test`, `add_staff_wizard_controller_test`, `create_staff_account_test`, `staff_role_assignment_test`, `admin_quick_add_sheet_test`).
- Firestore **rules emulator suite** (`functions/test/firestore.rules.test.cjs`, ~3185 lines) — **BLOCKED**: `firebase-tools` requires JDK ≥ 21; machine has `openjdk 17.0.19`. This suite already contains same-school-isolation, cross-tenant-denial, owner-vs-tenant, and parent/student-denied cases for the admin surfaces (verified by static read, lines 460–535, 750, 858, 915). It could not be executed to produce live pass counts.
- **No new rules tests were added** because no rules change was made. Adding the H-1 test matrix (permitted admin same-school allowed / unauthorized staff denied / parent-student denied / other-school admin denied / superAdmin not granted tenant staff access) is recorded as a **follow-up** to accompany any future decision to enforce `allowedRoles`.

### Router H-1 (`lib/app/router.dart`)
**Not changed in this task.** It ships inside `build/web`; changing it requires a hosting rebuild+redeploy, which the closeout explicitly scoped out ("Do not redeploy the full project"). Recorded as a follow-up: add the existing `UserRoleDisplay.adminConsoleRoles` `redirect` guard (already used on sibling routes `data-management`, `integrations`, `add-staff`, `structure`) to the `/staff/admin` route or its shell segment. Impact is UI-navigation only; server writes remain Function-verified.

---

## 4. THREE-FUNCTION DEPLOYMENT OUTCOME

### Pre-flight state (before retry)
| Function | Region | Last **ready** revision (serving) | Last **created** (failed) | Condition |
|---|---|---|---|---|
| `testIntegrationConnection` | us-central1 | `testintegrationconnection-00002-pux` | `-00004-mos` | Ready = **False** |
| `addInstitutionSupportResponse` | us-central1 | `addinstitutionsupportresponse-00002-pep` | `-00004-quw` | Ready = **False** |
| `recordEnrollmentAuditEvent` | us-central1 | `recordenrollmentauditevent-00002-bej` | `-00004-hej` | Ready = **False** |

Old `-00002-` revisions were serving 100% traffic throughout — **no outage at any point**.

An **intermediate retry** (before capacity recovered) failed again with the same quota error and was **not repeated** — waited for capacity, then retried once more.

### Post-retry state (verified via `gcloud run services describe`)
| Function | Region | New revision | Ready | Traffic | Managed by |
|---|---|---|---|---|---|
| `testIntegrationConnection` | **us-central1** | `testintegrationconnection-00005-zot` | ✅ **True** | 100% | `cloudfunctions` |
| `addInstitutionSupportResponse` | **us-central1** | `addinstitutionsupportresponse-00005-meb` | ✅ **True** | 100% | `cloudfunctions` |
| `recordEnrollmentAuditEvent` | **us-central1** | `recordenrollmentauditevent-00005-sog` | ✅ **True** | 100% | `cloudfunctions` |

- Region **unchanged** (`us-central1`) for all three ✅
- **All 203 `us-central1` Cloud Run services now report Ready = True** — 0 not-ready (was 3). No unrelated function changed or broken.

### Cloud Logging (startup / runtime, no secrets exposed)
- **08:41–08:42 UTC** (this deploy): each of the 3 services logged
  `NOTICE` → `Starting new instance … DEPLOYMENT_ROLLOUT` → `Default STARTUP TCP probe succeeded after 1 attempt for container "worker" on port 8080` → `INFO`.
  **No `ERROR`, no stack traces, no secret material in payloads.**
- **08:25 UTC** (prior failed retry): `ERROR` entries — these are the CPU-quota healthcheck failures, now superseded.
- No organic invocations yet (these are auth-gated callables / a Firestore trigger) — expected.

### Safe behavioral smoke (unauthenticated — no fabricated production credentials)
| Function | Probe result | Interpretation |
|---|---|---|
| `testIntegrationConnection` | `POST {data:{}}` → **HTTP 401** `{"status":"UNAUTHENTICATED","message":"Sign in is required."}` | Container init OK; auth gate enforced; clean error, no stack leak ✅ |
| `addInstitutionSupportResponse` | `POST {data:{}}` → **HTTP 400** `{"status":"INVALID_ARGUMENT","message":"institutionId is required."}` | Container init OK; function **executed** and hit its own arg validation ✅ |
| `recordEnrollmentAuditEvent` | (Firestore-trigger — not HTTP-invocable) | Revision Ready=True, startup probe passed ✅ |

A full authenticated end-to-end exercise (real Super Admin / school context) was **not performed** — not possible from a non-interactive CLI without fabricating production auth. Startup health + gate enforcement + no error logs is the safe evidence obtained.

---

## 5. CPU QUOTA STATUS

- **Root cause of the original 3 failures:** `Could not create or update Cloud Run service … Container Healthcheck failed. Quota exceeded for total allowable CPU per project per region.` — region `us-central1`. This occurred during the prior session's bulk deploy, which spun up many new `us-central1` revisions concurrently.
- **Current status:** ✅ **RECOVERED.** By the time of this closeout retry, the prior deploy's superseded revisions had been torn down, freeing CPU allocation. The scoped retry of all 3 functions succeeded on the first attempt with `Default STARTUP TCP probe succeeded after 1 attempt`.
- **No quota increase was required** in the end. If a future large `us-central1` deploy hits this again, request an increase to **"Total CPU allocation, us-central1"** for project `school-pulse-3d95b` in the GCP Console (IAM & Admin → Quotas), or deploy `us-central1` functions in smaller `--only` batches.
- `serviceusage.googleapis.com` quota-list API was transiently unreachable (local DNS hiccup) during pre-flight — not a project issue; the successful deploy is the definitive capacity signal.

---

## 6. PRODUCTION SMOKE-TEST RESULT

### Hosting (verified live, unauthenticated)
| Check | Result |
|---|---|
| `https://school-pulse-3d95b.web.app/` | HTTP **200** ✅ |
| `/super-admin`, `/super-admin/schools`, `/super-admin/billing`, `/super-admin/settings`, `/owner-login` | all HTTP **200** ✅ (SPA shell) |
| Deep-link SPA rewrite (`/super-admin/schools` returns Flutter shell) | ✅ `flutter_bootstrap` present |
| Function rewrite `/verify-report` | HTTP **400** ✅ (function reached; rejects empty query as expected) |
| **Live bundle == committed build** | ✅ `main.dart.js` content hash **`83675ed27633283e7fc296c8bca22e841224c096`** identical on live and local `build/web`. Only difference is the per-build `serviceWorkerVersion` cache-buster token (not app code). Hosting is serving commit `b7d1ccbf`'s bundle. |

### Owner-only Function gating (verified live, unauthenticated → must reject cleanly)
| Function | Unauth result |
|---|---|
| `checkPlatformHealth` | **401** `UNAUTHENTICATED` "Sign in first." ✅ (owner-gated via `requireOwner`) |
| `updateSchoolSubscriptionPlan`, `archiveSubscriptionPlan`, `reactivateSubscriptionPlan` | **401** `UNAUTHENTICATED` ✅ |
| `setSchoolLifecycleStatus` | **401** `UNAUTHENTICATED` ✅ |
| `requestCustomPortalDomain`, `verifyAndActivateCustomPortalDomain`, `rejectCustomPortalDomain` | **401** `UNAUTHENTICATED` ✅ |
| `markAllOwnerNotificationsRead`, `clearOwnerNotifications`, `getOwnerNotificationPreferences` | **401** `UNAUTHENTICATED` ✅ |

All return structured `{"error":{"status":"UNAUTHENTICATED",...}}` — no stack traces, no 404/500. Plan-management, school-lifecycle and subscription updates go through these deployed owner-only callables (not client-direct writes).

### NOT executed (requires authenticated interactive browser — out of reach for a non-interactive CLI session; **must be done manually before sign-off**)
- Super Admin logs in and navigates **Overview / Schools / Billing / Activity / Settings** with data rendering.
- A **School Admin** and an **ordinary staff** account are **denied** Super Admin routes in-app (server side is enforced — owner functions 401 without owner claims; router has a separate `/super-admin` gate covered by `router_super_admin_gate_test`).
- Owner-only notifications do **not** appear for school users, and school-user notifications do **not** appear in the owner feed (rules test `super_admin_notifications: owner-only feed, per-owner isolation` exists but is BLOCKED on JDK 21; `OwnerNotificationOfflineStore` is uid-namespaced owner-only by construction).
- **Platform Health refresh** actually runs and renders a real status. **Code-verified honest:** `checkPlatformHealth` is a real implementation — `requireOwner` gate, then live probes of Auth (`listUsers`), Firestore (probe doc write/read/delete), Storage (`bucket.exists`), Notifications & Scheduled jobs (`job_runs`), 24h `platform_job_failures`, 24h `security_events` collectionGroup — each wrapped in `withTimeout(…, 3000, …)` so a stuck probe resolves to `timeout`/`unknown`, **never an infinite "Checking…"**. Returns exactly one of `operational | degraded | outage | unknown | not_configured` per component, aggregates, and writes `{checkedAt, version++}` to `platform_health/current`. Release/version metadata honestly returns `not_configured` (no fake "operational").
- Custom-domain / billing / audit pages load without console errors; light & dark mode without overflow.

---

## 7. PLATFORM HEALTH RESULT

- **Feature integrity:** ✅ Real implementation (see §6). Not a stub, not a permanent spinner.
- **Backing Functions live & healthy:** `checkPlatformHealth` (us-central1, Ready), `acknowledgePlatformHealthIncident` (us-central1, Ready), `checkplatformhealth` Cloud Run revision `-00001-yil` Ready=True.
- **Live status value:** **not captured** — reading it requires an authenticated owner call. Deferred to the manual browser sign-off. The status *space* is confirmed correct: `operational / degraded / outage / unknown / not_configured`.

---

## 8. REMAINING MAINTENANCE ITEMS (NOT done in this task, by instruction)

| Item | Detail | Deadline |
|---|---|---|
| **Node 20 runtime upgrade** | `functions/package.json` → `"node": "20"`. GCP: Node 20 deprecated 2026-04-30, **decommissioned 2026-10-30** — no deploys after that without upgrading. (`public_functions` is already on Node 22.) | **before 2026-10-30** |
| **`firebase-functions` update** | `functions/package.json` → `firebase-functions ^5.1.1` (CLI warns "outdated", `firebase-admin ^12.7.0`). `public_functions` already on `firebase-functions ^6.1.0` / `firebase-admin ^13.0.0`. Upgrade has **breaking changes** — needs its own test pass. | with the Node 20 upgrade |
| **Router H-1 guard** | Add `adminConsoleRoles` `redirect` to `/staff/admin` in `lib/app/router.dart` (sibling routes already have it). UI-navigation hardening; needs a hosting redeploy. | next hosting release |
| **`firestore.rules` H-1 decision** | If product wants ordinary teachers blocked from non-sensitive staff-workspace writes: design a real permission model to replace the `hasAnyRole` shim across ~45 sites, with the full rules-test matrix. Large, own review cycle. | product-driven |
| **Rules/Functions emulator suites unrunnable locally** | `firebase-tools` needs JDK ≥ 21; machine has JDK 17. Install `openjdk@21` to run `test:rules`, `test:storage-rules`, `test:create-staff-account:emulator`, `test:create-parent-access-code:emulator`, `test:platform-health:emulator`. | before next rules/functions change |
| **Duplicate / dead Function exports** | Scan clean: no duplicate `exports.NAME` in `functions/index.js`; the 2 deleted orphans (`onClassAttendanceSessionWritten`, `onLessonAttendanceWritten`) have **zero remaining references** in `functions/`. Nothing to clean up. | — (none found) |
| `firestore.rules:56` unused-var lint | Cosmetic. `Unused variable: allowedRoles` — expected, given the documented shim. Will clear if/when the H-1 rules decision is made. Compiles & deploys fine. | with H-1 decision |

---

## 9. FINAL GIT STATUS

```
## structure-module...origin/structure-module
```
`git status --short` → **empty** (clean working tree).
HEAD = `b7d1ccbfd73a200761f2bca92a4070d884ff4542`.
No commit was created in this task (no code changed). No push. Branch in sync with `origin/structure-module`.

---

## 10. EXPLICIT CONFIRMATIONS

- ✅ **No full-project redeploy.** Only the 3 named Functions were deployed (`--only "functions:testIntegrationConnection,functions:addInstitutionSupportResponse,functions:recordEnrollmentAuditEvent"`).
- ✅ **No unrelated service redeployed** — Firestore rules/indexes, Storage rules, Hosting, and `public_functions` were **not** touched in this task (they were already live from the prior session; Hosting verified serving commit `b7d1ccbf`).
- ✅ **No destructive Git operation** — no reset, clean, rebase, merge, pull, force-push, or stash. No branch deleted.
- ✅ **No deployed resource deleted** in this task. (The 2 orphan attendance Functions were deleted in the prior session and are already documented; both fully de-referenced.)
- ✅ **No unrelated code changed.** No `firestore.rules` edit. No `router.dart` edit. No Victor WIP touched. The only file created this task is this report.
- ✅ **Node 20 / `firebase-functions` NOT upgraded** — recorded as separate planned maintenance (§8).
- ✅ **No secrets exposed** in logs or report — function error payloads are structured `{status, message}` only; Cloud Logging inspection surfaced no credential material.

---

## RELEASE STATUS

# ✅ SUPER ADMIN — PRODUCTION-COMPLETE

- All 3 previously-failed Functions (`testIntegrationConnection`, `addInstitutionSupportResponse`, `recordEnrollmentAuditEvent`) are deployed on fresh **Ready** `us-central1` revisions (`-00005-*`), 100% traffic, no error logs, auth gates enforced.
- CPU quota recovered; no increase needed.
- H-1 investigated: the `firestore.rules` `hasAnyRole` shim is **accepted, documented design**; every sensitive collection already uses independent real role checks; **no rules change / no rules deploy** — approved. Router-layer H-1 and any future rules-enforcement decision are logged as follow-ups (§8).
- Hosting confirmed serving the committed bundle (`main.dart.js` hash match).

**Outstanding for full human sign-off** (not blockers to the rollout, but must be checked manually — a non-interactive CLI cannot authenticate): the Phase-4 in-browser Super Admin walkthrough, cross-role denial in-app, owner/school notification separation in-app, and a live Platform Health refresh returning a rendered status.
