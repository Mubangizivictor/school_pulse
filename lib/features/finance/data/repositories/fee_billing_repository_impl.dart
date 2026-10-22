import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/fee_plan.dart';
import '../../domain/repositories/fee_billing_repository.dart';

class FeeBillingRepositoryImpl implements FeeBillingRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  FeeBillingRepositoryImpl({required this.firestore, required this.functions});

  @override
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
  }) async {
    try {
      final callable = functions.httpsCallable('publishFeePlan');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'planId': ?planId,
        'academicYearId': academicYearId,
        'termId': termId,
        'classId': classId,
        'studentCategory': studentCategory,
        'name': ?name,
        'lines': lines.map((l) => l.toJson()).toList(),
        'createNewVersion': createNewVersion,
      });
      final data = result.data;
      return Right((
        planId: data['planId'] as String,
        versionId: data['versionId'] as String,
        totalUgx: (data['totalUgx'] as num).toInt(),
      ));
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchedFeePlan?>> findMatchingFeePlan({
    required String schoolId,
    required String academicYearId,
    required String termId,
    required String classId,
    required String studentCategory,
  }) async {
    try {
      final callable = functions.httpsCallable('findMatchingFeePlan');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'academicYearId': academicYearId,
        'termId': termId,
        'classId': classId,
        'studentCategory': studentCategory,
      });
      final match = result.data['match'];
      if (match == null) return const Right(null);
      return Right(
        MatchedFeePlan.fromJson((match as Map).cast<String, dynamic>()),
      );
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> issueStudentBill({
    required String schoolId,
    required String studentId,
    required String planId,
    String? idempotencyKey,
    List<String> selectedOptionalLineIds = const [],
  }) async {
    try {
      final callable = functions.httpsCallable('issueStudentBill');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'studentId': studentId,
        'planId': planId,
        'idempotencyKey': idempotencyKey ?? '${studentId}_$planId',
        'selectedOptionalLineIds': selectedOptionalLineIds,
      });
      return Right(result.data['billId'] as String);
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<FeePlan>> watchFeePlans(String schoolId) {
    return firestore
        .collection('schools/$schoolId/fee_plans')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => FeePlan.fromJson(d.id, d.data())).toList(),
        );
  }

  @override
  Future<Either<Failure, FeePlanVersion?>> getFeePlanVersion(
    String schoolId,
    String planId,
    String versionId,
  ) async {
    try {
      final doc = await firestore
          .doc('schools/$schoolId/fee_plans/$planId/versions/$versionId')
          .get();
      if (!doc.exists) return const Right(null);
      return Right(FeePlanVersion.fromJson(doc.id, doc.data()!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<FeePlan>> findPublishedPlansForSelector({
    required String schoolId,
    required String academicYearId,
    required String termId,
    required String classId,
    required String studentCategory,
    String? excludePlanId,
  }) async {
    final normalizedCategory = studentCategory.trim().toLowerCase();
    final snap = await firestore
        .collection('schools/$schoolId/fee_plans')
        .where('status', isEqualTo: 'published')
        .where('selector.academicYearId', isEqualTo: academicYearId)
        .where('selector.termId', isEqualTo: termId)
        .where('selector.classId', isEqualTo: classId)
        .where('selector.studentCategory', isEqualTo: normalizedCategory)
        .get();
    return snap.docs
        .where((d) => d.id != excludePlanId)
        .map((d) => FeePlan.fromJson(d.id, d.data()))
        .toList();
  }

  @override
  Future<Either<Failure, void>> archiveFeePlan(
    String schoolId,
    String planId,
  ) async {
    try {
      await firestore.doc('schools/$schoolId/fee_plans/$planId').update({
        'status': 'archived',
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
