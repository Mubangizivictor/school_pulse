import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/salary_structure.dart';
import '../../domain/repositories/salary_structure_repository.dart';

class SalaryStructureRepositoryImpl implements SalaryStructureRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  SalaryStructureRepositoryImpl({
    required this.firestore,
    required this.functions,
  });

  @override
  Future<
    Either<Failure, ({String structureId, String versionId, int totalUgx})>
  >
  publishSalaryStructure({
    required String schoolId,
    String? structureId,
    required String designationId,
    String? name,
    required List<SalaryStructureLine> lines,
    bool createNewVersion = false,
  }) async {
    try {
      final callable = functions.httpsCallable('publishSalaryStructure');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'structureId': ?structureId,
        'designationId': designationId,
        'name': ?name,
        'lines': lines.map((l) => l.toJson()).toList(),
        'createNewVersion': createNewVersion,
      });
      final data = result.data;
      return Right((
        structureId: data['structureId'] as String,
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
  Future<Either<Failure, MatchedSalaryStructure?>> findMatchingSalaryStructure({
    required String schoolId,
    required String designationId,
  }) async {
    try {
      final callable = functions.httpsCallable('findMatchingSalaryStructure');
      final result = await callable.call<Map<String, dynamic>>({
        'schoolId': schoolId,
        'designationId': designationId,
      });
      final match = result.data['match'];
      if (match == null) return const Right(null);
      return Right(
        MatchedSalaryStructure.fromJson((match as Map).cast<String, dynamic>()),
      );
    } on FirebaseFunctionsException catch (e) {
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<SalaryStructure>> watchSalaryStructures(String schoolId) {
    return firestore
        .collection('schools/$schoolId/salary_structures')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => SalaryStructure.fromJson(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, SalaryStructureVersion?>> getSalaryStructureVersion(
    String schoolId,
    String structureId,
    String versionId,
  ) async {
    try {
      final doc = await firestore
          .doc(
            'schools/$schoolId/salary_structures/$structureId/versions/$versionId',
          )
          .get();
      if (!doc.exists) return const Right(null);
      return Right(SalaryStructureVersion.fromJson(doc.id, doc.data()!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<SalaryStructure>> findPublishedStructuresForSelector({
    required String schoolId,
    required String designationId,
    String? excludeStructureId,
  }) async {
    final snap = await firestore
        .collection('schools/$schoolId/salary_structures')
        .where('status', isEqualTo: 'published')
        .where('selector.designationId', isEqualTo: designationId)
        .get();
    return snap.docs
        .where((d) => d.id != excludeStructureId)
        .map((d) => SalaryStructure.fromJson(d.id, d.data()))
        .toList();
  }

  @override
  Future<Either<Failure, void>> archiveSalaryStructure(
    String schoolId,
    String structureId,
  ) async {
    try {
      await firestore
          .doc('schools/$schoolId/salary_structures/$structureId')
          .update({'status': 'archived'});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
