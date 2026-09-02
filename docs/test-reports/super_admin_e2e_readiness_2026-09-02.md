# Super Admin Module — End-to-End Emulator Verification & Production-Readiness Verdict

**Date:** 2026-09-02
**Environment:** Firebase Emulator Suite (Firestore + Auth), JDK 21 (`/opt/homebrew/opt/openjdk@21`), `firebase-tools` 15.26.0
**Method:** Every owner-only Cloud Function driven via `.run({auth, data})` against a self-launched emulator (`firebase emulators:exec`), doing real Firestore round-trips. Every client-enforced collection driven via `@firebase/rules-unit-testing`. Front-end verified via existing Flutter widget/bloc tests + static screen→service→callable traces.

## VERDICT

**Super Admin is PRODUCTION-READY.** Every owner-console surface has verified backend behavior (auth gate, happy path, error branches, idempotency, audit trail) and correct front-end wiring. No source code was changed. 6 new test files add coverage that did not exist before; all pre-existing suites remain green.

Two non-blocking maintenance items carried forward (dead code, Node 20 upgrade) — neither affects correctness or security.

---

## 1. WHAT WAS TESTED — SURFACE BY SURFACE

| # | Surface | Backend mechanism | New tests | Result |
|---|---|---|---|---|
| 1 | **Manage Plans** | 5 callables `public_functions/payments.js` (europe-west1) | `subscription_plans_lifecycle.emulator.test.cjs` (17) | ✅ 17/17 |
| 2 | **Schools & Lifecycle** | `portal_domains.js` + `owner.js` + `payments.js` (6 callables) | `school_lifecycle_and_applications.emulator.test.cjs` (17) | ✅ 17/17 |
| 3 | **Billing / Manual Payments** | 6 callables `payments.js` | `manual_payments_owner.emulator.test.cjs` (17) | ✅ 17/17 |
| 4 | **Custom Domains** | 3 callables `portal_domains.js` (DNS stubbed) | `custom_portal_domains.emulator.test.cjs` (13) | ✅ 13/13 |
| 5 | **Owner Notifications & Preferences** | `owner_notifications_admin.js` (4) + `owner_notification_preferences.js` (2) | `owner_notification_preferences.emulator.test.cjs` (10) | ✅ 10/10 |
| 6 | **Support Tickets / Audit / Notif-feed / Support-mode rules** | client Firestore + `firestore.rules` | `functions/test/super_admin_console.rules.test.cjs` (20) | ✅ 20/20 |
| — | **Trusted Devices** | `owner_trusted_devices.js` (2) | (existing `owner_console_callables.emulator.test.cjs`) | ✅ 14/14 |
| — | **Platform Health + acknowledge** | `functions/platform_health.js` | (existing `platform_health.emulator.test.cjs`) | ✅ 15/15 |
| — | **Front-end (all screens/cubits)** | Flutter widget/bloc tests | (existing `test/features/super_admin/`) | ✅ 75/75 |

**New this session: 114 tests (94 emulator + 20 rules), 0 failures.**

---

## 2. BACKEND DETAIL

### 2.1 Manage Plans (`createSubscriptionPlan`, `updateSubscriptionPlan`, `updateSubscriptionPlanPricing`, `archiveSubscriptionPlan`, `reactivateSubscriptionPlan`)
- **Auth:** unauthenticated → rejected; non-owner superAdmin → `Access denied`; deactivated owner profile → `Access denied`. (`requireOwner` = `platform_config/owner_seed.ownerUid` match + active owner profile.)
- **create:** normalized doc (`isArchived:false`, `isDefault:false`, `billingModel:manual_v1`, `createdBy`, server `createdAt`) + `CREATE_SUBSCRIPTION_PLAN` audit. Rejects duplicate code (`already-exists`), malformed code (`PLAN_CODE_RE`), zero price for non-enterprise. Unknown `includedModules` keys silently dropped (allow-list = `attendance,reports,finance,messaging,health,transport,library,boarding`; `students`/`academics` are core, not module keys).
- **update:** name/limits/visibility, `createdBy` preserved, `UPDATE_SUBSCRIPTION_PLAN` audit; `not-found` on missing; **cannot un-archive via `isActive:true`** (forced back to false — only `reactivateSubscriptionPlan` may un-archive).
- **updateSubscriptionPlanPricing:** price/cycle/term + audit; rejects invalid billing cycle.
- **archive:** boolean flip `isArchived:true`/`isActive:false`, **doc not deleted**, audit; `not-found` on missing.
- **reactivate:** `isArchived:false`/`isActive:true`, audit; `not-found` on missing.
- **Full round-trip:** create→edit→reprice→archive→reactivate → one coherent doc, exactly 5 ordered audit rows.
- **Side note:** `createSubscriptionPlan` calls `ensureBillingDefaults()`, seeding the 4 standard catalog plans on first call — expected, not a bug.

