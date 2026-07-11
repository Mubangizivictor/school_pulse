import 'package:equatable/equatable.dart';

abstract class DisciplineEvent extends Equatable {
  const DisciplineEvent();

  @override
  List<Object> get props => [];
}

class LoadDisciplineIncidents extends DisciplineEvent {
  final String studentId;

  const LoadDisciplineIncidents(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class LoadRecentIncidents extends DisciplineEvent {}
