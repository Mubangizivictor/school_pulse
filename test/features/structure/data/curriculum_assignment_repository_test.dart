import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/repositories/curriculum_assignment_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/curriculum_assignment.dart';
import 'package:school_pulse/features/structure/domain/services/structure_tenant_resolver.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CurriculumAssignmentRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = CurriculumAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: StructureTenantResolver(
        firestore: firestore,
        schoolIdOverride: 'school-a',
      ),
    );
  });

  const baseAssignment = CurriculumAssignment(
    id: 'ca-1',
    academicYearId: '2026',
    levelId: 'secondary',
    classId: 's1',
    subjectId: 'math',
  );

  group('CurriculumAssignmentRepositoryImpl.saveAssignment validation', () {
    test('rejects an assignment missing its academic year', () async {
      final assignment = baseAssignment.copyWith(academicYearId: '');
      expect(
        () => repository.saveAssignment(assignment),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects an assignment missing its subject', () async {
      final assignment = baseAssignment.copyWith(subjectId: '');
      expect(
        () => repository.saveAssignment(assignment),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects a negative periods-per-week value', () async {
      final assignment = baseAssignment.copyWith(periodsPerWeek: -1);
      expect(
        () => repository.saveAssignment(assignment),
        throwsA(
          isA<StateError>().having(
            (e) => e.message.toString(),
            'message',
            contains('negative'),
          ),
        ),
      );
    });

    test(
      'rejects a duplicate subject for the same class/stream/year',
      () async {
        await repository.saveAssignment(baseAssignment);
        final duplicate = baseAssignment.copyWith(id: 'ca-2');

        expect(
          () => repository.saveAssignment(duplicate),
          throwsA(
            isA<StateError>().having(
              (e) => e.message.toString(),
              'message',
              contains('already allocated'),
            ),
          ),
        );
      },
    );

    test('the same subject can be re-saved under its own existing id '
        '(idempotent edit, not treated as a duplicate)', () async {
      await repository.saveAssignment(baseAssignment);
      await repository.saveAssignment(
        baseAssignment.copyWith(periodsPerWeek: 5),
      );

      final doc = await firestore
          .collection('structure_curriculum_assignments')
          .doc('ca-1')
          .get();
      expect(doc.data()!['periodsPerWeek'], 5);
    });

    test(
      'a different stream for the same subject/class is not a duplicate',
      () async {
        await repository.saveAssignment(baseAssignment);
        await repository.saveAssignment(
          baseAssignment.copyWith(id: 'ca-2', streamId: 'blue'),
        );

        final snapshot = await firestore
            .collection('structure_curriculum_assignments')
            .get();
        expect(snapshot.docs, hasLength(2));
      },
    );

    test('saved assignment is scoped to the resolved school', () async {
      await repository.saveAssignment(baseAssignment);
      final doc = await firestore
          .collection('structure_curriculum_assignments')
          .doc('ca-1')
          .get();
      expect(doc.data()!['schoolId'], 'school-a');
    });
  });

  group('CurriculumAssignmentRepositoryImpl.deactivateAssignment', () {
    test('deactivating an unknown assignment throws', () async {
      expect(
        () => repository.deactivateAssignment('missing'),
        throwsA(isA<StateError>()),
      );
    });

    test('deactivating a cross-tenant assignment throws', () async {
      await firestore
          .collection('structure_curriculum_assignments')
          .doc('other-school-doc')
          .set({'schoolId': 'school-b', 'isActive': true});

      expect(
        () => repository.deactivateAssignment('other-school-doc'),
        throwsA(isA<StateError>()),
      );
    });

    test('deactivating an owned assignment flips isActive to false', () async {
      await repository.saveAssignment(baseAssignment);
      await repository.deactivateAssignment('ca-1');

      final doc = await firestore
          .collection('structure_curriculum_assignments')
          .doc('ca-1')
          .get();
      expect(doc.data()!['isActive'], isFalse);
    });
  });

  group('CurriculumAssignmentRepositoryImpl.watchAssignments', () {
    test('only streams active assignments for the resolved school', () async {
      await repository.saveAssignment(baseAssignment);
      await firestore.collection('structure_curriculum_assignments').add({
        'schoolId': 'school-a',
        'academicYearId': '2026',
        'levelId': 'secondary',
        'classId': 's2',
        'subjectId': 'english',
        'isActive': false,
      });
      await firestore.collection('structure_curriculum_assignments').add({
        'schoolId': 'school-b',
        'academicYearId': '2026',
        'levelId': 'secondary',
        'classId': 's1',
        'subjectId': 'math',
        'isActive': true,
      });

      final assignments = await repository.watchAssignments().first;

      expect(assignments, hasLength(1));
      expect(assignments.single.id, 'ca-1');
    });
  });
}
