import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/add_staff_wizard_controller.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/role_assignment_draft.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart'
    show SubjectAssignment;

/// Covers the client-side mirror of createStaffAccount's own precondition
/// (functions/index.js): a Class Teacher role needs exactly one class, a
/// Subject Teacher role needs at least one subject+class pair. This is the
/// gap that let the "No class assigned" bug reach production - the wizard
/// had a classId field sitting unused in RoleAssignmentDraft and no check
/// preventing submission without it.
void main() {
  late AddStaffWizardController controller;

  setUp(() {
    controller = AddStaffWizardController(
      schoolId: 'school-1',
      adminUid: 'admin-1',
    );
  });

  group('assignmentValidationError', () {
    test('is null when no teaching role is selected', () {
      controller.draft.selectedRoles.add(UserRole.bursar);
      expect(controller.assignmentValidationError, isNull);
    });

    test('flags Class Teacher selected with no class configured at all', () {
      controller.draft.selectedRoles.add(UserRole.classTeacher);
      expect(controller.assignmentValidationError, contains('Class Teacher'));
    });

    test('flags Class Teacher configured with an empty class name', () {
      controller.draft.selectedRoles.add(UserRole.classTeacher);
      controller.draft.roleConfigs[UserRole.classTeacher] = RoleAssignmentDraft(
        role: UserRole.classTeacher,
        className: '',
      );
      expect(controller.assignmentValidationError, contains('Class Teacher'));
    });

    test('is null once Class Teacher has a class name set', () {
      controller.draft.selectedRoles.add(UserRole.classTeacher);
      controller.draft.roleConfigs[UserRole.classTeacher] = RoleAssignmentDraft(
        role: UserRole.classTeacher,
        className: 'P1',
      );
      expect(controller.assignmentValidationError, isNull);
    });

    test('flags Subject Teacher selected with no subject/class pairs', () {
      controller.draft.selectedRoles.add(UserRole.subjectTeacher);
      expect(controller.assignmentValidationError, contains('Subject Teacher'));
    });

    test('is null once Subject Teacher has at least one pair', () {
      controller.draft.selectedRoles.add(UserRole.subjectTeacher);
      controller.draft.roleConfigs[UserRole.subjectTeacher] =
          RoleAssignmentDraft(
            role: UserRole.subjectTeacher,
            subjectAssignments: [
              const SubjectAssignment(subjectName: 'Art', className: 'P1'),
            ],
          );
      expect(controller.assignmentValidationError, isNull);
    });

    test(
      'a staff member holding both roles is valid only once both are complete',
      () {
        controller.draft.selectedRoles.addAll([
          UserRole.classTeacher,
          UserRole.subjectTeacher,
        ]);
        controller.draft.roleConfigs[UserRole.classTeacher] =
            RoleAssignmentDraft(role: UserRole.classTeacher, className: 'P1');
        // Subject Teacher still incomplete.
        expect(
          controller.assignmentValidationError,
          contains('Subject Teacher'),
        );

        controller.draft.roleConfigs[UserRole.subjectTeacher] =
            RoleAssignmentDraft(
              role: UserRole.subjectTeacher,
              subjectAssignments: [
                const SubjectAssignment(subjectName: 'Art', className: 'P1'),
              ],
            );
        expect(controller.assignmentValidationError, isNull);
      },
    );
  });

  group('submit()', () {
    test(
      'rejects locally without reaching the repository when Class Teacher has no class',
      () async {
        controller.draft.selectedRoles.add(UserRole.classTeacher);

        final result = await controller.submit();

        expect(result.isLeft(), isTrue);
        expect(controller.submitError, contains('Class Teacher'));
        expect(controller.submitting, isFalse);
      },
    );
  });
}
