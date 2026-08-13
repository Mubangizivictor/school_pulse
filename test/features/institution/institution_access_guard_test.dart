import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/institution/domain/guards/institution_access_guard.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';

UserEntity _user({
  required List<UserRole> roles,
  String schoolId = 'school-1',
}) {
  return UserEntity(
    id: 'u1',
    name: 'Test User',
    email: 'test@example.com',
    schoolId: schoolId,
    roles: roles,
  );
}

InstitutionContext _context({
  String institutionId = 'school-1',
  SchoolStatus status = SchoolStatus.active,
}) {
  return InstitutionContext(
    institutionId: institutionId,
    displayLabel: 'Test Institution',
    classification: InstitutionClassification.primary,
    divisions: const [],
    status: status,
    enabledFeatures: const [],
    loadedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('canAccessInstitution', () {
    test('superAdmin can access any institution regardless of status', () {
      final user = _user(
        roles: [UserRole.superAdmin],
        schoolId: 'other-school',
      );
      final context = _context(status: SchoolStatus.suspended);
      expect(canAccessInstitution(user, context), isTrue);
    });

    test('user matching institutionId with active status can access', () {
      final user = _user(roles: [UserRole.schoolAdmin], schoolId: 'school-1');
      final context = _context(institutionId: 'school-1');
      expect(canAccessInstitution(user, context), isTrue);
    });

    test('user from a different institution is denied', () {
      final user = _user(roles: [UserRole.schoolAdmin], schoolId: 'school-2');
      final context = _context(institutionId: 'school-1');
      expect(canAccessInstitution(user, context), isFalse);
    });

    test('non-superAdmin is denied when institution is suspended', () {
      final user = _user(roles: [UserRole.schoolAdmin], schoolId: 'school-1');
      final context = _context(
        institutionId: 'school-1',
        status: SchoolStatus.suspended,
      );
      expect(canAccessInstitution(user, context), isFalse);
    });

    test('non-superAdmin is denied when institution is archived', () {
      final user = _user(roles: [UserRole.schoolAdmin], schoolId: 'school-1');
      final context = _context(
        institutionId: 'school-1',
        status: SchoolStatus.archived,
      );
      expect(canAccessInstitution(user, context), isFalse);
    });
  });

  group('isInstitutionAdministrator', () {
    test('true for schoolAdmin', () {
      expect(
        isInstitutionAdministrator(_user(roles: [UserRole.schoolAdmin])),
        isTrue,
      );
    });

    test('true when an administrator role is not the legacy primary role', () {
      expect(
        isInstitutionAdministrator(
          _user(roles: [UserRole.subjectTeacher, UserRole.schoolAdmin]),
        ),
        isTrue,
      );
    });

    test('false for a non-admin role', () {
      expect(
        isInstitutionAdministrator(_user(roles: [UserRole.parent])),
        isFalse,
      );
    });
  });

  group('isSaasOwner', () {
    test('true only for superAdmin', () {
      expect(isSaasOwner(_user(roles: [UserRole.superAdmin])), isTrue);
      expect(isSaasOwner(_user(roles: [UserRole.schoolAdmin])), isFalse);
    });
  });
}
