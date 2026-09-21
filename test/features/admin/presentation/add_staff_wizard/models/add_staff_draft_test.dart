import 'package:flutter_test/flutter_test.dart';

import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/add_staff_draft.dart';

void main() {
  group('employmentInfoComplete', () {
    late AddStaffDraft draft;

    setUp(() {
      draft = AddStaffDraft();
    });

    test('is false when campus, department and designation are unset', () {
      expect(draft.employmentInfoComplete, isFalse);
    });

    test('is false when only some Work details fields are set', () {
      draft.campusId = 'campus-1';
      draft.departmentId = 'department-1';
      expect(draft.employmentInfoComplete, isFalse);
    });

    test(
      'is true once employment type, campus, department and designation are all set',
      () {
        draft.campusId = 'campus-1';
        draft.departmentId = 'department-1';
        draft.designationId = 'designation-1';
        expect(draft.employmentInfoComplete, isTrue);
      },
    );
  });

  group('compensationSetUpNow', () {
    test('defaults to false ("Set up later") on a fresh draft', () {
      expect(AddStaffDraft().compensationSetUpNow, isFalse);
    });

    test('round-trips through toJson/fromJson', () {
      final draft = AddStaffDraft()
        ..campusId = 'campus-1'
        ..departmentId = 'department-1'
        ..designationId = 'designation-1'
        ..compensationSetUpNow = true;

      final restored = AddStaffDraft.fromJson(draft.toJson());

      expect(restored.compensationSetUpNow, isTrue);
      expect(restored.campusId, 'campus-1');
      expect(restored.departmentId, 'department-1');
      expect(restored.designationId, 'designation-1');
    });

    test('missing key in stored JSON restores to the safe default (false)', () {
      final draft = AddStaffDraft();
      final json = draft.toJson()..remove('compensationSetUpNow');

      final restored = AddStaffDraft.fromJson(json);

      expect(restored.compensationSetUpNow, isFalse);
    });
  });

  group('selectedResponsibilityIds', () {
    test('round-trips through toJson/fromJson', () {
      final draft = AddStaffDraft()
        ..selectedResponsibilityIds.addAll(['class_teacher', 'bursar']);

      final restored = AddStaffDraft.fromJson(draft.toJson());

      expect(
        restored.selectedResponsibilityIds,
        {'class_teacher', 'bursar'},
      );
    });

    test('missing key in stored JSON restores to an empty set', () {
      final json = AddStaffDraft().toJson()
        ..remove('selectedResponsibilityIds');

      final restored = AddStaffDraft.fromJson(json);

      expect(restored.selectedResponsibilityIds, isEmpty);
    });

    test('rolesSelected is true from responsibilities alone, with no UserRole set', () {
      final draft = AddStaffDraft()
        ..selectedResponsibilityIds.add('board_secretary');

      expect(draft.rolesSelected, isTrue);
      expect(draft.selectedRoles, isEmpty);
    });
  });
}
