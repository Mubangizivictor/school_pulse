import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_dashboard_stats.dart';
import '../../domain/usecases/get_attendance_history.dart';

abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {}


class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final int studentsToday;
  final int totalStudents;
  final int submissionsDue;
  final int classesToday;
  final int activeNotifications;
  final List<ClassProgress> classProgress;

  const TeacherLoaded({
    required this.studentsToday,
    required this.totalStudents,
    required this.submissionsDue,
    required this.classesToday,
    required this.activeNotifications,
    required this.classProgress,
  });

  @override
  List<Object?> get props => [
        studentsToday,
        totalStudents,
        submissionsDue,
        classesToday,
        activeNotifications,
        classProgress,
      ];
}

class TeacherError extends TeacherState {
  final String message;

  const TeacherError(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherAttendanceLoaded extends TeacherState {
  final List<TeacherStudent> students;
  final String selectedClass;

  const TeacherAttendanceLoaded({
    required this.students,
    required this.selectedClass,
  });

  @override
  List<Object?> get props => [students, selectedClass];
}

class TeacherMarksEntryLoaded extends TeacherState {
  final List<TeacherStudent> students;
  final String selectedClass;
  final String selectedSubject;
  final String selectedAssessment;

  const TeacherMarksEntryLoaded({
    required this.students,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedAssessment,
  });

  @override
  List<Object?> get props => [students, selectedClass, selectedSubject, selectedAssessment];
}

class TeacherAttendanceHistoryLoaded extends TeacherState {
  final List<AttendanceHistoryRecord> history;

  const TeacherAttendanceHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class TeacherStudent extends Equatable {
  final String id;
  final String name;
  final String studentId;
  final String className;

  const TeacherStudent({
    required this.id,
    required this.name,
    required this.studentId,
    required this.className,
  });

  @override
  List<Object?> get props => [id, name, studentId, className];
}
