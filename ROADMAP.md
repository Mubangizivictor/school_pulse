# School Pulse — Final Roadmap to Launch

> **Rule #1 for every human or AI session:** say which step number you are on,
> work ONLY on that step, and do not start the next step until the current one
> meets the Definition of Done. New ideas go to the **Parking Lot** at the bottom.

Status legend: `[ ]` not started · `[~]` in progress · `[x]` done (tested + committed)

Snapshot when written (2026-10-21): `flutter analyze` = 0 errors, ~326 warnings/infos.
57 feature folders under `lib/features/`. Many modules are partly built in parallel.
This roadmap's goal is to finish the modules a school needs, in dependency order.

---

## Definition of Done (applies to EVERY step)

A step is only `[x]` when all of these are true:

1. Every screen in the step has real data. No placeholder text, no "coming soon", no fake numbers.
2. Every screen handles **loading, empty, error and offline** states.
3. Layout works on **phone (iPhone 17 Pro Max sim)**, **tablet**, and **web desktop (Chrome)**.
4. Every write is tenant-scoped (`schoolId`), and allowed or blocked correctly by `firestore.rules`. There is a rules test for each new collection.
5. Every callable function checks `request.auth`, role and institution (pattern: `requireSchoolAdmin()`).
6. Sensitive actions (money, health, student data, attendance, gate) write an audit log.
7. `flutter analyze` adds no new warnings. `dart format` has been run on touched files.
8. Unit/bloc tests exist for the logic. The relevant `functions` test script passes.
9. Manual E2E: walked through on the simulator **and** on web as the real role.
10. Committed in small commits with a clear message. This file is updated to `[x]`.

---

## PHASE 0 — Stabilise the ground (no new features)

### 0.1 Scope freeze
- [ ] Read this file end to end. Agree on the launch module list (Phases 1–7).
- [ ] Anything not listed goes into the Parking Lot. Don't touch it until after launch.

### 0.2 Clean repo state
- [x] `git status` is clean. All WIP is committed or deliberately deleted.
- [x] List all `git stash list` entries. For each one, decide whether to apply it via `git show stash@{n}:<path>` or drop it. Write the decision down here.
  - Decisions (2026-10-21). All 8 stashes were backed up first as patches in `~/Desktop/school_pulse_stash_backup/stash_{0..7}.patch`.
    - stash 0 (finance/nurse/parent report-card): **dropped**. The nurse/health commits in the tree are newer.
    - stash 1 (lesson attendance BLoC): **kept parked**. Now `stash@{0}`. See Phase 3.1.
    - stash 2 (reports_dashboard WIP): **dropped**.
    - stash 3 (admissions polish): **dropped**.
    - stash 4 (message outbox/NFC): **dropped**. Already landed; the outbox impl was split into mobile/web/factory files.
    - stash 5 (public location.js + Uganda regions): **dropped**. It breaks the no-regional-defaults rule.
    - stash 6 (pre-gate_ops-rebuild snapshot): **dropped**. Too stale.
    - stash 7 (old logo/launcher assets + super-admin dialogs): **dropped**. See Parking Lot.
    - The stray `# ` line in README.md was reverted.
- [ ] Merge `structure-module` → `main` at end of Phase 0, after tests are green. (Decision: deferred until then.)

### 0.3 Warnings and tests
- [ ] Fix all `unawaited_return_in_try_block` warnings (attendance_hub repo, staff_identity_bloc, communication_attachments_uploader, student_identity_bloc, nfc_scan_flow_mixin, nfc_credential_repository_impl).
- [ ] Fix the unused-variable warnings (e.g. `academic_structure_screen.dart:2289`).
- [ ] Bring analyzer issues from ~326 down to < 50. Errors and warnings must be zero.
- [ ] Run `flutter test`. Record the failing tests here, then fix or delete each one with a reason.
- [ ] Run every `functions/package.json` test script. Record and fix failures.
- [ ] `npm run test:rules` and `npm run test:storage-rules` are green.

### 0.4 Dead code audit
- [ ] For each of the 57 feature folders, mark it **WIRED** (referenced by router/DI), **UNWIRED**, or **DUPLICATE**.
  - Folders with 0 router/DI references (check these first): `attendance_summary`, `billing`, `librarian`, `qr_scanner`.
  - Known duplicate pairs to resolve: `attendance` vs `attendance_hub`, `exams` vs `exam_factory`, `library` vs `librarian`, `nurse` vs `health`, `parent` vs `parent_access` vs `parent_offline`, `messages` vs `communication_center` vs `announcements`, `billing` vs `subscription_payment` vs `super_admin` billing, `school_onboarding` vs `structure`.
