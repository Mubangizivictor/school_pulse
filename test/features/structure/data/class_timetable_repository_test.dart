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

  test('teacher collision is rejected by repository before persistence', () async {
    await repository.saveTimetable(
      const ClassTimetable(
        id: 's1-blue',
        schoolId: 'school-a',
        academicYearId: '2026',
        termId: 'term-1',
        classId: 's1',
        streamId: 'blue',
        name: 'S1 Blue',
      ),
    );
    await repository.saveTimetable(
      const ClassTimetable(
        id: 's1-red',
        schoolId: 'school-a',
        academicYearId: '2026',
        termId: 'term-1',
        classId: 's1',
        streamId: 'red',
        name: 'S1 Red',
      ),
    );

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

  test('publishing archives previous active timetable for same target', () async {
    await repository.saveTimetable(
      const ClassTimetable(
        id: 'old',
        schoolId: 'school-a',
        academicYearId: '2026',
        termId: 'term-1',
        classId: 's1',
        streamId: 'blue',
        name: 'Old S1 Blue',
        status: ClassTimetableStatus.active,
      ),
    );
    await repository.saveTimetable(
      const ClassTimetable(
        id: 'new',
        schoolId: 'school-a',
        academicYearId: '2026',
        termId: 'term-1',
        classId: 's1',
        streamId: 'blue',
        name: 'New S1 Blue',
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
