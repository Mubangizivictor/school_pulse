import 'package:equatable/equatable.dart';

abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class TeacherDashboardRequested extends TeacherEvent {}

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
