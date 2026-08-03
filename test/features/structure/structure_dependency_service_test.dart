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
      await firestore.collection('students').add({'schoolId': 'school-1', 'classId': 'class-1'});
      await firestore.collection('students').add({'schoolId': 'school-1', 'classId': 'class-1'});
      await firestore.collection('students').add({'schoolId': 'school-1', 'classId': 'class-2'});
      await firestore.collection('students').add({'schoolId': 'school-2', 'classId': 'class-1'});

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
      await firestore.collection('classes').add({'schoolId': 'school-1', 'levelId': 'level-1'});
      await firestore.collection('classes').add({'schoolId': 'school-1', 'levelId': 'level-2'});
      await firestore.collection('classes').add({'schoolId': 'school-2', 'levelId': 'level-1'});

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
      await firestore.collection('classes').add({'schoolId': 'school-1', 'levelId': 'level-1', 'name': 'A'});
      final classB = await firestore.collection('classes').add({'schoolId': 'school-1', 'levelId': 'level-1', 'name': 'B'});
      await firestore.collection('students').add({'schoolId': 'school-1', 'classId': classB.id});
      await firestore.collection('students').add({'schoolId': 'school-1', 'classId': classB.id});

      final count = await service.countStudentsInLevel('school-1', 'level-1');
      expect(count, 2);
    });
  });

  group('stubbed counts (documented as always-0 until future phases)', () {
    test('countStaffInDepartment always returns 0', () async {
      expect(await service.countStaffInDepartment('school-1', 'dept-1'), 0);
    });

    test('countCampusReferences always returns 0', () async {
      expect(await service.countCampusReferences('school-1', 'campus-1'), 0);
    });
  });
}