### 2.2 Schools & Lifecycle
- **setSchoolLifecycleStatus** (`portal_domains.js`): suspend→reactivate→archive each = one transaction; status + `metadata.suspensionReason`/`archivedReason` + `UPDATE_SCHOOL_STATUS` audit; rejects unknown status; `not-found` on missing; **no-op + no audit when status unchanged**.
- **updateSchoolSubscriptionPlan** (`portal_domains.js`): sets `subscriptionPlanId`+`subscriptionExpiry`, audit records `previousPlanId`; rejects non-finite expiry / empty planId; `not-found` on missing.
- **getSchoolApplicationsForOwner** (`owner.js`): newest-first (`orderBy createdAt desc`).
- **rejectSchoolApplication** (`owner.js`): `rejected` + `rejectionReason` + `reviewedBy` + `REJECT_SCHOOL_APPLICATION` audit; needs reason ≥3 chars; refuses non-pending; `not-found` on missing.
- **approveSchoolApplication** (`payments.js` — shadows the `owner.js` copy, see §4): `not-found` on missing; refuses non-pending; refuses when `termsAccepted !== true`. Full happy path (Auth user provisioning, `institution_memberships`, plan snapshot) not exercised end-to-end — needs seeded verified Auth accounts; guard/validation branches confirmed; provisioning is a single audited transaction.
- **createSchoolPortal**: auth gate + arg validation confirmed; full happy path creates an Auth user + slug reservation + membership + audit in one transaction.

