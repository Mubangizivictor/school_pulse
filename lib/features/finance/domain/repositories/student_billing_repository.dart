import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student_bill.dart';

/// Client-facing surface for a student's issued bills and everything that
/// corrects them (adjustments, payments, reversals) - the "Phase 2" half of
/// `functions/student_fee_billing.js`. Every mutation goes through a
/// callable; bill/adjustment/payment docs are read-only from the client per
/// firestore.rules (`allow write: if false`), so this repository has no
/// direct-write methods at all, only reads plus callable wrappers.
abstract class StudentBillingRepository {
  /// All bills issued to [studentId], most recent first. Render
  /// `issuedTotalUgx`/`lines` exactly as stored - never recompute them
  /// against the current fee-plan version.
  Stream<List<StudentBill>> watchBills(String schoolId, String studentId);

  Future<Either<Failure, StudentBill?>> getBill(
    String schoolId,
    String studentId,
    String billId,
  );

  Stream<List<BillAdjustment>> watchAdjustments(
    String schoolId,
    String studentId,
    String billId,
  );

  /// Payments and reversals together, most recent first - a reversal is its
  /// own record (see [StudentPayment.isReversal]), never a mutation of the
  /// original.
  Stream<List<StudentPayment>> watchPayments(
    String schoolId,
    String studentId,
    String billId,
  );

  /// Applies a discount/scholarship/waiver. Exactly one of [amountUgx] or
  /// [percentage] must be provided. `approverId` is captured server-side
  /// from the caller's auth token - never accepted from the client.
  Future<Either<Failure, ({String adjustmentId, int amountUgx, int balanceUgx})>>
  applyBillAdjustment({
    required String schoolId,
    required String studentId,
    required String billId,
    required String type,
    int? amountUgx,
    double? percentage,
    required String reason,
    String? evidenceReference,
  });

  /// Records a cash/mobile-money/bank-transfer payment. `receiptNumber` is
  /// always server-generated - the return value is the only place a caller
  /// learns it.
  Future<Either<Failure, ({String paymentId, String receiptNumber, int balanceUgx})>>
  recordStudentPayment({
    required String schoolId,
    required String studentId,
    required String billId,
    required String method,
    required int amountUgx,
    String? referenceNumber,
    String? payerName,
    String? payerGuardianId,
    List<({String? chargeId, int amountUgx})> allocations = const [],
  });

  /// Reverses [paymentId] with a compensating record - never deletes or
  /// mutates the original payment's money fields.
  Future<Either<Failure, ({String reversalPaymentId, String receiptNumber, int balanceUgx})>>
  reverseStudentPayment({
    required String schoolId,
    required String studentId,
    required String billId,
    required String paymentId,
    required String reason,
  });
}
