import 'package:equatable/equatable.dart';
import '../../../student/domain/entities/student.dart';

abstract class StudentIdentityEvent extends Equatable {
  const StudentIdentityEvent();

  @override
  List<Object?> get props => [];
}

class GenerateStudentIdentityEvent extends StudentIdentityEvent {
  final Student student;
  const GenerateStudentIdentityEvent(this.student);

  @override
  List<Object?> get props => [student];
}

class LoadStudentIdentityEvent extends StudentIdentityEvent {
  final String studentId;
  const LoadStudentIdentityEvent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class CacheStudentsOfflineEvent extends StudentIdentityEvent {
  final List<Student> students;
  const CacheStudentsOfflineEvent(this.students);

  @override
  List<Object?> get props => [students];
}
