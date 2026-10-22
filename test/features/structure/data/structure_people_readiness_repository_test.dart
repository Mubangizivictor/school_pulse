import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/repositories/structure_people_readiness_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StructurePeopleReadinessRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = StructurePeopleReadinessRepositoryImpl(firestore: firestore);
  });

  group('StructurePeopleReadinessRepositoryImpl.watchSchoolStaff', () {
    test('an empty schoolId yields an empty list without querying', () async {
      final staff = await repository.watchSchoolStaff('').first;
      expect(staff, isEmpty);
    });

    test('excludes parents and students, keeping staff roles', () async {
      await firestore.collection('users').doc('teacher-a').set({
        'name': 'Zara Teacher',
        'schoolId': 'school-a',
        'roles': ['subjectTeacher'],
      });
      await firestore.collection('users').doc('admin-a').set({
        'name': 'Amy Admin',
        'schoolId': 'school-a',
        'roles': ['schoolAdmin'],
      });
      await firestore.collection('users').doc('parent-a').set({
        'name': 'Pat Parent',
        'schoolId': 'school-a',
        'roles': ['parent'],
      });
      await firestore.collection('users').doc('student-a').set({
        'name': 'Sam Student',
        'schoolId': 'school-a',
        'roles': ['student'],
      });

      final staff = await repository.watchSchoolStaff('school-a').first;

      expect(staff.map((u) => u.id), containsAll(['teacher-a', 'admin-a']));
      expect(staff.map((u) => u.id), isNot(contains('parent-a')));
      expect(staff.map((u) => u.id), isNot(contains('student-a')));
    });

    test('only returns staff scoped to the requested school', () async {
      await firestore.collection('users').doc('teacher-a').set({
        'name': 'Teacher A',
        'schoolId': 'school-a',
        'roles': ['subjectTeacher'],
      });
      await firestore.collection('users').doc('teacher-b').set({
        'name': 'Teacher B',
        'schoolId': 'school-b',
        'roles': ['subjectTeacher'],
      });

      final staff = await repository.watchSchoolStaff('school-a').first;

      expect(staff, hasLength(1));
      expect(staff.single.id, 'teacher-a');
    });

    test(
      'results are sorted alphabetically by name, case-insensitively',
      () async {
        await firestore.collection('users').doc('t1').set({
          'name': 'zoe',
          'schoolId': 'school-a',
          'roles': ['subjectTeacher'],
        });
        await firestore.collection('users').doc('t2').set({
          'name': 'Adam',
          'schoolId': 'school-a',
          'roles': ['subjectTeacher'],
        });

        final staff = await repository.watchSchoolStaff('school-a').first;

        expect(staff.map((u) => u.name), ['Adam', 'zoe']);
      },
    );

    test(
      'a legacy single "role" field (no "roles" list) is still honoured',
      () async {
        await firestore.collection('users').doc('teacher-legacy').set({
          'name': 'Legacy Teacher',
          'schoolId': 'school-a',
          'role': 'subjectTeacher',
        });

        final staff = await repository.watchSchoolStaff('school-a').first;

        expect(staff, hasLength(1));
        expect(staff.single.id, 'teacher-legacy');
      },
    );
  });
}