- [ ] For each pair, choose ONE winner. Delete or archive the loser in one commit per pair.

### 0.5 Shared foundations
- [ ] The design system (`lib/design_system/`) has: buttons, inputs, cards, list tiles, empty state, error state, loading skeleton, responsive scaffold, data table, stat tile, filter bar, confirmation dialog. Fill any gaps.
- [ ] One standard pattern for offline writes (queue) and one for audit logs, documented in `PROJECT_CONTEXT.md`.
- [ ] Notification init in `main.dart` is time-bounded (already fixed, so verify it).
- [ ] App Check, Crashlytics/error logging and analytics are enabled.
- [ ] Create a seed script that builds a **demo school** (2 terms, 6 classes, 10 staff, 60 students, 40 parents) in the emulator, so every later step has data to test with.

---

## PHASE 1 — The school exists (Foundation)

### 1.1 Public website and school registration
- [ ] Marketing site (`web_marketing/`, Next.js export): home, features, pricing, contact pages are final.
- [ ] `/register-school` 6-step wizard: school info → owner account → contact → plan → payment/trial → confirmation.
- [ ] Email verification and the welcome email (production email system).
- [ ] Super Admin can see, approve or reject new schools.
- [ ] Deploy via `tool/deploy_web.sh`.

### 1.2 Authentication and roles
- [ ] Login flows: email/password, phone OTP (if used), parent access code, staff identity.
- [ ] Forgot password / reset.
- [ ] First-login forced password change.
- [ ] Role resolution → correct shell for: Super Admin, School Admin, Headteacher, Director, Dean (DOS), Bursar, Class Teacher, Subject Teacher, Nurse, Matron, Patron, Librarian, Gate, Parent, Student.
- [ ] Router guards: wrong role → redirect, no institution → redirect, suspended school → blocked screen.
- [ ] Logout clears local cache (Isar) and the FCM token.
- [ ] Rules test: a user from school A cannot read school B.

### 1.3 Super Admin (platform owner console)
- [ ] School list, status, plan and usage.
- [ ] Suspend / reactivate a school.
- [ ] Plans and pricing management.
- [ ] Platform billing: invoices, payments received.
- [ ] Support: impersonate (read-only) or view a school's setup health.
- [ ] Platform audit log.

### 1.4 School setup wizard (`lib/features/structure/`, 16 steps)
Each step uses `SetupWizardShell`, saves a draft, and can be revisited.
- [ ] 1. Institution profile: name, logo, motto, address, country (no default), contacts.
- [ ] 2. Academic years.
- [ ] 3. Academic calendar and terms: custom term names and dates, holidays.
- [ ] 4. Education levels: nursery/primary/O-level/A-level/international, all custom.
- [ ] 5. Classes.
- [ ] 6. Streams.
- [ ] 7. Subjects: per level, compulsory/optional, codes.
- [ ] 8. Teaching plans: subject ↔ class ↔ periods per week.
- [ ] 9. Departments.
- [ ] 10. Responsibilities: HOD, class teacher, patron, etc.
- [ ] 11. Assessment and grading: grading scales, divisions/points, weightings, custom models.
- [ ] 12. Spaces: rooms, labs, dorms.
- [ ] 13. Operations: day/boarding, school hours, attendance config.
- [ ] 14. Feature toggles: which modules this school uses.
- [ ] 15. Timetables: generate or manual, with clash detection.
- [ ] 16. Review and validation: lists missing pieces, then "Go live".
- [ ] Setup progress percentage is shown on the admin dashboard until complete.

### 1.5 Branding
- [ ] School colours and logo applied in app, report cards, receipts and ID cards.

---

## PHASE 2 — People

### 2.1 Staff
- [ ] Add Staff wizard (all stages): personal → contact → roles → department/subjects → classes → documents → account creation → review.
- [ ] Custom roles (currently "coming soon" in `stage_03_roles.dart`), or remove the option.
- [ ] Staff list: search, filter by role/department, status.
- [ ] Staff profile: edit, deactivate, reset login, reassign classes.
- [ ] Bulk staff import (CSV/Excel), with a validation preview.
- [ ] Staff ID card generation.

### 2.2 Students
- [ ] Direct registration (single student) with a draft save.
- [ ] Bulk import (CSV/Excel), with a validation preview and duplicate detection.
- [ ] Student list: search, filter by class/stream/status.
- [ ] Student profile tabs: bio, guardians, academics, attendance, finance, health, discipline, documents.
- [ ] Documents upload: allow PDF (`admin_student_documents_screen.dart` TODO).
- [ ] Promote class at year end (bulk).
- [ ] Transfer in / transfer out / withdraw / graduate flows (`student_profile_tabs.dart` TODO).
- [ ] Student ID, QR and NFC card (student_identity, verification).