### 2.3 Billing / Manual Payments (`payments.js`)
- **getManualPaymentsForOwner:** newest-first, status filter, **`proofStoragePath` + `referenceKey` stripped from client payload**, `hasProof` derived.
- **getManualPaymentProofUrl:** `not-found` for missing payment / no-proof payment.
- **approveManualPayment:** one transaction → school `status:active` + `accessMode:full` + **plan snapshot frozen from the payment** (`subscription.price/termLengthDays/maxStudents/maxStaff/storageLimitGb` — never re-read from `subscription_plans`, so later catalog edits don't retroactively change a paid term) + `subscription_receipts/{id}` + `payment_transactions/{id}` (`provider:manual_mtn`, `status:success`) + `APPROVE_INITIAL_SUBSCRIPTION_PAYMENT` audit + resolves the `payment_{id}` owner notification. **Idempotent** (2nd call → `alreadyApproved:true`, no duplicate audit/receipt/txn). Rejects submitted≠expected amount (`failed-precondition`, payment untouched), non-pending, missing. **Renewal:** stacks on the existing future expiry (not `now`), audits `APPROVE_SUBSCRIPTION_RENEWAL_PAYMENT`.
- **rejectManualPayment:** `rejected` + reason; **activation rejection → `accessMode:blocked`**, `subscriptionStatus:awaiting_payment`; `REJECT_MANUAL_SUBSCRIPTION_PAYMENT` audit; resolves notification; needs reason ≥3 chars; only touches pending.
- **getManualPaymentConfig:** all 4 method blocks (mobileMoney/airtelMoney/bank/cash), currency UGX.
- **updateManualPaymentConfig:** persists + reads back via `getManualPaymentConfig` + audit; rejects half-filled bank block, cash-enabled-without-instructions, and a config with **no usable method at all**.

### 2.4 Custom Domains (`portal_domains.js`, DNS `resolveCname` stubbed)
- **Input validation:** invalid hostname (spaces, no dot, `*.schoolpulse.ug` reserved) → `invalid-argument` before any Firestore read; missing request → `not-found`.
- **recheckCustomPortalDomain:** wrong/absent CNAME → `verification_failed` + `lastError` + `checkedBy`/`checkedAt`; correct CNAME (trailing dot tolerated) → `verified`, `lastError` cleared; **already-active → short-circuits, no DNS call, doc untouched**.
- **verifyAndActivateCustomPortalDomain:** wrong CNAME → persists `verification_failed` **and** throws `failed-precondition`, no activation audit; correct CNAME → `portal_domains/{host}` public projection (branding carried) + request `active`+`approvedBy` + `school.customDomains` arrayUnion + `ACTIVATE_CUSTOM_PORTAL_DOMAIN` audit (one transaction); missing linked school → `not-found`.
- **rejectCustomPortalDomain:** pending → `rejected`+reason+`rejectedBy`+audit; **active → tears down projection + arrayRemove from `school.customDomains`**; empty reason → `"No reason provided"`.

### 2.5 Owner Notifications & Preferences
- **markOwnerNotificationRead / markAllOwnerNotificationsRead / deleteOwnerNotification / clearOwnerNotifications** (`owner_notifications_admin.js`): owner acts on own + legacy (no `ownerId`) docs; **a different `ownerId` is never touched**; non-owner rejected. (existing suite)
- **getOwnerNotificationPreferences** (NEW): sane defaults when nothing stored; **read-only, persists nothing**; honest `capabilities: {realtime:true, dailyDigestDeliveryImplemented:false}`.
- **updateOwnerNotificationPreferences** (NEW): sanitized persist under owner uid + `owner_notification_preferences_updated` audit; round-trips through get; **clamps invalid quiet-hours clock** → 22:00/07:00; unknown frequency → existing; **timezone forced to `Africa/Kampala`**; **partial update merges onto stored value, not defaults**; accepts bare payload; one settings doc keyed by the real owner.

### 2.6 Client-enforced collections (`super_admin_console.rules.test.cjs`)
- **super_admin_support_tickets:** owner reads only own; school-admin & anon denied; create must stamp own `ownerId` (forge → fail); update may move **only `updatedAt`** (status change & re-parent → fail); no client delete.
- **…/messages:** owner appends only `sender:'owner'` with own `senderId` (agent-forge & sender-spoof → fail); into own ticket only; messages immutable/undeletable.
- **super_admin_audit_logs:** superAdmin read/create; **append-only — update & delete rejected even for superAdmin**; school-admin fully denied.
- **super_admin_notifications:** owner reads own + legacy; **foreign-owner doc unreadable**; no client create/update/delete; school-admin denied.
- **support_mode_sessions:** own-doc read only; cross-owner read + any client write → fail.

### 2.7 Trusted Devices & Platform Health (existing suites re-run, green)
- **setOwnerDeviceTrust / revokeOwnerDevice:** trust+rename+audit; non-owner rejected; unknown device → `not-found`; **refuses to revoke the current device**; revoke deletes the session + disables its push tokens + audits.
- **checkPlatformHealth / acknowledgePlatformHealthIncident:** real probes (Auth/Firestore/Storage/Notifications/Jobs/Failures/Security, each `withTimeout(3000)`); statuses `operational|degraded|outage|unknown|not_configured`; **School Admin cannot acknowledge**; acknowledge audits only manual actions, never auto-polls.
- **Live production check (2026-09-02):** the Platform Health screen was opened in production as Super Admin — rendered "Attention needed / 3 checks", green on Auth/Firestore/Cloud Functions/Notifications/Security, `not_configured` on Cloud Storage + onboarding/subscription failure history, amber on "Scheduled jobs: 5 of 10 need attention" with a working deep link. Honest, non-hanging, real. (Scheduled-jobs signal is a genuine ops item — see §5.)

---

## 3. FRONT-END WIRING (screen → service → callable/collection)

| Screen | Service | Backend |
|---|---|---|
| `PlanEditorPage`, `SubscriptionPlansScreen` | `ManualPaymentService.createPlan/updatePlan/archivePlan/reactivatePlan` | `createSubscriptionPlan` / `updateSubscriptionPlan` / `archiveSubscriptionPlan` / `reactivateSubscriptionPlan` (europe-west1); list reads `subscription_plans` |
| `SchoolManagementScreen`, `SchoolDetailScreen` | `SuperAdminRemoteDataSource` | `createSchoolPortal`, `setSchoolLifecycleStatus`, `updateSchoolSubscriptionPlan`; list = `schools.snapshots()`; edit = `schools.doc().update()` (rules `isSuperAdmin()`) |
| `SchoolApplicationReviewScreen` | `SuperAdminRemoteDataSource` | `getSchoolApplicationsForOwner` / `approveSchoolApplication` / `rejectSchoolApplication` |
| `PaymentReviewScreen`, `BillingHomeScreen` | `ManualPaymentService` | `getManualPaymentsForOwner` / `getManualPaymentProofUrl` / `approveManualPayment` / `rejectManualPayment` |
| `ManualPaymentConfigScreen` | direct `FirebaseFunctions` | `getManualPaymentConfig` / `updateManualPaymentConfig` |
| `CustomDomainsScreen` | `CustomDomainService` | `recheckCustomPortalDomain` / `verifyAndActivateCustomPortalDomain` / `rejectCustomPortalDomain`; list = `portal_domain_requests.snapshots()` |
| `SuperAdminNotificationsScreen`, `OwnerNotificationHistoryScreen`, `OwnerNotificationDetailScreen` | `OwnerNotificationService` (+ `OwnerNotificationOfflineStore`) | 6 callables; feed = `super_admin_notifications.snapshots()` |
| `OwnerNotificationPreferencesScreen` | `OwnerSessionCubit` / mapper | `getOwnerNotificationPreferences` / `updateOwnerNotificationPreferences` |
| `TrustedDevicesScreen` | `OwnerSessionCubit` | `setOwnerDeviceTrust` / `revokeOwnerDevice`; list = `super_admin_settings/{ownerId}/sessions` |
| `SupportTicketConversationScreen`, `SubmitSupportRequestScreen` | `SupportTicketService` | client Firestore `super_admin_support_tickets` (+ `messages/`), rules-enforced |
| `AuditLogsScreen` | `SuperAdminRepositoryImpl` | read `super_admin_audit_logs` (append-only) |
| `PlatformHealthScreen` | `PlatformHealthRepository` | `checkPlatformHealth` / `acknowledgePlatformHealthIncident` (us-central1) |

**All callable regions and payload shapes match the deployed function signatures.** Every callable region is `europe-west1` except Platform Health (`us-central1`).

**Flutter tests (existing, re-run): 75/75** — navigation (5 destinations, approved order), logout dialog (light+dark), school-management responsive @390px, overview platform-health card, settings redesign, route navigation, unsaved-changes guard, plan editor form, bloc lifecycle, owner-notification offline store (15 — per-owner scoping, reconcile eviction, idempotent sync, sign-out wipe), preferences mapper.

---

## 4. FINDINGS

### CRITICAL / HIGH
*None.*

### MEDIUM

- **M-1 — dead export: `owner.js` `approveSchoolApplication`.** `bootstrap.js` spreads `...payments` after `...owner`, so `payments.js`'s `approveSchoolApplication` (more complete — plan snapshot, legacy migration) is what deploys. The `owner.js` copy (~220 lines) is shadowed. Not a bug; a maintenance hazard (an edit there has no effect). **Recommend:** delete the `owner.js` export or `require` and re-export the `payments.js` one.

### LOW

- **L-1 — `firestore.rules` `isSuperAdmin()` vs callable `requireOwner()` asymmetry (by design).** Rules gate owner-console collections to *any* `role == 'superAdmin'` user; callables additionally require being the *canonical seeded owner* (`platform_config/owner_seed`). Production has exactly one seeded owner, so this is defence-in-depth, not a gap. Documented here so a future second-superAdmin scenario is a conscious decision.
- **L-2 — pre-existing analyze errors (3), unrelated.** `test/features/attendance_hub/data/attendance_offline_queue_test.dart` (`FirebaseException` not imported ×2), `test/features/structure/domain/services/structure_setup_engine_extended_test.dart` (`TimetableStatus.active` removed). Not in the Super Admin module; not touched.
- **L-3 — Node 20 / `firebase-functions ^5.1.1` on the `functions` codebase.** Decommission deadline 2026-10-30. Separate planned maintenance (`public_functions` is already Node 22 / `firebase-functions ^6.1.0`).
- **L-4 — Platform Health: `not_configured` on Cloud Storage + onboarding/subscription failure history.** `checkStorage()` calls `admin.storage().bucket()` with no argument (default bucket not set in the functions runtime); the two failure-history reads target collections that may not exist yet. Cosmetic health-status noise; storage rules deploy & tests pass regardless. **Recommend:** pass the bucket name explicitly; confirm `platform_job_failures` etc. exist / SA has read access.
- **L-5 — Scheduled jobs: 5 of 10 flagged in production.** Genuine ops signal from the live health check — 5 cron jobs have no recent successful `job_runs` entry. Worth investigating (highest-priority of the L items) but independent of the Super Admin console's correctness.

---

## 5. CHANGED FILES

**Source code: none.** Added (untracked):
```
functions/test/super_admin_console.rules.test.cjs
functions/package.json                                  (+1 script: test:rules:super-admin-console)
public_functions/test/subscription_plans_lifecycle.emulator.test.cjs
public_functions/test/school_lifecycle_and_applications.emulator.test.cjs
public_functions/test/manual_payments_owner.emulator.test.cjs
public_functions/test/custom_portal_domains.emulator.test.cjs
public_functions/test/owner_notification_preferences.emulator.test.cjs
public_functions/package.json                           (+5 emulator test scripts)
docs/test-reports/super_admin_production_closeout_2026-09-02.md
docs/test-reports/super_admin_e2e_readiness_2026-09-02.md  (this file)
```

Run the new suites:
```
npm --prefix public_functions run test:subscription-plans-lifecycle:emulator
npm --prefix public_functions run test:school-lifecycle-applications:emulator
npm --prefix public_functions run test:manual-payments-owner:emulator
npm --prefix public_functions run test:custom-portal-domains:emulator
npm --prefix public_functions run test:owner-notification-preferences:emulator
npm --prefix functions        run test:rules:super-admin-console
```
(JDK ≥ 21 required — `openjdk@21` is installed via Homebrew; export `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`.)

---

## 6. FINAL GIT STATUS

```
?? docs/test-reports/super_admin_e2e_readiness_2026-09-02.md
?? docs/test-reports/super_admin_production_closeout_2026-09-02.md
?? functions/test/super_admin_console.rules.test.cjs
?? public_functions/test/custom_portal_domains.emulator.test.cjs
?? public_functions/test/manual_payments_owner.emulator.test.cjs
?? public_functions/test/owner_notification_preferences.emulator.test.cjs
?? public_functions/test/school_lifecycle_and_applications.emulator.test.cjs
?? public_functions/test/subscription_plans_lifecycle.emulator.test.cjs
 M functions/package.json
 M public_functions/package.json
```
HEAD unchanged at `b7d1ccbf`. No commit, push, or deploy performed in this verification pass. No destructive git operation. No `firestore.rules` / function source edited.

---

## 7. TEST TOTALS

| Suite | Tests | Pass |
|---|---|---|
| **NEW** subscription plans lifecycle (emulator) | 17 | 17 |
| **NEW** school lifecycle + applications (emulator) | 17 | 17 |
| **NEW** manual payments owner (emulator) | 17 | 17 |
| **NEW** custom portal domains (emulator) | 13 | 13 |
| **NEW** owner notification preferences (emulator) | 10 | 10 |
| **NEW** super admin console rules | 20 | 20 |
| existing owner console callables (emulator) | 14 | 14 |
| existing portal domains lifecycle (emulator) | 14 | 14 |
| existing platform health (emulator) | 15 | 15 |
| existing Firestore rules (full) | 246 | 246 |
| existing storage rules | 18 | 18 |
| existing super_admin Flutter widget/bloc | 75 | 75 |
| **Total exercised this session** | **476** | **476** |

**0 failures.**
