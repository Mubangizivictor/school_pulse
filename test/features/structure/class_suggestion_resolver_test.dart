import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/class_suggestion_resolver.dart';

void main() {
  const resolver = ClassSuggestionResolver();
  const level = EducationalLevel(
    id: 'primary',
    schoolId: 'school-a',
    name: 'Primary',
    description: 'Classes: Primary 1, Primary 2\nPrimary 3',
  );

  test('uses the level’s configured catalogue without curriculum defaults', () {
    expect(
      resolver.resolve(
        level: level,
        profile: const InstitutionProfile(schoolType: 'Primary'),
        classes: const [],
      ),
      ['Primary 1', 'Primary 2', 'Primary 3'],
    );
  });

  test('does not offer an already configured class again', () {
    expect(
      resolver.resolve(
        level: level,
        profile: const InstitutionProfile(schoolType: 'Primary'),
        classes: const [
          SchoolClass(
            id: 'p1',
            schoolId: 'school-a',
            levelId: 'primary',
            name: 'Primary 1',
          ),
        ],
      ),
      ['Primary 2', 'Primary 3'],
    );
  });

  test(
    'expands only an explicit range in the configured level description',
    () {
      const ranged = EducationalLevel(
        id: 'secondary',
        schoolId: 'school-a',
        name: 'Secondary',
        description: 'S1 to S4',
      );
      expect(
        resolver.resolve(
          level: ranged,
          profile: const InstitutionProfile(schoolType: 'Secondary'),
          classes: const [],
        ),
      ['S1', 'S2', 'S3', 'S4'],
      );
    },
  );
}