### 2.3 Parents
- [ ] Parent creation and access codes.
- [ ] Link parent ↔ student (max 2 parents per student, enforced in rules AND function).
- [ ] Admin-only reallocation, finished (`TODO(guardian-reallocation)`).
- [ ] Resend access code: build the Cloud Function (`TODO(parent-access)`).
- [ ] Parent workspace in admin: list, search, link status.
- [ ] Guardian contact resolution via ParentStudentRelationship → ParentAccessCode everywhere.

### 2.4 School directory
- [ ] Staff and parent directory, respecting privacy rules per role.

---

## PHASE 3 — Daily operations

### 3.1 Attendance
- [ ] Choose one module (`attendance_hub`). Delete or merge `attendance` and `attendance_summary`.
- [ ] Class register: mark present/absent/late/excused, works offline and syncs later.
- [ ] Staff attendance (`watchToday` etc.).
- [ ] Attendance history (previous attendances).
- [ ] Absence → parent notification.
- [ ] Reports: daily, weekly, per class, per student, chronic absentees.
- [ ] Google Sheets export (per-school OAuth).
- Note: lesson attendance BLoC (stash 1 patch: `~/Desktop/school_pulse_stash_backup/stash_1.patch`, also still parked as `stash@{0}`).

### 3.2 Timetable
- [ ] View timetable per class, per teacher, per room.
- [ ] Substitutions / cover lessons.
- [ ] Teacher "my lessons today".

### 3.3 Teacher panels
- [ ] Subject Teacher: my classes, lesson plans, homework, marks entry, resources.
- [ ] Class Teacher: register, class list, student notes, Resources, timetable, More (outstanding).
- [ ] Lesson plans: create, submit, DOS approval (`lesson_plans`, `approvals`).
- [ ] Homework: create and attach files; students view and download attachments (`student_homework_screen.dart` TODO).

