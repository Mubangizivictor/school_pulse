import '../entities/structure_entities.dart';

/// Defaults used when an administrator creates an academic year.
class AcademicYearSetupPolicy {
  const AcademicYearSetupPolicy._();

  /// The first active year must become the school's current year so that the
  /// academic structure is immediately usable.
  static bool shouldSetNewYearCurrent(Iterable<AcademicYear> years) =>
      !years.any((year) => year.isCurrent && !year.isArchived);
}
