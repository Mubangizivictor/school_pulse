import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/fee_plan.dart';

/// Client-facing surface for the immutable fee-plan/billing backend in
/// `functions/student_fee_billing.js`. Every mutation goes through a
/// callable function - this repository never writes plan/version/bill
/// documents directly from the client, per that backend's design (published
/// plans and issued bills are immutable snapshots).
abstract class FeeBillingRepository {
  /// Publishes a new plan, or a new version of an existing published plan
  /// when [createNewVersion] is true. Throws on the server if the selector
  /// would collide with another already-published plan in a way the caller
  /// didn't intend - callers should still pre-check via [findPublishedPlansForSelector]
  /// for a better UX, since the server-side guarantee is enforced only at
  /// match time (`findMatchingFeePlan`), not at publish time.
  Future<Either<Failure, ({String planId, String versionId, int totalUgx})>>
  publishFeePlan({
    required String schoolId,
    String? planId,
    required String academicYearId,
    required String termId,
    required String classId,
    required String studentCategory,
    String? name,
    required List<FeePlanLine> lines,
    bool createNewVersion = false,
  });

  /// Read-only match for the enrolment wizard's Finance step. Returns null
  /// when no published plan matches - the caller must treat that as
  /// "billing pending", never fall back to a manual amount.
  Future<Either<Failure, MatchedFeePlan?>> findMatchingFeePlan({
    required String schoolId,
    required String academicYearId,
    required String termId,
    required String classId,
    required String studentCategory,
  });

  /// Issues an idempotent bill for [studentId] against the published plan
  /// [planId]. Safe to retry with the same [idempotencyKey] - the backend's
  /// bill doc id defaults to `idempotencyKey ?? '${studentId}_${planId}'`,
  /// so retries never create a duplicate bill.
  Future<Either<Failure, String>> issueStudentBill({
    required String schoolId,
    required String studentId,
    required String planId,
    String? idempotencyKey,
  });

  /// Direct Firestore reads for the Fee Plan Builder - listing/streaming is
  /// not money-authoritative and doesn't need a callable per the Phase 1
  /// spec.
  Stream<List<FeePlan>> watchFeePlans(String schoolId);

  Future<Either<Failure, FeePlanVersion?>> getFeePlanVersion(
    String schoolId,
    String planId,
    String versionId,
  );

  /// Plans currently published for the exact selector, used by the builder
  /// to warn about an overlap before publishing (client-side UX nicety on
  /// top of the server's own guarantee enforced in `findMatchingFeePlan`).
  Future<List<FeePlan>> findPublishedPlansForSelector({
    required String schoolId,
    required String academicYearId,
    required String termId,
    required String classId,
    required String studentCategory,
    String? excludePlanId,
  });

  /// Client-side status flip only - archiving does not touch the immutable
  /// version snapshots, only the parent plan doc's `status` field.
  Future<Either<Failure, void>> archiveFeePlan(String schoolId, String planId);
}
