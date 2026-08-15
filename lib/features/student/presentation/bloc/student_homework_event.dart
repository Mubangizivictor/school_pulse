import 'package:equatable/equatable.dart';

abstract class StudentHomeworkEvent extends Equatable {
  const StudentHomeworkEvent();

  @override
  List<Object> get props => [];
}

class LoadStudentHomework extends StudentHomeworkEvent {
  final String schoolId;
  final String className;

  const LoadStudentHomework(this.schoolId, this.className);

  @override
  List<Object> get props => [schoolId, className];
}
