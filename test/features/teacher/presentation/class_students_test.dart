import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';

ClassStudentSummary _student({
  required String id,
  required String name,
  String admissionNumber = '',
  String? gender,
  ResidencyType residency = ResidencyType.unknown,
}) {
  return ClassStudentSummary(
    studentId: id,
    schoolId: 'school1',
    name: name,
    admissionNumber: admissionNumber,
    classId: 'p5',
    className: 'P5',
    streamId: 'east',
    streamName: 'East',
    academicYearId: '2026',
    gender: gender,
    residency: residency,
  );
}

void main() {
  final roster = [
    _student(id: 's1', name: 'Abalo Peter', admissionNumber: '2021/PE/010', gender: 'Male', residency: ResidencyType.boarding),
    _student(id: 's2', name: 'Adong Grace', admissionNumber: '2021/PE/011', gender: 'Female', residency: ResidencyType.day),
    _student(id: 's3', name: 'Okello John', admissionNumber: '2021/PE/012', gender: 'Male', residency: ResidencyType.day),
  ];

  ClassStudentsState stateWith({
    Map<String, LessonAttendanceStatus> attendance = const {},
    String query = '',
    ClassRosterFilter filter = ClassRosterFilter.all,
    String? gender,
    ResidencyType? residency,
  }) {
    return ClassStudentsState(
      students: roster,
      attendance: attendance,
      query: query,
      filter: filter,
      genderFilter: gender,
      residencyFilter: residency,
    );
  }

  group('unmarked students', () {
    test('are not counted as absent', () {
      // The whole point: nobody has said these students are absent, so the
      // Absent tab must not claim them.
      final state = stateWith();

      expect(state.presentCount, 0);
      expect(state.absentCount, 0);
      expect(state.hasRegister, isFalse);
    });

    test('report as not marked rather than defaulting to a status', () {
      expect(
        stateWith().statusOf('s1'),
        LessonAttendanceStatus.notMarked,
      );
    });

    test('are excluded from both the Present and Absent tabs', () {
      final state = stateWith(
        attendance: {'s1': LessonAttendanceStatus.present},
      );

      expect(
        state.copyWith(filter: ClassRosterFilter.present).visibleStudents,
        hasLength(1),
      );
      expect(
        state.copyWith(filter: ClassRosterFilter.absent).visibleStudents,
        isEmpty,
      );
    });
  });

  group('attendance counts', () {
    test('count lateness as attendance', () {
      final state = stateWith(attendance: {
        's1': LessonAttendanceStatus.present,
        's2': LessonAttendanceStatus.late,
        's3': LessonAttendanceStatus.absent,
      });

      expect(state.presentCount, 2);
      expect(state.absentCount, 1);
    });

    test('count authorised absence as absence from the room', () {
      final state = stateWith(attendance: {
        's1': LessonAttendanceStatus.medical,
        's2': LessonAttendanceStatus.approvedLeave,
        's3': LessonAttendanceStatus.present,
      });

      expect(state.presentCount, 1);
      expect(state.absentCount, 2);
    });
  });

  group('search', () {
    test('matches on name', () {
      expect(stateWith(query: 'adong').visibleStudents.single.studentId, 's2');
    });

    test('matches on admission number, which is what a parent quotes', () {
      expect(
        stateWith(query: '2021/PE/012').visibleStudents.single.studentId,
        's3',
      );
    });

    test('is case insensitive', () {
      expect(stateWith(query: 'OKELLO').visibleStudents, hasLength(1));
    });

    test('an empty query keeps the whole class', () {
      expect(stateWith(query: '   ').visibleStudents, hasLength(3));
    });
  });

  group('filters', () {
    test('narrow by gender', () {
      expect(stateWith(gender: 'Female').visibleStudents.single.studentId, 's2');
    });

    test('narrow by residency', () {
      expect(
        stateWith(residency: ResidencyType.boarding).visibleStudents.single.studentId,
        's1',
      );
    });

    test('combine with search and the active tab', () {
      final state = stateWith(
        attendance: {
          's1': LessonAttendanceStatus.present,
          's3': LessonAttendanceStatus.present,
        },
        filter: ClassRosterFilter.present,
        gender: 'Male',
        query: 'okello',
      );

      expect(state.visibleStudents.single.studentId, 's3');
    });
  });

  group('student summary', () {
    test('builds initials from the first and last name', () {
      expect(_student(id: 's1', name: 'Abalo Peter').initials, 'AP');
    });

    test('falls back to a single initial for a one-word name', () {
      expect(_student(id: 's1', name: 'Madina').initials, 'M');
    });

    test('joins class and stream for the placement label', () {
      expect(_student(id: 's1', name: 'Abalo Peter').placementLabel, 'P5 East');
    });
  });
}
