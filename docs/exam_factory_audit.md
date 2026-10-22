# Exam Factory audit — 30 August 2026

## Fixed in this change

| Finding | Correction |
| --- | --- |
| DOS still had an old `Performance` tab in the installed binary. | Source navigation now labels the tab `Exams` and opens Exam Factory. A full rebuild is required to see it. |
| Exam Factory was only reachable through the DOS route tree. | Teacher routes now exist at `/staff/exam-factory/...`; DOS routes remain at `/staff/dean/exam-factory/...`. |
| The client repository returned empty streams and threw for every action. | It now reads institution-scoped Firestore collections and invokes protected callable actions. |
| A DOS account (`deanOfStudies`) was omitted from the Exam Factory lead role lists. | Added to Firestore and Storage authorization checks and backend policy. |
| Drafts, moderation and paper state could not be made securely. | Added idempotent callable actions with role, tenant, assignment, state and total-mark validation plus audits. |
| Direct browser/client writes to confidential collections were a risk. | Firestore and Storage writes remain denied; generated paper files are protected. |

## Deliberately blocked until implemented

These requirements are not represented as completed: server-side PDF rendering,
print job/reprint workflow, controlled downloads, schedules/room conflicts,
attendance/incidents, marking/result publication, notifications, offline sync,
and migration execution. They require additional callable endpoints, protected
data models and emulator tests before being enabled.

## Required follow-up verification

1. Finish a clean iOS build; the local Xcode clean command is currently
   hanging on its `firebase-core` scheme.
2. Run Firebase emulator tests for the new callable flows and the new rules.
3. Add widget/integration tests for DOS and teacher route access.
4. Do not deploy or migrate existing examination data until reconciliation,
   PDF rendering and print auditing are complete.
