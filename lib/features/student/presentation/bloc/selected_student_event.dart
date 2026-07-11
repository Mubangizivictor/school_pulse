import 'package:equatable/equatable.dart';
import '../../domain/entities/student.dart';

abstract class SelectedStudentEvent extends Equatable {
  const SelectedStudentEvent();
  @override
  List<Object?> get props => [];
}

class SelectStudent extends SelectedStudentEvent {
  final Student student;
  const SelectStudent(this.student);
  @override
  List<Object?> get props => [student];
}
