import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_dashboard/subject_teacher_dashboard_bloc.dart';

Lesson _lesson({
  required String id,
  required DateTime start,
  LessonStatus status = LessonStatus.scheduled,
}) {
  return Lesson(
    id: id,
    schoolId: 'school1',
    academicYearId: '2026',
    subjectId: 'science',
    classId: 'p3',
    teacherStaffId: 'staff1',
    scheduledStart: start,
    scheduledEnd: start.add(const Duration(minutes: 45)),
    status: status,
  );
}

void main() {
  final now = DateTime.now();

  test('no lessons means no featured lesson', () {
    expect(const SubjectTeacherDashboardState().featuredLesson, isNull);
  });

  test('a lesson in progress wins over anything scheduled later', () {
    final state = SubjectTeacherDashboardState(
      todaysLessons: [
        _lesson(
          id: 'ongoing',
          start: now.subtract(const Duration(minutes: 10)),
          status: LessonStatus.ongoing,
        ),
        _lesson(id: 'later', start: now.add(const Duration(hours: 3))),
      ],
    );

    expect(state.featuredLesson?.id, 'ongoing');
  });

  test('otherwise the next lesson still to come', () {
    final state = SubjectTeacherDashboardState(
      todaysLessons: [
        _lesson(id: 'done', start: now.subtract(const Duration(hours: 3))),
        _lesson(id: 'next', start: now.add(const Duration(hours: 1))),
        _lesson(id: 'after', start: now.add(const Duration(hours: 4))),
      ],
    );

    expect(state.featuredLesson?.id, 'next');
  });

  test('falls back to the last lesson once teaching is over for the day', () {
    // The card should not go blank the moment the final period ends.
    final state = SubjectTeacherDashboardState(
      todaysLessons: [
        _lesson(id: 'first', start: now.subtract(const Duration(hours: 5))),
        _lesson(id: 'last', start: now.subtract(const Duration(hours: 2))),
      ],
    );

    expect(state.featuredLesson?.id, 'last');
  });

  test('counts still read as unknown rather than zero before they load', () {
    const state = SubjectTeacherDashboardState();
    expect(state.presentToday, isNull);
    expect(state.presentPercentage, isNull);
  });
}
