import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/admin/domain/services/staff_admin_lockout_guard.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  Future<void> seedUser(
    String id, {
    required List<UserRole> roles,
    bool isActive = true,
    String schoolId = 'school-a',
  }) async {
    await firestore.collection('users').doc(id).set({
      'schoolId': schoolId,
      'isActive': isActive,
      'roles': roles.map((r) => r.name).toList(),
    });
  }

  group('StaffAdminLockoutGuard.isLastAdmin', () {
    test('returns false when candidateRoles has no admin role', () async {
      await seedUser('staff-1', roles: [UserRole.subjectTeacher]);
      final result = await StaffAdminLockoutGuard.isLastAdmin(
        schoolId: 'school-a',
        staffId: 'staff-1',
        candidateRoles: [UserRole.subjectTeacher],
        firestore: firestore,
      );
      expect(result, isFalse);
    });

    test(
      'returns true when the target is the only active admin in the school',
      () async {
        await seedUser('staff-1', roles: [UserRole.schoolAdmin]);
        await seedUser('staff-2', roles: [UserRole.subjectTeacher]);
        final result = await StaffAdminLockoutGuard.isLastAdmin(
          schoolId: 'school-a',
          staffId: 'staff-1',
          candidateRoles: [UserRole.schoolAdmin],
          firestore: firestore,
        );
        expect(result, isTrue);
      },
    );

    test(
      'returns false when another active admin exists in the school',
      () async {
        await seedUser('staff-1', roles: [UserRole.director]);
        await seedUser('staff-2', roles: [UserRole.headTeacher]);
        final result = await StaffAdminLockoutGuard.isLastAdmin(
          schoolId: 'school-a',
          staffId: 'staff-1',
          candidateRoles: [UserRole.director],
          firestore: firestore,
        );
        expect(result, isFalse);
      },
    );

    test('ignores admins from other schools', () async {
      await seedUser('staff-1', roles: [UserRole.schoolAdmin]);
      await seedUser(
        'staff-2',
        roles: [UserRole.schoolAdmin],
        schoolId: 'school-b',
      );
      final result = await StaffAdminLockoutGuard.isLastAdmin(
        schoolId: 'school-a',
        staffId: 'staff-1',
        candidateRoles: [UserRole.schoolAdmin],
        firestore: firestore,
      );
      expect(result, isTrue);
    });

    test('ignores an inactive admin as "another admin"', () async {
      await seedUser('staff-1', roles: [UserRole.schoolAdmin]);
      await seedUser('staff-2', roles: [UserRole.director], isActive: false);
      final result = await StaffAdminLockoutGuard.isLastAdmin(
        schoolId: 'school-a',
        staffId: 'staff-1',
        candidateRoles: [UserRole.schoolAdmin],
        firestore: firestore,
      );
      expect(result, isTrue);
    });

    test('a staff member holding an admin role alongside other roles still '
        'counts as covering the admin seat', () async {
      await seedUser('staff-1', roles: [UserRole.schoolAdmin]);
      await seedUser(
        'staff-2',
        roles: [UserRole.headTeacher, UserRole.subjectTeacher],
      );
      final result = await StaffAdminLockoutGuard.isLastAdmin(
        schoolId: 'school-a',
        staffId: 'staff-1',
        candidateRoles: [UserRole.schoolAdmin],
        firestore: firestore,
      );
      expect(result, isFalse);
    });
  });
}
