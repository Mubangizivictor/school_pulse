# School Pulse — Checklist to Production

> This is the ONLY plan. It replaces the old ROADMAP.md (Phases 0–7) and
> BUSINESS_CHECKLIST.md. The old versions are in git history
> (`git show 8f2f53c3:ROADMAP.md`).

## ▶ Current step

**Step 1 — Website and school registration** (status: `[!]` blocked on A7 (Firebase billing), started 2026-10-22)

Step A (business tasks) runs in parallel with every step.

---

## Rules for every person or AI agent working on this

1. Read this file, then `CLAUDE.md` and `PROJECT_CONTEXT.md`.
2. Say which step you are on. Work **only** on the current step. Don't start the
   next step until the current one passes its **Done when** check and the
   Definition of Done below.
3. Anything unrelated you notice goes in the **Parking Lot**. Don't fix it now.
4. Commit in small commits with clear messages.
5. **How to update this file when you finish a piece of work:**
   - Tick the item: `- [ ]` → `- [x]`.
   - When every item in a step is ticked and its **Done when** passes, change the
     step's status to `[x]` with the date, e.g. `Status: [x] done 2026-11-03`.
   - Move the **▶ Current step** block at the top to the next step and set it to `[~]`.
   - Put short notes (decisions, blockers) under the step as `Note:` lines.
   - Commit: `git add ROADMAP.md && git commit -m "docs(roadmap): step N done"`.

Status legend: `[ ]` not started · `[~]` in progress · `[x]` done (tested + committed) · `[!]` blocked (say on what)

Who: **Claude** = the AI agent does it. **Victor** = only the owner can do it
(accounts, money, schools, testing on real phones, approvals).

### How to brief another AI agent (copy-paste)

> We are working on School Pulse. Read `ROADMAP.md` and `CLAUDE.md`.
> We are on **Step N only**. Do not touch other modules.
> Finish it to the Definition of Done, tick the boxes in `ROADMAP.md`, move the
> Current step marker, and commit. Unrelated findings go to the Parking Lot.

---

## Definition of Done (applies to every step)

A step is only `[x]` when all of these are true:

1. Every screen in the step has real data. No placeholder text, no "coming soon", no fake numbers.
2. Every screen handles **loading, empty, error and offline** states.
3. Layout works on **phone (iPhone 17 Pro Max sim)**, **tablet**, and **web desktop (Chrome)**.
4. Every write is tenant-scoped (`schoolId`) and allowed or blocked correctly by `firestore.rules`, with a rules test for each new collection.
5. Every callable function checks `request.auth`, role and institution (pattern: `requireSchoolAdmin()`).
6. Sensitive actions (money, health, student data, attendance, gate) write an audit log.
7. `flutter analyze` adds no new warnings. `dart format` has been run on touched files.
8. Unit/bloc tests exist for the logic. The relevant `functions` test script passes.
9. Manual E2E: walked through on the simulator **and** on web as the real role.
10. Committed in small commits. This file is updated.

---

## Commands used in every step

Run from the project folder in a terminal (VS Code: Terminal → New Terminal).

| What | Command |
| --- | --- |
| Get the latest code | `cd ~/Desktop/apps/school_pulse && git pull origin structure-module` |
| Start the test database (leave it running) | `export JAVA_HOME=$(/usr/libexec/java_home -v 21) && firebase emulators:start` |
| Load demo data (2nd terminal) | `cd functions && npm run seed:demo-school` |
| Run on iPhone simulator | `flutter run -d "iPhone 17 Pro Max"` |
| Run in Chrome | `flutter run -d chrome --web-port=8080` |
| Run on Victor's iPhone | `flutter run -d "iPhone (wireless)"` |
| Check code + tests | `flutter analyze && flutter test` |
| One feature's tests | `flutter test test/features/<feature>/` |
| Backend tests | `cd functions && npm run <script>` (list: `npm run` in `functions/`) |
| Preview the website | `cd web_marketing && npm run dev` → http://localhost:3000 |
| Deploy the website + web app | `tool/deploy_web.sh` (never a plain `flutter build web`: it overwrites the homepage) |

