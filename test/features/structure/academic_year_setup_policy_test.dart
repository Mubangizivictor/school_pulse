import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/academic_year_setup_policy.dart';

void main() {
  AcademicYear year({bool isCurrent = false, bool isArchived = false}) =>
      AcademicYear(
        id: 'year',
        schoolId: 'school',
        name: '2026',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        isCurrent: isCurrent,
        isArchived: isArchived,
      );

  test(
    'makes a new academic year current when no active current year exists',
    () {
      expect(AcademicYearSetupPolicy.shouldSetNewYearCurrent([]), isTrue);
      expect(
        AcademicYearSetupPolicy.shouldSetNewYearCurrent([
          year(isCurrent: true, isArchived: true),
        ]),
        isTrue,
      );
    },
  );

  test('does not replace an existing active current year by default', () {
    expect(
      AcademicYearSetupPolicy.shouldSetNewYearCurrent([year(isCurrent: true)]),
      isFalse,
    );
  });
}
