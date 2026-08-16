import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StructureDependencyService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = StructureDependencyService(firestore: firestore);
  });

  group('countStudentsInClass', () {
    test('returns 0 when no students are in the class', () async {
      final count = await service.countStudentsInClass('school-1', 'class-1');
      expect(count, 0);
    });

    test('counts only students in the given school and class', () async {
      await firestore.collection('students').add({
        'schoolId': 'school-1',
        'classId': 'class-1',
      });
      await firestore.collection('students').add({
        'schoolId': 'school-1',
        'classId': 'class-1',
      });
      await firestore.collection('students').add({
        'schoolId': 'school-1',
        'classId': 'class-2',
      });
      await firestore.collection('students').add({
        'schoolId': 'school-2',
        'classId': 'class-1',
      });

      final count = await service.countStudentsInClass('school-1', 'class-1');
      expect(count, 2);
    });
  });

  group('countClassesInLevel', () {
    test('returns 0 when no classes reference the level', () async {
      final count = await service.countClassesInLevel('school-1', 'level-1');
      expect(count, 0);
    });

    test('counts only classes in the given school and level', () async {
      await firestore.collection('classes').add({
        'schoolId': 'school-1',
        'levelId': 'level-1',
      });
      await firestore.collection('classes').add({
        'schoolId': 'school-1',
        'levelId': 'level-2',
      });
      await firestore.collection('classes').add({
        'schoolId': 'school-2',
        'levelId': 'level-1',
      });

      final count = await service.countClassesInLevel('school-1', 'level-1');
      expect(count, 1);
    });
  });

  group('countStudentsInLevel', () {
    test('returns 0 when the level has no classes', () async {
      final count = await service.countStudentsInLevel('school-1', 'level-1');
      expect(count, 0);
    });

    test('sums students across every class under the level', () async {
      await firestore.collection('classes').add({
        'schoolId': 'school-1',
        'levelId': 'level-1',
        'name': 'A',
      });
      final classB = await firestore.collection('classes').add({
        'schoolId': 'school-1',
        'levelId': 'level-1',
        'name': 'B',
      });
      await firestore.collection('students').add({
        'schoolId': 'school-1',
        'classId': classB.id,
      });
      await firestore.collection('students').add({
        'schoolId': 'school-1',
        'classId': classB.id,
      });

      final count = await service.countStudentsInLevel('school-1', 'level-1');
      expect(count, 2);
    });
  });

  group('staff structure references', () {
    test('counts only staff in the tenant and department', () async {
      await firestore.collection('users').add({
        'schoolId': 'school-1',
        'departmentId': 'dept-1',
      });
      await firestore.collection('users').add({
        'schoolId': 'school-1',
        'departmentId': 'dept-2',
      });
      await firestore.collection('users').add({
        'schoolId': 'school-2',
        'departmentId': 'dept-1',
      });

      expect(await service.countStaffInDepartment('school-1', 'dept-1'), 1);
    });

    test('counts only staff in the tenant and campus', () async {
      await firestore.collection('users').add({
        'schoolId': 'school-1',
        'campusId': 'campus-1',
      });
      await firestore.collection('users').add({
        'schoolId': 'school-1',
        'campusId': 'campus-2',
      });
      await firestore.collection('users').add({
        'schoolId': 'school-2',
        'campusId': 'campus-1',
      });

      expect(await service.countCampusReferences('school-1', 'campus-1'), 1);
    });
  });

  group('countAssignmentsForDesignation', () {
    test('returns 0 when no assignments reference the role', () async {
      final count = await service.countAssignmentsForDesignation(
        'school-1',
        'role-1',
      );
      expect(count, 0);
    });

    test(
      'counts only active assignments in the given school and role',
      () async {
        final schoolAssignments = firestore
            .collection('schools')
            .doc('school-1')
            .collection('staff_role_assignments');
        await schoolAssignments.add({
          'roleDefinitionId': 'role-1',
          'status': 'active',
        });
        await schoolAssignments.add({
          'roleDefinitionId': 'role-1',
          'status': 'active',
        });
        // Different role - should not count.
        await schoolAssignments.add({
          'roleDefinitionId': 'role-2',
          'status': 'active',
        });
        // Same role but ended - should not count.
        await schoolAssignments.add({
          'roleDefinitionId': 'role-1',
          'status': 'removed',
        });
        // Same role, active, but a different school - should not count.
        await firestore
            .collection('schools')
            .doc('school-2')
            .collection('staff_role_assignments')
            .add({'roleDefinitionId': 'role-1', 'status': 'active'});

        final count = await service.countAssignmentsForDesignation(
          'school-1',
          'role-1',
        );
        expect(count, 2);
      },
    );
  });
}