Demo logins (emulator only): admin `admin@demo-school.test` / `Demo@1234`;
parents `DEMOP001`–`DEMOP040`, PIN `1234`.

---

## Where the app stands (2026-10-22)

Phase 0 (stabilise) is done and merged into `main` (PR #6). Much of the rest is
built but has never been checked against the Definition of Done, so many steps
are "verify and finish", not "build from zero". This table comes from code, git
history and notes; modules were not re-tested when it was written.

| Area | State | Step |
| --- | --- | --- |
| Repo, tests, analyzer, demo data | Done: 0 errors, 0 warnings, suite green | Phase 0 |
| Crashlytics, analytics, error logging | Done; App Check monitor-only | 29 |
| Website + register-school wizard | Built; prices and copy not final | 1 |
| Super Admin console | Built and consolidated (`lib/features/super_admin/`) | 3 |
| Setup wizard (16 steps) | Built | 4 |
| Add Staff wizard | Code complete, needs E2E | 6 |
| Parents module | Redesigned and shipped | 8 |
| Attendance + history + Sheets export | Built; `attendance` → `attendance_hub` merge pending | 10 |
| Class / Subject Teacher panels | Mostly built; Resources, timetable, More outstanding | 12 |
| Notifications (`lib/features/notifications/`) | Built — extend, don't rebuild | 13 |
| Bursar / finance | All 8 areas built, E2E-green on simulator; not deployed | 15 |
| Financial entitlements, report card clearance | Built and deployed | 16 |
| SaaS billing screens | Wired to backend, not E2E tested | 18 |
| Director dashboards | ~11 files with TODOs / fake data | 24 |
| Android package id | Still `com.example.school_pulse` (Play Store rejects it) | 31 |
| iOS push | Blocked until Apple Developer account (A5) | A5, 13 |

---

## Step A — Business tasks (Victor, start now, runs in parallel)

These take days or weeks to come through, and later steps wait on them.

- [x] A1. Prices and trial decided (2026-10-22):
  | Plan | Price per term | Students | Includes |
  | --- | --- | --- | --- |
  | Starter | UGX 350,000 | up to 300 | Setup wizard, students and staff, parents app, attendance, announcements, timetable |
  | Growth (most popular) | UGX 550,000 | up to 700 | Starter + fees and Bursar, receipts, mobile money, report cards, exams |
  | Pro | UGX 800,000 | up to 1,500 | Growth + Director/Dean dashboards, analytics, NFC/QR student IDs, financial clearance |
  | Enterprise | Custom quote | 1,500+ or multiple campuses | Everything + multi-campus, dedicated support, custom features, on-site training |
  - Yearly (3 terms upfront): about 10% off (e.g. Growth UGX 1,485,000/year).
  - Free trial: 30 days, all Pro features, no payment. After it, the school picks a plan or becomes read-only; data is never deleted.
  - Pilot school: free first term for feedback and a testimonial.
- [x] A2. Answer the open pricing questions (main one: which plan gets boarding, health, library, transport). Suggestion: none at launch, they're in the Parking Lot. *Needed by Step 1.* Decided 2026-10-22: boarding, health, library and transport are in no plan at launch (Parking Lot).
- [ ] A3. Business email (e.g. support@schoolpulseapp.com). *Needed by Step 1.* Done when you can send and receive from it.
- [ ] A4. Mobile money provider chosen (Flutterwave / Pesapal / MTN MoMo) and merchant registration submitted. *Needed by Step 17.* Done when you have sandbox API keys.
- [ ] A5. Apple Developer account ($99/yr). *Needed by Step 13 (iOS push) and Step 31.*
- [ ] A6. Google Play Console account ($25 once). *Needed by Step 31.*
- [ ] A7. Firebase Blaze plan + budget alert (Firebase Console → Usage and billing). *Needed by Step 15 (first production deploy).*
- [ ] A8. Company registration with URSB decided and started. *Needed before taking money from schools.*
- [ ] A9. Privacy policy + terms drafted (Claude can draft); PDPO registration (Uganda Data Protection and Privacy Act). *Needed by Step 31.*
- [ ] A10. Pilot school found and agreed. *Needed by Step 32.*
- [ ] A11. Pilot school's real setup collected: classes, streams, subjects, fee structure, sample report card, term dates. *Needed by Step 32; useful for Steps 4 and 20.*

Weekly habit: Friday, review this file and the Parking Lot.

---

## PHASE 1 — The school exists

### Step 1 — Website and school registration
Status: `[!]` blocked on A7 (Firebase billing) (started 2026-10-22)

- [x] Claude: put the A1 prices into the website and the register-school plan step (Growth = "up to 700"); apply the website copy; remove the "payments save offline" claim until Step 15 ships offline payment capture.
- [x] Claude: check the 6-step `/register-school` wizard end to end (school info → owner account → contact → plan → payment/trial → confirmation) and the verification + welcome emails.
- [x] Claude: check Super Admin can approve and reject a new school.
- [x] Victor: read the site in Chrome and approve the wording (also updated the Resend `application-approved` template).
- [ ] Claude: deploy with `tool/deploy_web.sh` once approved.

Note (2026-10-22): prices done in `web_marketing/public/js/pricing-config.js` (single source; tiers carry the backend `plan`). The Pricing page had been deleted in b088f053 and nav/footer links 404'd on the live site; restored as `pages-html/pricing.html`. Offline claim now says attendance only. Not deployed yet.
Note (2026-10-22): the app's /register-school plan step had the old 5-tier list and multiplied the per-term price by the student count (450 students showed UGX 247.5M); now mirrors pricing-config.js (bb76e405).
Note: Victor chose to build the 30-day trial now (was planned for Step 18). Approval now starts a 30-day full-access trial with no payment (TRIAL_DAYS 14 -> 30); expiry reuses the hourly sweep -> accessMode readOnly, data kept; paying during the trial starts the paid term at trial end; a rejected payment keeps the trial (c17f9d62, 112c0b13, a19a86ac). Step 18 still owns the billing screens E2E.
Note: bug fixed: approval never set `approvedAt`, so the approval email + PDF were never sent in production (da5b5a8a).
Note: E2E passed in Chrome (desktop 1440px + phone 430px) against the emulator: 6 steps, verification link, submit, received email, approve -> trial + welcome email with PDF, reject -> email, no school created. Emails are queued only (no Resend key locally); real delivery needs Victor's check after deploy.
Note: the live approval email is the Resend hosted template `application-approved`; its wording still says "pay to activate". Victor must edit it in the Resend dashboard.
Note: blocker for local testing only: firebase-tools 15 emulator loses `admin.firestore.FieldValue` (proxy uses .bind), so public_functions crash in the Functions emulator; production is unaffected. Ran E2E with a scratch preload shim. JDK 21: `export JAVA_HOME=/opt/homebrew/opt/openjdk@21` (`java_home -v 21` doesn't find it).
Note: the Firestore emulator uses port 8080, so run Flutter web on another port (e.g. `--web-port=8081`).
Note: A3: emails already use support@schoolpulseapp.com; A2 still open (no plan includes boarding/health/library/transport on the site).
Note: the app's welcome screen has no "Register your school" entry; on phones the app wizard is only reachable by URL.
Note: the app's Super Admin approve/reject screens were not clicked through (owner login needs MFA); the same callables were tested over HTTP + emulator suites.
Remaining in Step 1: Victor's wording approval in Chrome, Resend template edit, deploy (website + functions).

Note (2026-10-22): checks green from structure-module 6446bb6a (web npm test, public_functions npm test, school-lifecycle-applications 21/21 + portal-domains-lifecycle 14/14 emulator, flutter analyze 49 infos only, registration/institution tests 29/29). Website + web app DEPLOYED with `tool/deploy_web.sh` (live). Functions NOT deployed: `firebase deploy` failed with Secret Manager 403 "requires billing to be enabled" (RESEND_API_KEY), and the live public functions return 503, so live registration is down until billing (A7) is on. Once it is, deploy: `firebase deploy --only functions:publicwebsite:{approveSchoolApplication,getSchoolApplicationStatus,submitSchoolApplication,submitManualPayment,approveManualPayment,rejectManualPayment,checkSubscriptionLifecycle,notifyOwnerOfSchoolApplication,createSchoolPortal,syncPortalDomainProjection}` (each as its own comma-separated `functions:publicwebsite:<name>`), then register a test school with mubangizivic@gmail.com, confirm the emails, approve in Super Admin.

Commands: `cd web_marketing && npm run dev && npm test`; deploy `tool/deploy_web.sh`.
Done when: the live site shows the final prices, and a test school can register, get the email, and be approved in Super Admin.

### Step 2 — Login and roles
Status: `[ ]`

- [ ] Claude: test every login type (email/password, phone OTP if used, parent access code, staff identity), forgot password, first-login password change.
- [ ] Claude: each role lands on its shell: Super Admin, School Admin, Headteacher, Director, Dean, Bursar, Class Teacher, Subject Teacher, Nurse, Matron, Patron, Librarian, Gate, Parent, Student.
- [ ] Claude: guards — wrong role, no institution, suspended school are redirected/blocked.
- [ ] Claude: logout clears Isar cache and the FCM token; rules test that school A can't read school B.
- [ ] Victor: log in as admin, teacher and parent on your iPhone.

Commands: `cd functions && npm run test:rules`; then run on the simulator with the demo logins.
Done when: every role reaches its own home screen and the cross-school rules test passes.

### Step 3 — Super Admin console
Status: `[ ]`

- [ ] Claude: verify school list (status, plan, usage), suspend/reactivate, plans and pricing (A1 prices), platform invoices and payments, setup-health view, platform audit log.

Commands: `cd functions && npm run test:rules:super-admin-console`; `flutter run -d chrome --web-port=8080`.
Done when: suspending the demo school blocks its login, and reactivating restores it.

### Step 4 — School setup wizard (`lib/features/structure/`, 16 steps)
Status: `[ ]`

- [ ] Claude: walk all 16 steps with the demo school (profile, academic years, calendar/terms, levels, classes, streams, subjects, teaching plans, departments, responsibilities, assessment/grading, spaces, operations, feature toggles, timetables, review). Each uses `SetupWizardShell`, saves a draft, can be revisited, has no Uganda-only defaults.
- [ ] Claude: setup progress % shows on the admin dashboard until "Go live".
- [ ] Victor: if A11 is done, enter the pilot school's real classes and subjects as a test.

Commands: `flutter test test/features/structure/`; run on simulator and Chrome.
Done when: a fresh school goes from step 1 to "Go live" on phone and web with no errors.

### Step 5 — Branding
Status: `[ ]`

- [ ] Claude: school colours and logo applied in app, report cards, receipts and ID cards.

Done when: changing the demo school's logo changes it in all four places.

---

## PHASE 2 — People

### Step 6 — Staff
Status: `[ ]`

- [ ] Add Staff wizard E2E (personal → contact → roles → department/subjects → classes → documents → account → review).
- [ ] Custom roles (`stage_03_roles.dart` "coming soon"): build or remove.
- [ ] Staff list (search, filter, status) and profile (edit, deactivate, reset login, reassign classes).
- [ ] Bulk staff import (CSV/Excel) with validation preview.
- [ ] Staff ID cards.

Commands: `cd functions && npm run test:create-staff-account:emulator && npm run test:create-staff-invitation:emulator`.
Done when: Victor adds a teacher on his phone and that teacher can log in.

### Step 7 — Students
Status: `[ ]`

- [ ] Single registration with draft save; bulk import with validation preview and duplicate detection.
- [ ] Student list (search, filter by class/stream/status) and profile tabs (bio, guardians, academics, attendance, finance, health, discipline, documents).
- [ ] Documents accept PDF (`admin_student_documents_screen.dart` TODO).
- [ ] Year-end bulk promotion; transfer in/out, withdraw, graduate (`student_profile_tabs.dart` TODO).
- [ ] Student ID, QR and NFC card (`student_identity`, `verification`).

Done when: 60 demo students import from one CSV and one class is promoted.

### Step 8 — Parents
Status: `[ ]`

- [ ] Parent creation and access codes.
- [ ] Max 2 parents per student enforced in rules AND functions; admin-only reallocation (`TODO(guardian-reallocation)`).
- [ ] Resend access code Cloud Function (`TODO(parent-access)`).
- [ ] Parent workspace in admin; guardian contacts resolved via ParentStudentRelationship → ParentAccessCode everywhere.

Commands: `cd functions && npm run test:create-parent-access-code:emulator && npm run test:parent-invitations:emulator && npm run test:list-parent-access-invites:emulator`.
Done when: a 3rd parent link is refused and a resent code works.

### Step 9 — School directory
Status: `[ ]`

- [ ] Staff and parent directory, with privacy rules per role.

Done when: a parent can't see other parents' phone numbers.

---

## PHASE 3 — Daily operations

### Step 10 — Attendance
Status: `[ ]`

- [ ] Move `AttendanceMethodScreen`, `AttendanceSummaryScreen`, `AttendanceListScreen` (still routed from `attendance/`, router.dart ~3288-3340) and the `attendance_summary` entity into `attendance_hub`, then delete `attendance/` and `attendance_summary/`.
- [ ] Review the parked worktrees in `.claude/worktrees/`: `agent-abf93cab` (real Subject Teacher attendance), `agent-a7aaac82` (roll-call unification, 10 commits), `agent-a14eca92` (lesson_attendance rules tests), `agent-ac81db02` (scan marking tests), `agent-a304dc17` (parent absence alerts), `agent-a4fef698` (TeacherLessonsBloc tests). Lesson attendance BLoC patch: `~/Desktop/school_pulse_stash_backup/stash_1.patch` (also `stash@{0}`).
- [ ] Class register (present/absent/late/excused) works offline and syncs.
- [ ] Staff attendance (`watchToday`), attendance history, absence → parent notification.
- [ ] Reports (daily, weekly, per class, per student, chronic absentees); Google Sheets export (per-school OAuth).
- [ ] Victor: mark a register on your phone in airplane mode, then reconnect.

Commands: `cd functions && npm run test:staff-attendance-corrections:emulator && npm run test:staff-shifts`.
Done when: the offline register syncs and the parent gets the absence alert.

### Step 11 — Timetable
Status: `[ ]`

- [ ] Views per class, teacher and room; substitutions/cover; teacher "my lessons today".

Done when: a teacher sees today's lessons on their home screen.

### Step 12 — Teacher panels
Status: `[ ]`

- [ ] Subject Teacher: classes, lesson plans, homework, marks entry, resources.
- [ ] Class Teacher: register, class list, notes, Resources, timetable, More.
- [ ] Lesson plans: create, submit, DOS approval (`lesson_plans`, `approvals`).
- [ ] Homework with attachments; students can download them (`student_homework_screen.dart` TODO).

Done when: a teacher posts homework with a file and a student opens it.

### Step 13 — Communication
Status: `[ ]` (iOS push needs A5)

- [ ] Confirm the split: `messages` (1:1 chat), `communication_center` (bulk campaigns), `announcements` (feed).
- [ ] Announcements (school, class, role); 1-to-1 messaging (parent ↔ teacher, staff ↔ staff).
- [ ] SMS and email fallback for parents without the app; message templates.
- [ ] Push + in-app inbox + deep links (extend `lib/features/notifications/`).

Done when: an announcement reaches a parent's phone as a push and opens the right screen.

### Step 14 — Calendar and appointments
Status: `[ ]`

- [ ] Term dates, holidays and events visible to every role; parents book a teacher or admin.

Done when: a parent books a slot and the teacher sees it.

---

## PHASE 4 — Money

### Step 15 — Bursar / finance (code done, needs to ship)
Status: `[ ]` (needs A7)

- [ ] Offline queue for payment capture; desktop deep-link routing.
- [ ] Verify fee structures, invoicing, payments (cash, bank, mobile money), PDF receipts, reversals with audit, petty cash, suppliers, vouchers, expenses, bank reconciliation, reports (collections, arrears, defaulters, income vs expense).
- [ ] Victor: approve the first production deploy.
- [ ] Deploy and run one real E2E pass on production with a test school.

Commands: `cd functions && npm run test:finance-operations:emulator && npm run test:finance-reconciliation:emulator && npm run test:finance-governance:emulator && npm run test:student-fee-billing:emulator && npm run test:payment-codes:emulator`; then `firebase use school-pulse-3d95b && firebase deploy --only functions,firestore:rules,firestore:indexes`.
Done when: a test payment on production prints a receipt and shows on the defaulters report.

### Step 16 — Financial entitlements and clearance
Status: `[ ]`

- [ ] Exam / report card / gate / meal decisions by fee status.
- [ ] Report Card Financial Clearance Phase 2 verified and deployed.
- [ ] Parent sees balance and a clear restriction message.

Commands: `cd functions && npm run test:financial-entitlements:emulator && npm run test:report-card-release-exceptions:emulator && npm run test:report-card-bursar:emulator`.
Done when: a parent with arrears sees the restriction message instead of the report card.

### Step 17 — Parents pay in the app
Status: `[ ]` (needs A4)

- [ ] Mobile money checkout, automatic receipt and reconciliation.

Done when: a sandbox payment clears a demo balance with no manual step.

### Step 18 — SaaS subscription (school pays School Pulse)
Status: `[ ]`

- [ ] Billing and plans screens E2E with A1 prices.
- [ ] Trial → paid → overdue → suspended (read-only, data kept), with reminders.

Commands: `cd functions && npm run test:academic-calendar-billing && npm run test:academic-calendar-billing:emulator`.
Done when: a trial school becomes read-only after its trial, with its data kept.

---

## PHASE 5 — Academics

### Step 19 — Exams
Status: `[ ]`

- [ ] Keep both modules: `exams` = assessments/marks, `exam_factory` = paper production.
- [ ] Exam setup (types, sittings, weightings per term); offline marks entry locked after deadline; DOS moderation.
- [ ] Results: averages, positions, grades, divisions/points (configurable).

Done when: a class's marks produce correct positions and grades.

### Step 20 — Report cards
Status: `[ ]`

- [ ] Templates per school/level; teacher and headteacher comments.
- [ ] Bulk PDF per class; publish to parents with the clearance check.
- [ ] QR on report card → public verify page.
- [ ] Victor: compare one generated card with the pilot school's sample (A11).

Commands: `cd functions && npm run test:report-card-engine && npm run test:report-card-workflow:emulator`.
Done when: a class's report cards generate as one PDF and the QR opens the verify page.

### Step 21 — Academic analytics
Status: `[ ]`

- [ ] Per-subject averages, per-class performance, term-over-term trends (this unblocks Director/Dean).

Done when: the numbers match a hand calculation for one class.

---

## PHASE 6 — Role dashboards (read-only views over Phases 1–5)

Done when (every step here): every number on screen comes from real demo data, and
`grep -rni "coming soon\|TODO" lib/features/<module>` shows nothing left for that screen.

### Step 22 — School Admin
Status: `[ ]`
- [ ] Dashboard (setup progress, today's attendance, fees collected, alerts), desktop shell, mobile More, module control, data export/backup.

### Step 23 — Headteacher
Status: `[ ]`
- [ ] Dashboard: attendance, academics, discipline, staff, approvals queue.

### Step 24 — Director
Status: `[ ]`
- [ ] Real data in `financial_overview_screen`, `finance_analytics_screen`, `director_reports_screen`, `school_performance_screen`, `academic_overview_screen`, `student_analytics_screen`, `staff_overview_screen`, `parent_engagement_screen`, `incidents_screen`, `communication_screen`.

### Step 25 — Dean of Studies
Status: `[ ]`
- [ ] Dashboard and shell (reconcile Victor's stashed 777-line dean_dashboard rewrite first), lesson plan approvals, timetable, marks moderation, academic reports.

### Step 26 — Parent app
Status: `[ ]`
- [ ] Children switcher, attendance, fees balance, announcements; per child results, attendance, homework, timetable, health notes; pay fees, message teacher, book appointment; offline mode (`parent_offline`).

### Step 27 — Student app
Status: `[ ]`
- [ ] Timetable, homework, results, announcements, library loans, ID card.

### Step 28 — Discipline
Status: `[ ]`
- [ ] Incidents, sanctions, parent notification, history on the student profile.

---

## PHASE 7 — Launch

### Step 29 — Security
Status: `[ ]`

- [ ] Claude: review every collection in `firestore.rules` / `storage.rules` (tenant check + test) and every callable (auth + role + institution); run `/security-review` on the branch.
- [ ] Victor: create a reCAPTCHA v3 site key (Google Cloud console) for web App Check.
- [ ] Claude: register debug tokens, then enforce App Check for Firestore, Storage and callables (`enforceAppCheck`).
- [ ] Daily Firestore backups: `gcloud firestore backups schedules create --database='(default)' --recurrence=daily --retention=14w`.

Commands: `cd functions && npm run test:rules && npm run test:storage-rules`.
Done when: rules tests pass, App Check shows "Enforced" in the Firebase Console, and a backup exists the next day.

### Step 30 — Quality
Status: `[ ]`

- [ ] Claude: full regression on iPhone sim, Android emulator, Chrome.
- [ ] Victor: one day on a cheap Android phone and your iPhone, including weak network for attendance, payments, marks.
- [ ] Claude: cold start < 3s, lists paginated, images cached.

Done when: the bug list from Victor's test day is empty.

### Step 31 — Store releases
Status: `[ ]` (needs A5, A6, A9)

- [ ] Claude: change Android package id from `com.example.school_pulse` (e.g. `com.schoolpulseapp.app`), then `flutterfire configure`.
- [ ] Claude: app icons, splash, store screenshots; privacy policy and terms pages (A9).
- [ ] Victor: Firebase Console → Crashlytics → **Enable** (Android shows `firebase_crashlytics_enabled:false`).
- [ ] Victor + Claude: Android signing key (keep a backup — losing it means no more updates); `flutter build appbundle --release`; Victor uploads to Play internal track.
- [ ] Victor: sign in to Xcode with the Apple Developer account; `flutter build ipa --release`; Victor uploads to TestFlight.
- [ ] Claude: production deploy — `tool/deploy_web.sh` and `firebase deploy --only functions,firestore:rules,firestore:indexes,storage`.

Done when: the app installs from Play internal track and TestFlight on Victor's phones, and the live site opens the latest app.

### Step 32 — Pilot
Status: `[ ]` (needs A10, A11)

- [ ] Victor: onboard the pilot school with real data (Claude helps with setup).
- [ ] Two weeks of daily use; Claude fixes bugs only, no new features.
- [ ] Claude: short user guides for admin, teacher, bursar, parent.
- [ ] Victor: support WhatsApp and business email (A3) on the website; an issue list.

Done when: two weeks of use with no open serious bugs.

### Step 33 — Go live
Status: `[ ]`

- [ ] Claude: alerts for crashes (Crashlytics), function errors and Firebase spending.
- [ ] Victor: open registration to more schools.

Done when: a school Victor has never met registers, pays and starts using School Pulse without help.

---

## PARKING LOT — after launch only

Partly built but NOT needed to launch. Don't touch until Step 33 is done. New ideas go here.

- Gate operations (pickup release and dashboard "coming soon")
- Health / Nurse sick bay (fold `nurse/` into `health/presentation` later)
- Boarding (matron, dorms), Transport, Catering / meals
- Library / Librarian, Inventory / stores and assets
- HR (leave, payroll), Biometrics
- Patron / clubs, Games, Religion
- Third-party integrations, Institution health scoring
- Parked worktrees (`.claude/worktrees/`): `agent-a040b126` owner security settings, `agent-a4dedd7b` notification settings (+ `firestore.rules`), `agent-a76df3e0` help/support module, `agent-a64ad55c` dean router + structure, `agent-ab1f35fe` inline Structure setup + dean + tests, `agent-aea8c764` functions (1 file)
- Old logo/launcher assets: `~/Desktop/school_pulse_stash_backup/stash_7.patch`
- Product question: should communication campaigns publish into announcements?
- Next.js dev shows React hydration-mismatch warnings on every static page (vanilla JS rewrites the HTML); harmless, dev only
- `integration_registry.dart` still uses the old 'Standard' plan name as minimumEntitlement
- Plan-based feature limits don't exist yet (every plan/trial gets every feature)
