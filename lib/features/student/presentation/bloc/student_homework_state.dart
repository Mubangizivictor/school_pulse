import 'package:equatable/equatable.dart';
import '../../../teacher/domain/entities/homework.dart';

abstract class StudentHomeworkState extends Equatable {
  const StudentHomeworkState();

  @override
  List<Object> get props => [];
}

class StudentHomeworkInitial extends StudentHomeworkState {}

class StudentHomeworkLoading extends StudentHomeworkState {}

class StudentHomeworkLoaded extends StudentHomeworkState {
  final List<Homework> homeworkList;

  const StudentHomeworkLoaded(this.homeworkList);

  @override
  List<Object> get props => [homeworkList];
}

class StudentHomeworkError extends StudentHomeworkState {
  final String message;

  const StudentHomeworkError(this.message);

  @override
  List<Object> get props => [message];
}
