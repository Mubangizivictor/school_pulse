import 'package:equatable/equatable.dart';
import '../../domain/entities/discipline_incident.dart';
import '../../domain/entities/counseling_session.dart';

abstract class DisciplineState extends Equatable {
  const DisciplineState();
  
  @override
  List<Object> get props => [];
}

class DisciplineInitial extends DisciplineState {}

class DisciplineLoading extends DisciplineState {}

class DisciplineLoaded extends DisciplineState {
  final List<DisciplineIncident> incidents;
  final List<CounselingSession> sessions;

  const DisciplineLoaded({
    this.incidents = const [],
    this.sessions = const [],
  });

  @override
  List<Object> get props => [incidents, sessions];
}

class DisciplineError extends DisciplineState {
  final String message;

  const DisciplineError(this.message);

  @override
  List<Object> get props => [message];
}
