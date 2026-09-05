import 'package:equatable/equatable.dart';

import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';

class LevelInUseReport extends Equatable {
  final String levelId;
  final int classCount;
  final int studentCount;

  const LevelInUseReport({
    required this.levelId,
    required this.classCount,
    required this.studentCount,
  });

  bool get isInUse => classCount > 0 || studentCount > 0;

  @override
  List<Object?> get props => [levelId, classCount, studentCount];
}

/// Checks whether previously-provisioned Structure levels that are about to
/// be removed/changed already have real classes or students attached, so the
/// Education levels step can warn before silently orphaning that data.
///
/// Only meaningful for levels that were actually provisioned in a prior
/// Save & continue (i.e. have a real Structure `EducationalLevel` id) - a
/// level with no known Structure id has nothing to check yet, and this
/// deliberately returns no report for it rather than fabricating a "0 in
/// use" that would look identical to a checked, genuinely-unused level.
class LevelsInUseChecker {
  LevelsInUseChecker({required StructureDependencyService dependencyService})
    : _dependencyService = dependencyService;

  final StructureDependencyService _dependencyService;

  /// [affectedStructureLevelIds] are real Structure `EducationalLevel` ids
  /// (e.g. previously-provisioned ids that are being removed or renamed out
  /// of the new selection).
  Future<List<LevelInUseReport>> checkLevelsInUse(
    String schoolId,
    List<String> affectedStructureLevelIds,
  ) async {
    final reports = <LevelInUseReport>[];
    for (final levelId in affectedStructureLevelIds) {
      final classCount = await _dependencyService.countClassesInLevel(
        schoolId,
        levelId,
      );
      final studentCount = await _dependencyService.countStudentsInLevel(
        schoolId,
        levelId,
      );
      reports.add(
        LevelInUseReport(
          levelId: levelId,
          classCount: classCount,
          studentCount: studentCount,
        ),
      );
    }
    return reports;
  }
}
