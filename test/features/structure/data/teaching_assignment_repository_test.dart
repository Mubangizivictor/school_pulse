import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/repositories/teaching_assignment_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/teaching_assignment.dart';
import 'package:school_pulse/features/structure/domain/services/structure_tenant_resolver.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TeachingAssignmentRepositoryImpl repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = TeachingAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: StructureTenantResolver(
        firestore: firestore,
        schoolIdOverride: 'school-a',
      ),
    );
    await firestore.collection('users').doc('teacher-a').set({
      'name': 'Teacher A',
      'role': 'teacher',
      'roles': ['teacher'],
      'schoolId': 'school-a',
      'isActive': true,
    });
    await firestore.collection('users').doc('teacher-b').set({
      'name': 'Teacher B',
      'role': 'teacher',
      'roles': ['teacher'],
      'schoolId': 'school-a',
      'isActive': true,
    });
  });

  Future<void> seedCurriculum({String streamId = ''}) {
    return firestore.collection('structure_curriculum_assignments').add({
      'schoolId': 'school-a',
      'academicYearId': '2026',
      'levelId': 'secondary',
      'classId': 's1',
      'streamId': streamId,
      'subjectId': 'math',
      'isActive': true,
    });
  }

  test('subject teacher requires curriculum allocation first', () async {
    const assignment = TeachingAssignment(
      id: 'subject-a',
      staffId: 'teacher-a',
      academicYearId: '2026',
      responsibilityType: TeachingResponsibilityType.subjectTeacher,
      classId: 's1',
      streamId: 'blue',
      subjectId: 'math',
    );

    expect(
      () => repository.saveAssignment(assignment),
      throwsA(
        isA<StateError>().having(
          (error) => error.message.toString(),
          'message',
          contains('curriculum'),
        ),
      ),
    );
  });

  test(
    'whole-class curriculum permits stream-scoped subject teacher',
    () async {
      await seedCurriculum();
      const assignment = TeachingAssignment(
        id: 'subject-a',
        staffId: 'teacher-a',
        academicYearId: '2026',
        responsibilityType: TeachingResponsibilityType.subjectTeacher,
        classId: 's1',
        streamId: 'blue',
        subjectId: 'math',
      );

      await repository.saveAssignment(assignment);
      final saved = await repository.watchAssignments().first;
      expect(saved, hasLength(1));
      expect(saved.single.staffId, 'teacher-a');
      expect(saved.single.streamId, 'blue');
    },
  );

  test('one login can hold subject teacher and class teacher roles', () async {
    await seedCurriculum();
    await repository.saveAssignment(
      const TeachingAssignment(
        id: 'subject-a',
        staffId: 'teacher-a',
        academicYearId: '2026',
        responsibilityType: TeachingResponsibilityType.subjectTeacher,
        classId: 's1',
        subjectId: 'math',
      ),
    );
    await repository.saveAssignment(
      const TeachingAssignment(
        id: 'class-a',
        staffId: 'teacher-a',
        academicYearId: '2026',
        responsibilityType: TeachingResponsibilityType.classTeacher,
        classId: 's1',
      ),
    );

    final saved = await repository.watchAssignments().first;
    expect(saved, hasLength(2));
    expect(
      saved.map((item) => item.responsibilityType).toSet(),
      containsAll({
        TeachingResponsibilityType.subjectTeacher,
        TeachingResponsibilityType.classTeacher,
      }),
    );
  });

  test(
    'same staff cannot be class teacher for two classes in one year',
    () async {
      await repository.saveAssignment(
        const TeachingAssignment(
          id: 'class-s1',
          staffId: 'teacher-a',
          academicYearId: '2026',
          responsibilityType: TeachingResponsibilityType.classTeacher,
          classId: 's1',
        ),
      );

      expect(
        () => repository.saveAssignment(
          const TeachingAssignment(
            id: 'class-s2',
            staffId: 'teacher-a',
            academicYearId: '2026',
            responsibilityType: TeachingResponsibilityType.classTeacher,
            classId: 's2',
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message.toString(),
            'message',
            contains('another class/stream'),
          ),
        ),
      );
    },
  );

  test('inactive staff cannot receive new responsibilities', () async {
    await firestore.collection('users').doc('teacher-b').update({
      'isActive': false,
    });
    await seedCurriculum();

    expect(
      () => repository.saveAssignment(
        const TeachingAssignment(
          id: 'inactive',
          staffId: 'teacher-b',
          academicYearId: '2026',
          responsibilityType: TeachingResponsibilityType.subjectTeacher,
          classId: 's1',
          subjectId: 'math',
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message.toString(),
          'message',
          contains('inactive'),
        ),
      ),
    );
  });
}
