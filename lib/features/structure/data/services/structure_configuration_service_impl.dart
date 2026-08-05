import '../../domain/entities/institution_profile.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/repositories/structure_repository.dart';
import '../../domain/services/structure_configuration_service.dart';

/// Delegates to [StructureRepository]'s existing streams - no new
/// Firestore queries, just a narrower, read-only view over data the
/// repository already fetches.
class StructureConfigurationServiceImpl
    implements StructureConfigurationService {
  final StructureRepository repository;

  StructureConfigurationServiceImpl({required this.repository});

  @override
  Future<InstitutionProfile> getInstitutionProfile(String schoolId) =>
      repository.watchInstitutionProfile(schoolId).first;

  @override
  Future<AcademicYear?> getCurrentAcademicYear(String schoolId) async {
    final years = await repository.watchAcademicYears(schoolId).first;
    for (final year in years) {
      if (year.isCurrent) return year;
    }
    return null;
  }

  @override
  Future<AcademicTerm?> getCurrentAcademicPeriod(String schoolId) async {
    final terms = await repository.watchAcademicTerms(schoolId).first;
    for (final term in terms) {
      if (term.isCurrent) return term;
    }
    return null;
  }

  @override
  Future<List<EducationalLevel>> getActiveLevels(String schoolId) async {
    final levels = await repository.watchLevels(schoolId).first;
    return levels.where((l) => l.isActive).toList();
  }

  @override
  Future<List<SchoolClass>> getActiveClasses(
    String schoolId, {
    String? levelId,
  }) async {
    final classes = await repository.watchClasses(schoolId).first;
    return classes
        .where((c) => c.isActive && (levelId == null || c.levelId == levelId))
        .toList();
  }

  @override
  Future<List<ClassStream>> getActiveStreams(
    String schoolId, {
    String? classId,
  }) async {
    final streams = await repository.watchStreams(schoolId).first;
    return streams
        .where((s) => s.isActive && (classId == null || s.classId == classId))
        .toList();
  }
}
