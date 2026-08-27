import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/student_bill.dart';
import '../../domain/repositories/student_billing_repository.dart';

class StudentBillingRepositoryImpl implements StudentBillingRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  StudentBillingRepositoryImpl({
    required this.firestore,
    required this.functions,
  });

  String _billsPath(String schoolId, String studentId) =>
      'schools/$schoolId/student_accounts/$studentId/bills';

  @override
  Stream<List<StudentBill>> watchBills(String schoolId, String studentId) {
    return firestore
        .collection(_billsPath(schoolId, studentId))
        .orderBy('issuedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => StudentBill.fromJson(d.id, d.data())).toList(),
        );
  }

  @override
  Future<Either<Failure, StudentBill?>> getBill(
    String schoolId,
    String studentId,
    String billId,
  ) async {
    try {
      final doc = await firestore
          .doc('${_billsPath(schoolId, studentId)}/$billId')
          .get();
      if (!doc.exists) return const Right(null);
      return Right(StudentBill.fromJson(doc.id, doc.data()!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<BillAdjustment>> watchAdjustments(
    String schoolId,
    String studentId,
    String billId,
  ) {
    return firestore
        .collection('${_billsPath(schoolId, studentId)}/$billId/adjustments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => BillAdjustment.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<List<StudentPayment>> watchPayments(
    String schoolId,
    String studentId,
    String billId,
  ) {
    return firestore
        .collection('${_billsPath(schoolId, studentId)}/$billId/payments')
        .orderBy('recordedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => StudentPayment.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  @override
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
  }) async {
    try {
      final callable = functions.httpsCallable('applyBillAdjustment');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'studentId': studentId,
        'billId': billId,
        'type': type,
        if (amountUgx != null) 'amountUgx': amountUgx,
        if (percentage != null) 'percentage': percentage,
        'reason': reason,
        if (evidenceReference != null) 'evidenceReference': evidenceReference,
      });
      final data = result.data;
      return Right((
        adjustmentId: data['adjustmentId'] as String,
        amountUgx: (data['amountUgx'] as num).toInt(),
        balanceUgx: (data['balanceUgx'] as num).toInt(),
      ));
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final callable = functions.httpsCallable('recordStudentPayment');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'studentId': studentId,
        'billId': billId,
        'method': method,
        'amountUgx': amountUgx,
        if (referenceNumber != null) 'referenceNumber': referenceNumber,
        if (payerName != null) 'payerName': payerName,
        if (payerGuardianId != null) 'payerGuardianId': payerGuardianId,
        if (allocations.isNotEmpty)
          'allocations': allocations
              .map((a) => {'chargeId': a.chargeId, 'amountUgx': a.amountUgx})
              .toList(),
      });
      final data = result.data;
      return Right((
        paymentId: data['paymentId'] as String,
        receiptNumber: data['receiptNumber'] as String,
        balanceUgx: (data['balanceUgx'] as num).toInt(),
      ));
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({String reversalPaymentId, String receiptNumber, int balanceUgx})>>
  reverseStudentPayment({
    required String schoolId,
    required String studentId,
    required String billId,
    required String paymentId,
    required String reason,
  }) async {
    try {
      final callable = functions.httpsCallable('reverseStudentPayment');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'studentId': studentId,
        'billId': billId,
        'paymentId': paymentId,
        'reason': reason,
      });
      final data = result.data;
      return Right((
        reversalPaymentId: data['reversalPaymentId'] as String,
        receiptNumber: data['receiptNumber'] as String,
        balanceUgx: (data['balanceUgx'] as num).toInt(),
      ));
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
