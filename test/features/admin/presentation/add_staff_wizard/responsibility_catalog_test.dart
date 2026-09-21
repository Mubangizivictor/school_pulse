import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/responsibility_catalog.dart';

void main() {
  group('kResponsibilityCatalog', () {
    test('every entry has a unique id', () {
      final ids = kResponsibilityCatalog.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every entry belongs to one of the declared categories', () {
      for (final r in kResponsibilityCatalog) {
        expect(
          kResponsibilityCategories,
          contains(r.category),
          reason: '${r.id} has an undeclared category "${r.category}"',
        );
      }
    });

    test('every entry has a non-empty title and description', () {
      for (final r in kResponsibilityCatalog) {
        expect(r.title.trim(), isNotEmpty, reason: r.id);
        expect(r.description.trim(), isNotEmpty, reason: r.id);
      }
    });

    test('responsibilitiesByCategory partitions the full catalogue', () {
      final total = responsibilitiesByCategory.values
          .fold<int>(0, (sum, list) => sum + list.length);
      expect(total, kResponsibilityCatalog.length);
    });

    test('responsibilityById resolves every catalogue id', () {
      for (final r in kResponsibilityCatalog) {
        expect(responsibilityById[r.id], same(r));
      }
    });
  });

  group('incompatibleResponsibilitiesFor', () {
    test('boarding_master and boarding_mistress are mutually exclusive', () {
      expect(
        incompatibleResponsibilitiesFor('boarding_master'),
        {'boarding_mistress'},
      );
      expect(
        incompatibleResponsibilitiesFor('boarding_mistress'),
        {'boarding_master'},
      );
    });

    test('dormitory_matron and dormitory_patron are mutually exclusive', () {
      expect(
        incompatibleResponsibilitiesFor('dormitory_matron'),
        {'dormitory_patron'},
      );
    });

    test('an id with no conflict group returns empty', () {
      expect(incompatibleResponsibilitiesFor('class_teacher'), isEmpty);
    });
  });
}
