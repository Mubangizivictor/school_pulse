# Exam Factory migration plan

This module is additive. Existing `features/exams` collections and UI remain
authoritative until a server-side migration has been reviewed and run.

| Existing record | Exam Factory destination | Notes |
| --- | --- | --- |
| `ExaminationSchedule` | `exam_factory_series` and paper schedule | Preserve source IDs as `legacyId`; do not delete source documents. |
| Existing assessment marks | `exam_factory_results` reference | Results are copied only after an approved reconciliation. |
| Existing timetable / room data | series schedule, rooms and invigilators | Read existing structure records rather than duplicating rooms. |

The future callable must support `dryRun: true`, a stable idempotency key and
cursor-based batches. Its dry run must report source, eligible, migrated,
skipped and failed totals for every collection. Production execution is
explicitly out of scope for this change.

## Secure-action boundary

Question submission validation, moderation, paper approval/locking, PDF
generation, print-job creation and result approval must be callable functions
that validate institution, role, assignment and state transition. Generated
files belong at:

`institutions/{institutionId}/exam_factory/{seriesId}/{paperId}/{fileName}`

They must include a version and audit reference. Client code must not generate
or directly upload confidential papers.
