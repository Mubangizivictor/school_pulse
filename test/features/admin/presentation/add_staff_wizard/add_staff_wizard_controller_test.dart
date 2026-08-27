import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/add_staff_wizard_controller.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/role_assignment_draft.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart'
    show SubjectAssignment;
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Records every createStaffAccount call's idempotencyKey so a test can
/// assert a retry reuses the same one, without touching real Firebase - the
/// production server-side duplicate-prevention behavior for that key is
/// already covered by
/// functions/test/create_staff_account.emulator.test.cjs.
class _RecordingAuthRepository implements AuthRepository {
  final List<String?> idempotencyKeysSeen = [];
  int callCount = 0;

  @override
  Future<Either<Failure, String>> createStaffAccount({
    required String name,
    required String email,
    required String schoolId,
    required List<UserRole> roles,
    required String password,
    String? assignedClass,
    List<SubjectAssignment>? subjects,
    String? academicYearId,
    String? departmentId,
    String? designationId,
    String? campusId,
    String? employmentType,
    DateTime? dateJoined,
    String? idempotencyKey,
    bool forcePasswordChange = false,
    bool sendLoginDetailsViaEmail = false,
    Map<String, dynamic>? staffData,
    Map<String, dynamic>? roleConfigs,
  }) async {
    callCount++;
    idempotencyKeysSeen.add(idempotencyKey);
    // Mirrors the real callable's idempotent-replay contract: a retry with
    // the same key that already succeeded returns the same staffCode
    // instead of minting a new account.
    return const Right('SMAC260007');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

/// Overrides AuditRepository.logAction (the only method
/// AddStaffWizardController.logAudit calls) to fail on demand, without
/// touching Firestore - proves audit-log failure never surfaces as a
/// controller/UI error, matching functions/index.js's own "audit after
/// commit, never blocks success" shape but on the client side, where this
/// wizard's audit call actually lives (see logAudit() below, called from
/// step_11_review_confirm.dart only after submit() already succeeded).
class _FailingAuditRepository implements AuditRepository {
  int callCount = 0;
  bool shouldThrow = true;

  @override
  Future<void> logAction({
    String? schoolId,
    required String title,
    required String description,
    required String iconName,
    required String colorHex,
    String? userId,
    String? relatedEntityId,
  }) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('simulated audit log failure');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

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

  // Requirement 6 (idempotent creation / audit resilience) on the surface
  // that actually implements it: audit logging for staff enrolment is
  // entirely client-side (AddStaffWizardController.logAudit, called from
  // step_11_review_confirm.dart's _submit only after controller.submit()
  // already returned success) - there is no server-side audit write inside
  // createStaffAccount in functions/index.js to test there. This mirrors
  // that real call sequence: submit() succeeds, logAudit() is invoked and
  // fails, then a retry submit() (same in-memory draft, so the same
  // idempotencyKey per the `draft.idempotencyKey ??= Uuid().v4()` cache in
  // submit()) still succeeds and reuses that key - proving a client-visible
  // audit failure can never turn into a duplicate account creation attempt
  // or a surfaced error.
  group('audit-log failure and retry', () {
    late _RecordingAuthRepository fakeAuthRepository;
    late _FailingAuditRepository fakeAuditRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      fakeAuthRepository = _RecordingAuthRepository();
      fakeAuditRepository = _FailingAuditRepository();
      await di.sl.reset();
      di.sl.registerLazySingleton<CreateStaffAccount>(
        () => CreateStaffAccount(fakeAuthRepository),
      );
      di.sl.registerLazySingleton<AuditRepository>(() => fakeAuditRepository);

      controller.draft.email = 'new.teacher@example.com';
      controller.draft.firstName = 'New';
      controller.draft.lastName = 'Teacher';
      controller.draft.designationId = 'designation-1';
      controller.draft.selectedRoles.add(UserRole.bursar);
    });

    test(
      'a failed audit log never surfaces as a submit error, and retrying reuses the same idempotencyKey without duplicating the account',
      () async {
        // First attempt: submit succeeds, then the caller (mirroring
        // step_11_review_confirm.dart) invokes logAudit(), which fails.
        final firstResult = await controller.submit();
        expect(firstResult.isRight(), isTrue);
        expect(controller.submitError, isNull);
        expect(fakeAuthRepository.callCount, 1);
        final firstIdempotencyKey = fakeAuthRepository.idempotencyKeysSeen.single;
        expect(firstIdempotencyKey, isNotNull);

        await controller.logAudit();
        expect(fakeAuditRepository.callCount, 1);
        // logAudit() catches internally - a thrown audit failure must never
        // propagate out to the caller or flip any controller error state.
        expect(controller.submitError, isNull);

        // Retry: same controller/draft instance (as it would be if the
        // admin simply presses Confirm again after seeing success, or if
        // the app statefully retries without discarding the wizard), so
        // draft.idempotencyKey is already cached from the first attempt and
        // submit() must send that exact key again rather than minting a
        // new one - functions/index.js's staff_enrolment_requests replay
        // logic depends on this to avoid a duplicate Auth user/users doc.
        final secondResult = await controller.submit();
        expect(secondResult.isRight(), isTrue);
        expect(controller.submitError, isNull);
        expect(fakeAuthRepository.callCount, 2);
        expect(fakeAuthRepository.idempotencyKeysSeen, [
          firstIdempotencyKey,
          firstIdempotencyKey,
        ]);

        // Audit logging succeeding this time still never affects the
        // reported result.
        fakeAuditRepository.shouldThrow = false;
        await controller.logAudit();
        expect(fakeAuditRepository.callCount, 2);
        expect(controller.submitError, isNull);
      },
    );
  });
}
