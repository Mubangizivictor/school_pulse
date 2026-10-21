import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pending_payment.dart';
import '../../domain/entities/payment_channel_config.dart';
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
          (snap) => snap.docs
              .map((d) => StudentBill.fromJson(d.id, d.data()))
              .toList(),
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
  Future<
    Either<Failure, ({String adjustmentId, int amountUgx, int balanceUgx})>
  >
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
        'amountUgx': ?amountUgx,
        'percentage': ?percentage,
        'reason': reason,
        'evidenceReference': ?evidenceReference,
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
  Future<
    Either<Failure, ({String paymentId, String receiptNumber, int balanceUgx})>
  >
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
        'referenceNumber': ?referenceNumber,
        'payerName': ?payerName,
        'payerGuardianId': ?payerGuardianId,
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
  Future<
    Either<
      Failure,
      ({String reversalPaymentId, String receiptNumber, int balanceUgx})
    >
  >
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

  @override
  Stream<PaymentChannelConfig> watchPaymentChannelConfig(String schoolId) {
    return firestore
        .doc('schools/$schoolId/payment_config/channels')
        .snapshots()
        .map((doc) => PaymentChannelConfig.fromJson(doc.data()));
  }

  @override
  Future<Either<Failure, void>> updatePaymentChannelConfig({
    required String schoolId,
    required PaymentChannelConfig config,
  }) async {
    try {
      final callable = functions.httpsCallable('updatePaymentChannelConfig');
      await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'schoolDisplayName': config.schoolDisplayName,
        'mtnMomo': {
          'enabled': config.mtnMomo.enabled,
          'ussdCode': config.mtnMomo.ussdCode,
          'steps': config.mtnMomo.steps,
          'merchantLabel': config.mtnMomo.merchantLabel,
        },
        'airtelMoney': {
          'enabled': config.airtelMoney.enabled,
          'ussdCode': config.airtelMoney.ussdCode,
          'steps': config.airtelMoney.steps,
          'merchantLabel': config.airtelMoney.merchantLabel,
        },
        'bankAccounts': config.bankAccounts.map((b) => b.toJson()).toList(),
        'otherChannels': config.otherChannels.map((c) => c.toJson()).toList(),
      });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<String?> watchStudentPaymentCode(String schoolId, String studentId) {
    return firestore
        .doc('schools/$schoolId/student_accounts/$studentId')
        .snapshots()
        .map((doc) => doc.data()?['paymentCode'] as String?);
  }

  @override
  Stream<List<PendingPayment>> watchPendingPayments(String schoolId) {
    return firestore
        .collection('schools/$schoolId/pending_payments')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => PendingPayment.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, void>> confirmPendingPayment({
    required String schoolId,
    required String pendingPaymentId,
    required String billId,
    List<({String? chargeId, int amountUgx})> allocations = const [],
  }) async {
    try {
      final callable = functions.httpsCallable('confirmPendingPayment');
      await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'pendingPaymentId': pendingPaymentId,
        'billId': billId,
        if (allocations.isNotEmpty)
          'allocations': allocations
              .map((a) => {'chargeId': a.chargeId, 'amountUgx': a.amountUgx})
              .toList(),
      });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectPendingPayment({
    required String schoolId,
    required String pendingPaymentId,
    required String reason,
  }) async {
    try {
      final callable = functions.httpsCallable('rejectPendingPayment');
      await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'pendingPaymentId': pendingPaymentId,
        'reason': reason,
      });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> claimPendingPayment({
    required String schoolId,
    required String studentId,
    required String channel,
    required int amountUgx,
    String? evidenceRef,
  }) async {
    try {
      final callable = functions.httpsCallable('claimPendingPayment');
      await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'studentId': studentId,
        'channel': channel,
        'amountUgx': amountUgx,
        'evidenceRef': ?evidenceRef,
      });
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
