import 'package:equatable/equatable.dart';

abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class TeacherDashboardRequested extends TeacherEvent {
  final String teacherId;

  const TeacherDashboardRequested(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class TeacherAttendanceHistoryRequested extends TeacherEvent {
  final String teacherId;

  const TeacherAttendanceHistoryRequested(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class TeacherAttendanceRequested extends TeacherEvent {
  final String className;

  const TeacherAttendanceRequested(this.className);

  @override
  List<Object?> get props => [className];
}

class TeacherMarksEntryRequested extends TeacherEvent {
  final String className;
  final String subject;
  final String assessment;

  const TeacherMarksEntryRequested({
    required this.className,
    required this.subject,
    required this.assessment,
  });

  @override
  List<Object?> get props => [className, subject, assessment];
}

class TeacherMarksSubmitted extends TeacherEvent {
  final String className;
  final String subject;
  final String assessment;
  final String term;
  final String year;

  /// studentId -> score (0-100)
  final Map<String, double> marks;

  const TeacherMarksSubmitted({
    required this.className,
    required this.subject,
    required this.assessment,
    required this.term,
    required this.year,
    required this.marks,
  });

  @override
  List<Object?> get props =>
      [className, subject, assessment, term, year, marks];
}

class TeacherAttendanceSubmitted extends TeacherEvent {
  final String className;
  final Map<String, String> attendance; // studentId -> status

  const TeacherAttendanceSubmitted({
    required this.className,
    required this.attendance,
  });

  @override
  List<Object?> get props => [className, attendance];
}
