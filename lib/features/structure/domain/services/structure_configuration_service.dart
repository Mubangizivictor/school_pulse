import '../entities/institution_profile.dart';
import '../entities/structure_entities.dart';

/// Read-only, narrow-surface facade over [StructureRepository] for other
/// features that only need to *read* a school's master data (its current
/// year/period, active levels/classes/streams, institution profile) and
/// shouldn't have to know the full CRUD surface of Structure.
///
/// This is additive: [StructureRepository] is untouched and existing
/// consumers keep using it directly. New consumers should prefer this
/// facade instead.
abstract class StructureConfigurationService {
  Future<InstitutionProfile> getInstitutionProfile(String schoolId);

  Future<AcademicYear?> getCurrentAcademicYear(String schoolId);

  Future<AcademicTerm?> getCurrentAcademicPeriod(String schoolId);

  Future<List<EducationalLevel>> getActiveLevels(String schoolId);

  Future<List<SchoolClass>> getActiveClasses(
    String schoolId, {
    String? levelId,
  });

  Future<List<ClassStream>> getActiveStreams(
    String schoolId, {
    String? classId,
  });
}
