import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity staff profile fields', () {
    test('construction without staff fields defaults them to null', () {
      const parent = UserEntity(
        id: 'p1',
        name: 'A Parent',
        email: 'parent@example.com',
        schoolId: 'school-1',
        roles: [UserRole.parent],
      );

      expect(parent.departmentId, isNull);
      expect(parent.designationId, isNull);
      expect(parent.campusId, isNull);
      expect(parent.employmentType, isNull);
      expect(parent.dateJoined, isNull);
      expect(parent.address, isNull);
      expect(parent.emergencyContact, isNull);
    });

    test('copyWith updates only the given staff fields', () {
      const staff = UserEntity(
        id: 's1',
        name: 'A Teacher',
        email: 'teacher@example.com',
        schoolId: 'school-1',
        roles: [UserRole.subjectTeacher],
        departmentId: 'dept-1',
      );

      final updated = staff.copyWith(designationId: 'desig-1');

      expect(updated.departmentId, 'dept-1');
      expect(updated.designationId, 'desig-1');
      expect(updated.id, staff.id);
    });

    test('two entities with the same staff fields are equal', () {
      const a = UserEntity(
        id: 's1',
        name: 'A',
        email: 'a@example.com',
        schoolId: 'school-1',
        roles: [UserRole.subjectTeacher],
        departmentId: 'dept-1',
        designationId: 'desig-1',
        campusId: 'campus-1',
        employmentType: 'Permanent',
      );
      const b = UserEntity(
        id: 's1',
        name: 'A',
        email: 'a@example.com',
        schoolId: 'school-1',
        roles: [UserRole.subjectTeacher],
        departmentId: 'dept-1',
        designationId: 'desig-1',
        campusId: 'campus-1',
        employmentType: 'Permanent',
      );

      expect(a, equals(b));
    });
  });

  group('UserModel Firestore mapping', () {
    test('fromJson tolerates missing staff fields (legacy docs)', () {
      final model = UserModel.fromJson({
        'id': 'u1',
        'name': 'Legacy User',
        'email': 'legacy@example.com',
        'schoolId': 'school-1',
        'role': 'subjectTeacher',
      });

      expect(model.departmentId, isNull);
      expect(model.dateJoined, isNull);
      expect(model.emergencyContact, isNull);
    });

    test('fromJson parses a Firestore Timestamp for dateJoined', () {
      final joined = DateTime(2026, 3, 1);
      final model = UserModel.fromJson({
        'id': 'u1',
        'name': 'Staff',
        'email': 'staff@example.com',
        'schoolId': 'school-1',
        'role': 'subjectTeacher',
        'dateJoined': Timestamp.fromDate(joined),
        'departmentId': 'dept-1',
        'designationId': 'desig-1',
        'campusId': 'campus-1',
        'employmentType': 'Permanent',
        'emergencyContact': {
          'name': 'Next of Kin',
          'relationship': 'Sibling',
          'phoneNumber': '0700000000',
        },
      });

      expect(model.dateJoined, joined);
      expect(model.departmentId, 'dept-1');
      expect(model.designationId, 'desig-1');
      expect(model.campusId, 'campus-1');
      expect(model.employmentType, 'Permanent');
      expect(model.emergencyContact?.name, 'Next of Kin');
    });

    test('toJson round-trips through fromJson', () {
      final original = UserModel(
        id: 'u1',
        name: 'Staff',
        email: 'staff@example.com',
        schoolId: 'school-1',
        roles: const [UserRole.subjectTeacher],
        departmentId: 'dept-1',
        designationId: 'desig-1',
        campusId: 'campus-1',
        employmentType: 'Permanent',
        dateJoined: DateTime(2026, 3, 1),
        address: '123 Main St',
        emergencyContact: const StaffEmergencyContact(
          name: 'Next of Kin',
          relationship: 'Sibling',
          phoneNumber: '0700000000',
        ),
      );

      final restored = UserModel.fromJson(original.toJson());

      expect(restored.departmentId, original.departmentId);
      expect(restored.designationId, original.designationId);
      expect(restored.campusId, original.campusId);
      expect(restored.employmentType, original.employmentType);
      expect(restored.dateJoined, original.dateJoined);
      expect(restored.address, original.address);
      expect(restored.emergencyContact, original.emergencyContact);
    });
  });
}
