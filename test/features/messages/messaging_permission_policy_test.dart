import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/policies/messaging_permission_policy.dart';

UserEntity _user({
  required String id,
  required String schoolId,
  required List<UserRole> roles,
  bool isActive = true,
  String? studentId,
  List<String> studentIds = const [],
}) {
  return UserEntity(
    id: id,
    name: id,
    email: '$id@example.com',
    schoolId: schoolId,
    roles: roles,
    isActive: isActive,
    studentId: studentId,
    studentIds: studentIds,
  );
}

void main() {
  group('MessagingPermissionPolicy.canStartConversation', () {
    test('refuses cross-school messaging', () {
      final actor = _user(id: 'a', schoolId: 's1', roles: [UserRole.subjectTeacher]);
      final target = _user(id: 'b', schoolId: 's2', roles: [UserRole.parent]);

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.subjectTeacher,
        target: target,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.differentSchool);
    });

    test('refuses when target is inactive', () {
      final actor = _user(id: 'a', schoolId: 's1', roles: [UserRole.schoolAdmin]);
      final target = _user(
        id: 'b',
        schoolId: 's1',
        roles: [UserRole.subjectTeacher],
        isActive: false,
      );

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.schoolAdmin,
        target: target,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.targetInactive);
    });

    test('allows staff to message staff in the same school', () {
      final actor = _user(id: 'a', schoolId: 's1', roles: [UserRole.bursar]);
      final target = _user(id: 'b', schoolId: 's1', roles: [UserRole.schoolAdmin]);

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.bursar,
        target: target,
      );

      expect(decision.isAllowed, isTrue);
    });

    test('refuses student-to-student by default', () {
      final actor = _user(id: 'a', schoolId: 's1', roles: [UserRole.student]);
      final target = _user(id: 'b', schoolId: 's1', roles: [UserRole.student]);

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.student,
        target: target,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.studentToStudentDisallowed);
    });

    test('refuses student-to-teacher by default', () {
      final actor = _user(id: 'a', schoolId: 's1', roles: [UserRole.student]);
      final target = _user(id: 'b', schoolId: 's1', roles: [UserRole.subjectTeacher]);

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.student,
        target: target,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.studentToStaffDisallowed);
    });

    test('allows student to message their own linked parent', () {
      final actor = _user(
        id: 'stu1',
        schoolId: 's1',
        roles: [UserRole.student],
        studentId: 'stu1',
      );
      final target = _user(
        id: 'par1',
        schoolId: 's1',
        roles: [UserRole.parent],
        studentIds: ['stu1'],
      );

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.student,
        target: target,
      );

      expect(decision.isAllowed, isTrue);
    });

    test('refuses student messaging a parent who is not theirs', () {
      final actor = _user(
        id: 'stu1',
        schoolId: 's1',
        roles: [UserRole.student],
        studentId: 'stu1',
      );
      final target = _user(
        id: 'par2',
        schoolId: 's1',
        roles: [UserRole.parent],
        studentIds: ['stu2'],
      );

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.student,
        target: target,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.studentTargetNotOwnParent);
    });

    test('refuses parent messaging a student directly', () {
      final actor = _user(id: 'par1', schoolId: 's1', roles: [UserRole.parent]);
      final target = _user(id: 'stu1', schoolId: 's1', roles: [UserRole.student]);

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.parent,
        target: target,
      );

      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.parentTargetNotStaff);
    });

    test('active role, not roles.first, decides a multi-role staff member', () {
      // A user who is both classTeacher and boardingPatron messaging a
      // student must be evaluated as whichever role is currently active,
      // not an arbitrary first role.
      final actor = _user(
        id: 'staff1',
        schoolId: 's1',
        roles: [UserRole.classTeacher, UserRole.boardingPatron],
      );
      final target = _user(id: 'stu1', schoolId: 's1', roles: [UserRole.student]);

      final decision = MessagingPermissionPolicy.canStartConversation(
        actor: actor,
        actorRole: UserRole.boardingPatron,
        target: target,
      );

      expect(decision.isAllowed, isTrue);
    });
  });

  group('MessagingPermissionPolicy.canManageGroup', () {
    test('refuses a non-admin member', () {
      final decision = MessagingPermissionPolicy.canManageGroup(
        actorId: 'u1',
        adminIds: ['u2'],
      );
      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.groupNotAdmin);
    });

    test('allows an admin', () {
      final decision = MessagingPermissionPolicy.canManageGroup(
        actorId: 'u1',
        adminIds: ['u1', 'u2'],
      );
      expect(decision.isAllowed, isTrue);
    });
  });

  group('MessagingPermissionPolicy.canSendSchoolWideBroadcast', () {
    test('refuses a subject teacher', () {
      final decision = MessagingPermissionPolicy.canSendSchoolWideBroadcast(
        actorRole: UserRole.subjectTeacher,
      );
      expect(decision.isAllowed, isFalse);
      expect(decision.refusal, MessagingRefusal.broadcastNotAuthorized);
    });

    test('allows a school admin', () {
      final decision = MessagingPermissionPolicy.canSendSchoolWideBroadcast(
        actorRole: UserRole.schoolAdmin,
      );
      expect(decision.isAllowed, isTrue);
    });
  });
}
