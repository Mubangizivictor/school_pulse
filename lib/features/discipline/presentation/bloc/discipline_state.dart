import 'package:equatable/equatable.dart';
import '../../domain/entities/discipline_incident.dart';

abstract class DisciplineState extends Equatable {
  const DisciplineState();
  
  @override
  List<Object> get props => [];
}

class DisciplineInitial extends DisciplineState {}

class DisciplineLoading extends DisciplineState {}

class DisciplineLoaded extends DisciplineState {
  final List<DisciplineIncident> incidents;

  const DisciplineLoaded(this.incidents);

  @override
  List<Object> get props => [incidents];
}

class DisciplineError extends DisciplineState {
  final String message;

  const DisciplineError(this.message);

  @override
  List<Object> get props => [message];
}
