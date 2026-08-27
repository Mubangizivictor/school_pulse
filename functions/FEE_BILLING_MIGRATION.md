# Legacy fee data: what stays, what's new, how to backfill later

## Legacy collections (untouched, still readable)

- `fee_structures` (mutable, double-precision `amount`, free-text `term`/`academicYear`) — written by `FeeConfigurationScreen` / `FinanceRepository.saveFeeStructure`. `FeeStructure`/`FeeStructureItem` entities in `lib/features/finance/domain/entities/fee_structure.dart`.
- `student_financials` (`StudentFinancialAccount`, free-text `totalBilled`) — written by `InitializeStudentFinancials` usecase.

No new code path writes to either collection. `FeeConfigurationScreen`, `FinanceRepository.getFeeStructures`/`updateStudentFinancialAccount`, and `InitializeStudentFinancials` are all still present and still work for any school/student that predates the fee-plan system — they are simply no longer reachable from new enrolments or the `fee-structures` route (which now opens the Fee Plan Builder).

## New collections

- `schools/{schoolId}/fee_plans/{planId}` (+ `versions/{versionId}`) — immutable published plan snapshots, integer UGX, `publishFeePlan`.
- `schools/{schoolId}/fee_catalogue/{chargeId}` — reusable charge items, client-writable by finance roles.
- `schools/{schoolId}/student_accounts/{studentId}/bills/{billId}` (+ `adjustments/{id}`, `payments/{id}`) — immutable issued-bill snapshots and their compensating records. Callable-only writes (`issueStudentBill`, `applyBillAdjustment`, `recordStudentPayment`, `reverseStudentPayment`).

A student can have both a legacy `student_financials` doc and a new `bills` subcollection simultaneously — they are not linked, and nothing merges them automatically. `parent/fees_screen.dart` prefers a real bill when one exists for the child and falls back to the legacy `FeeItem` stream otherwise, so a family only sees stale legacy data if no bill has ever been issued for them under the new system.

## Optional future backfill (not run, not scripted here)

If Victor later wants existing students moved onto the new bill model, the shape of that migration would be:

1. For each school, publish a `fee_plans` version per distinct `(academicYearId, termId, classId, studentCategory)` combination found in that school's `fee_structures`, converting `double` amounts to integer UGX (round or reject fractional shillings — decide explicitly, don't silently truncate).
2. For each student with a `student_financials` doc but no `bills` doc for the current term, call `issueStudentBill` with an idempotency key derived from the student (e.g. `${studentId}_backfill_${planId}`) so a partial re-run never double-bills.
3. Leave the original `fee_structures`/`student_financials` docs in place afterward — this is additive, not a replacement, per the "never delete legacy data" constraint.

This would need to run as a one-off authenticated admin script (calling the callables as a privileged school-admin user, or via the Admin SDK directly with the same validation `student_fee_billing.js` already enforces) and should be reviewed and dry-run against a single school before any wider rollout. No such script exists yet — this section is a plan, not an implementation.
