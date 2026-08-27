import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/salary_structure.dart';

/// Client-facing surface for the immutable salary-structure backend in
/// `functions/staff_payroll_structure.js`. Every mutation goes through a
/// callable function - this repository never writes structure/version
/// documents directly from the client, per that backend's design (published
/// structures are immutable snapshots), mirroring `FeeBillingRepository`.
abstract class SalaryStructureRepository {
  /// Publishes a new structure, or a new version of an existing published
  /// structure when [createNewVersion] is true.
  Future<Either<Failure, ({String structureId, String versionId, int totalUgx})>>
  publishSalaryStructure({
    required String schoolId,
    String? structureId,
    required String designationId,
    String? name,
    required List<SalaryStructureLine> lines,
    bool createNewVersion = false,
  });

  /// Read-only match for the Add Staff wizard's Pay Structure step. Returns
  /// null when no published structure matches - the caller must treat that
  /// as "pay setup pending", never fall back to a manual amount.
  Future<Either<Failure, MatchedSalaryStructure?>> findMatchingSalaryStructure({
    required String schoolId,
    required String designationId,
  });

  /// Direct Firestore reads for the Salary Structure Builder - listing is
  /// not money-authoritative and doesn't need a callable.
  Stream<List<SalaryStructure>> watchSalaryStructures(String schoolId);

  Future<Either<Failure, SalaryStructureVersion?>> getSalaryStructureVersion(
    String schoolId,
    String structureId,
    String versionId,
  );

  /// Structures currently published for the exact designation, used by the
  /// builder to warn about an overlap before publishing.
  Future<List<SalaryStructure>> findPublishedStructuresForSelector({
    required String schoolId,
    required String designationId,
    String? excludeStructureId,
  });

  Future<Either<Failure, void>> archiveSalaryStructure(
    String schoolId,
    String structureId,
  );
}
