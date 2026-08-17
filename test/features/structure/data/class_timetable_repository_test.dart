import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/repositories/class_timetable_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/class_timetable_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_tenant_resolver.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ClassTimetableRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ClassTimetableRepositoryImpl(
      firestore: firestore,
      tenantResolver: StructureTenantResolver(
        firestore: firestore,
        schoolIdOverride: 'school-a',
      ),
    );
  });

  ClassTimetableLesson lesson({
    required String id,
    required String timetableId,
    required String classId,
    required String streamId,
    String teacherId = 'teacher-john',
    String roomId = 'science-lab',
  }) {
    return ClassTimetableLesson(
      id: id,
      schoolId: 'school-a',
      timetableId: timetableId,
      academicYearId: '2026',
      termId: 'term-1',
      classId: classId,
      streamId: streamId,
      day: 'Monday',
      slotKey: 'p1|08:00|08:45',
      startTime: '08:00',
      endTime: '08:45',
      subjectId: 'math',
      teacherId: teacherId,
      roomId: roomId,
    );
  }

  Future<void> saveTable({
    required String id,
    required String classId,
    required String streamId,
    ClassTimetableStatus status = ClassTimetableStatus.draft,
  }) {
    return repository.saveTimetable(
      ClassTimetable(
        id: id,
        schoolId: 'school-a',
        academicYearId: '2026',
        termId: 'term-1',
        classId: classId,
        streamId: streamId,
        name: id,
        status: status,
      ),
    );
  }

  Future<void> seedTeaching({
    required String classId,
    required String teacherId,
    String streamId = '',
  }) async {
    await firestore.collection('structure_curriculum_assignments').add({
      'schoolId': 'school-a',
      'academicYearId': '2026',
      'levelId': 'secondary',
      'classId': classId,
      'streamId': streamId,
      'subjectId': 'math',
      'isActive': true,
    });
    await firestore.collection('structure_teaching_assignments').add({
      'schoolId': 'school-a',
      'academicYearId': '2026',
      'staffId': teacherId,
      'classId': classId,
      'streamId': streamId,
      'subjectId': 'math',
      'responsibilityType': 'subjectTeacher',
      'isActive': true,
    });
  }

  test('lesson is rejected when teacher lacks the academic assignment', () async {
    await saveTable(id: 's1-blue', classId: 's1', streamId: 'blue');
    await firestore.collection('structure_curriculum_assignments').add({
      'schoolId': 'school-a',
      'academicYearId': '2026',
      'levelId': 'secondary',
      'classId': 's1',
      'streamId': 'blue',
      'subjectId': 'math',
      'isActive': true,
    });

    expect(
      () => repository.saveLesson(
        lesson(
          id: 'bad-teacher',
          timetableId: 's1-blue',
          classId: 's1',
          streamId: 'blue',
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message.toString(),
          'message',
          contains('not assigned to teach'),
        ),
      ),
    );
  });

  test('teacher collision is rejected by repository before persistence', () async {
    await saveTable(id: 's1-blue', classId: 's1', streamId: 'blue');
    await saveTable(id: 's1-red', classId: 's1', streamId: 'red');
    await seedTeaching(classId: 's1', teacherId: 'teacher-john');

    await repository.saveLesson(
      lesson(
        id: 'blue-p1',
        timetableId: 's1-blue',
        classId: 's1',
        streamId: 'blue',
      ),
    );

    expect(
      () => repository.saveLesson(
        lesson(
          id: 'red-p1',
          timetableId: 's1-red',
          classId: 's1',
          streamId: 'red',
          roomId: 'room-b',
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message.toString(),
          'message',
          contains('teacher is already teaching'),
        ),
      ),
    );
  });

  test('room collision is rejected across different classes', () async {
    await saveTable(id: 'table-s1', classId: 's1', streamId: 'blue');
    await saveTable(id: 'table-s2', classId: 's2', streamId: 'red');
    await seedTeaching(classId: 's1', teacherId: 'teacher-a');
    await seedTeaching(classId: 's2', teacherId: 'teacher-b');

    await repository.saveLesson(
      lesson(
        id: 's1',
        timetableId: 'table-s1',
        classId: 's1',
        streamId: 'blue',
        teacherId: 'teacher-a',
      ),
    );

    expect(
      () => repository.saveLesson(
        lesson(
          id: 's2',
          timetableId: 'table-s2',
          classId: 's2',
          streamId: 'red',
          teacherId: 'teacher-b',
        ),
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message.toString(),
          'message',
          contains('room is already in use'),
        ),
      ),
    );
  });

  test('publishing requires lessons and archives previous active timetable', () async {
    await saveTable(
      id: 'old',
      classId: 's1',
      streamId: 'blue',
      status: ClassTimetableStatus.active,
    );
    await saveTable(id: 'new', classId: 's1', streamId: 'blue');
    await seedTeaching(classId: 's1', teacherId: 'teacher-john');
    await repository.saveLesson(
      lesson(
        id: 'new-p1',
        timetableId: 'new',
        classId: 's1',
        streamId: 'blue',
      ),
    );

    await repository.publishTimetable('new');
    final tables = await repository.watchTimetables().first;
    final old = tables.firstWhere((item) => item.id == 'old');
    final current = tables.firstWhere((item) => item.id == 'new');

    expect(old.status, ClassTimetableStatus.archived);
    expect(current.status, ClassTimetableStatus.active);
  });
}
