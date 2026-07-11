import 'package:equatable/equatable.dart';
import '../../domain/entities/health_visit.dart';

abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object> get props => [];
}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthLoaded extends HealthState {
  final List<HealthVisit> visits;
  const HealthLoaded(this.visits);

  @override
  List<Object> get props => [visits];
}

class HealthError extends HealthState {
  final String message;
  const HealthError(this.message);

  @override
  List<Object> get props => [message];
}
