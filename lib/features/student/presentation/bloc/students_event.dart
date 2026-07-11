import 'package:equatable/equatable.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object> get props => [];
}

class FetchStudents extends StudentsEvent {
  final List<String> studentIds;
  const FetchStudents(this.studentIds);

  @override
  List<Object> get props => [studentIds];
}
