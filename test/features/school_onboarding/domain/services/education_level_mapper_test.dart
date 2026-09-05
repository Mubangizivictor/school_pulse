import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/school_onboarding/domain/entities/education_level_selection.dart';
import 'package:school_pulse/features/school_onboarding/domain/services/education_level_mapper.dart';

void main() {
  test('maps selected levels preserving order, name and code', () {
    const selected = [
      SelectableLevel(
        id: 's1',
        category: LevelCategory.primary,
        name: 'Primary',
        code: 'PRI',
        order: 0,
      ),
      SelectableLevel(
        id: 's2',
        category: LevelCategory.secondary,
        name: 'Secondary',
        code: 'SEC',
        order: 1,
      ),
    ];

    final result = toEducationalLevels(
      schoolId: 'school-a',
      selected: selected,
    );

    expect(result.length, 2);
    expect(result[0].name, 'Primary');
    expect(result[0].code, 'PRI');
    expect(result[0].order, 0);
    expect(result[0].schoolId, 'school-a');
    expect(result[1].name, 'Secondary');
    expect(result[1].order, 1);
  });

  test('generates fresh ids for levels with no existing mapping', () {
    const selected = [
      SelectableLevel(
        id: 's1',
        category: LevelCategory.primary,
        name: 'Primary',
        order: 0,
      ),
    ];

    final result = toEducationalLevels(schoolId: 'school-a', selected: selected);

    expect(result.single.id, isNotEmpty);
  });

  test('reuses previously-provisioned ids for stable upserts', () {
    const selected = [
      SelectableLevel(
        id: 's1',
        category: LevelCategory.primary,
        name: 'Primary',
        order: 0,
      ),
    ];

    final result = toEducationalLevels(
      schoolId: 'school-a',
      selected: selected,
      existingIds: {'s1': 'structure-doc-123'},
    );

    expect(result.single.id, 'structure-doc-123');
  });

  test('empty selection maps to an empty list', () {
    final result = toEducationalLevels(schoolId: 'school-a', selected: const []);
    expect(result, isEmpty);
  });

  test('international programme name is carried into description', () {
    const selected = [
      SelectableLevel(
        id: 's1',
        category: LevelCategory.international,
        name: 'Cambridge Lower',
        order: 0,
        internationalProgrammeName: 'Cambridge International',
      ),
    ];

    final result = toEducationalLevels(schoolId: 'school-a', selected: selected);

    expect(result.single.description, 'Cambridge International');
  });
}