### 3.4 Communication
- [ ] One messaging stack. Decide between `messages`, `communication_center` and `announcements`.
- [ ] Announcements (school-wide, per class, per role).
- [ ] 1-to-1 messaging (parent ↔ teacher, staff ↔ staff).
- [ ] SMS and email fallback for parents without the app.
- [ ] Message templates (director "coming soon").
- [ ] Notifications: push + in-app inbox + deep links (existing `lib/features/notifications/` module, extend it, don't rebuild).

### 3.5 School calendar and appointments
- [ ] Calendar events, term dates and holidays visible to every role.
- [ ] Appointments: parent books time with a teacher or admin.

---

## PHASE 4 — Money

### 4.1 Bursar / Finance (code done, needs to ship)
- [ ] `firebase deploy --only functions,firestore:rules,firestore:indexes`.
- [ ] Fee structures per class/term, discounts, scholarships.
- [ ] Invoicing / billing per student per term (academic-calendar billing).
- [ ] Payments: cash, bank, mobile money. Receipts (PDF) and reversals with audit.
- [ ] Petty cash, suppliers, payment vouchers, expenses.
- [ ] Bank reconciliation.
- [ ] Reports engine: collections, arrears, defaulters list, income vs expense.
- [ ] Offline queue for payment capture.
- [ ] Desktop deep-link routing.
- [ ] Real E2E pass on production with one test school.

### 4.2 Financial entitlements and clearance
- [ ] Entitlement decisions (exam/report-card/gate/meals by fee status).
- [ ] Report Card Financial Clearance Phase 2: commit, test and deploy.
- [ ] Parent sees their balance and a clear restriction message.

### 4.3 Parent payments
- [ ] Parent pays fees in-app (mobile money gateway), with automatic receipt and reconciliation.

### 4.4 SaaS subscription (school pays School Pulse)
- [ ] Billing and plans screens wired to the backend. E2E test.
- [ ] Trial → paid → overdue → suspended lifecycle, with reminders.

---

## PHASE 5 — Academics

### 5.1 Exams
- [ ] Choose one module (`exam_factory` vs `exams`).
- [ ] Exam setup: exam types, sittings, weightings per term.
- [ ] Marks entry per subject teacher (offline-capable), with lock after deadline.
- [ ] DOS moderation and approval.
- [ ] Results computation: averages, positions, grades, divisions/points (configurable).

### 5.2 Report cards
- [ ] Report card templates (configurable per school/level).
- [ ] Teacher and headteacher comments.
- [ ] Generate PDF in bulk per class.
- [ ] Publish to parents, with the clearance check applied.
- [ ] Document verification (QR on report card → public verify page).

### 5.3 Academic analytics
- [ ] Per-subject averages, per-class performance, term-over-term trends. **This data unblocks the Director/Dean TODOs.**

---

## PHASE 6 — Role dashboards (read-only views over Phases 1–5)

### 6.1 School Admin
- [ ] Admin dashboard: setup progress, today's attendance, fees collected, alerts.
- [ ] Admin desktop shell (sidebar + IndexedStack sections) and the mobile More screen.
- [ ] Module control (feature toggles at runtime).
- [ ] Data management: export/backup.

### 6.2 Headteacher
- [ ] Dashboard: attendance, academics, discipline, staff, approvals queue.

### 6.3 Director (10 screens with TODOs, wire them to real data)
- [ ] `financial_overview_screen`: monthly revenue series.
- [ ] `finance_analytics_screen`: revenue, expense, collection trend.
- [ ] `director_reports_screen`: department expenditure, term trends, subject averages, lesson coverage, inventory.
- [ ] `school_performance_screen`: historical-terms trend.
- [ ] `academic_overview_screen`: per-subject averages, per-class list.
- [ ] `student_analytics_screen`: admissions/withdrawals/transfers, performance, discipline.
- [ ] `staff_overview_screen`: teaching vs non-teaching split, workload.
- [ ] `parent_engagement_screen`: active parents, messages sent/opened.
- [ ] `incidents_screen`: needs an incident repository (or reuse discipline).
- [ ] `communication_screen`: message templates.

### 6.4 Dean of Studies
- [ ] Dean dashboard and shell (beware the stashed 777-line rewrite, reconcile it first).
- [ ] Lesson plan approvals, timetable, marks moderation, academic reports.

### 6.5 Parent app
- [ ] Home: children switcher, today's attendance, fees balance, announcements.
- [ ] Per child: results/report cards, attendance history, homework, timetable, health notes.
- [ ] Pay fees, message teacher, book appointment.
- [ ] Offline mode (`parent_offline`).

### 6.6 Student app
- [ ] Timetable, homework, results, announcements, library loans, ID card.

### 6.7 Discipline
- [ ] Incident recording, sanctions, parent notification, history on the student profile.

---

## PHASE 7 — Launch

### 7.1 Security
- [ ] Full `firestore.rules` and `storage.rules` review. Every collection has a tenant check and a test.
- [ ] Every callable has an auth + role + institution check.
- [ ] Run `/security-review` on the branch.
- [ ] App Check enforced in production.
- [ ] Backup policy for Firestore (scheduled exports).

### 7.2 Quality
- [ ] Full regression on iPhone sim, Android emulator, Chrome, and a real low-end Android phone.
- [ ] Performance: cold start < 3s, lists paginated, images cached.
- [ ] Slow/no network tested for attendance, payments and marks entry.

### 7.3 Release
- [ ] App icons, splash, store screenshots, privacy policy, terms.
- [ ] Android: signed release, Play Store internal track.
- [ ] iOS: distribution cert, TestFlight.
- [ ] Web: `flutter build web --release` → `firebase deploy --only hosting`.
- [ ] Production functions, rules and indexes deployed.

### 7.4 Pilot
- [ ] Onboard ONE real school with real data.
- [ ] Two weeks of daily use. Collect bugs into a list and fix only bugs, no features.
- [ ] User guides: admin, teacher, bursar, parent (short PDFs or videos).
- [ ] Support channel (WhatsApp/email) and an issue tracker.

### 7.5 Go live
- [ ] Open registration to more schools.
- [ ] Monitoring: Crashlytics, function error alerts, billing alerts.

---

## PARKING LOT — v2 (after launch only)

Built or partly built, but NOT required to launch. Do not work on these until Phase 7 is done:

- Gate operations (gate_ops: pickup release and dashboard are "coming soon")
- Health / Nurse sick bay
- Boarding (matron, dorms, boarding settings "coming soon")
- Transport
- Catering / meals
- Library / Librarian (scanner, add resource, procurement TODOs)
- Inventory / stores and assets
- HR (leave, payroll)
- Biometrics
- Patron / clubs, Games, Religion
- Integrations (third-party)
- Institution health scoring
- Any new idea that comes up during Phases 0–7
- Lesson attendance BLoC (stash 1 patch)
- Old logo/launcher assets in `~/Desktop/school_pulse_stash_backup/stash_7.patch`

---

## How to brief an AI agent (copy-paste)

> We are working on School Pulse. Read `ROADMAP.md` and `CLAUDE.md`.
> We are on **step X.Y only**. Do not touch other modules.
> Finish it to the Definition of Done, tick the boxes in `ROADMAP.md`, and commit.
> If you find something unrelated, add it to the Parking Lot. Don't fix it.
