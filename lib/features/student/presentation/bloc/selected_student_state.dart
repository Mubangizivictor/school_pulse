import 'package:equatable/equatable.dart';
import '../../domain/entities/student.dart';

abstract class SelectedStudentState extends Equatable {
  const SelectedStudentState();

  @override
  List<Object?> get props => [];
}

class SelectedStudentInitial extends SelectedStudentState {}

class SelectedStudentLoading extends SelectedStudentState {}

class SelectedStudentLoaded extends SelectedStudentState {
  final Student student;

  const SelectedStudentLoaded(this.student);

  @override
  List<Object?> get props => [student];
}

class SelectedStudentError extends SelectedStudentState {
  final String message;

  const SelectedStudentError(this.message);

  @override
  List<Object?> get props => [message];
}
