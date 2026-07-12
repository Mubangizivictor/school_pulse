import 'package:equatable/equatable.dart';
import '../../domain/entities/dean_stats.dart';

abstract class DeanState extends Equatable {
  const DeanState();

  @override
  List<Object?> get props => [];
}

class DeanInitial extends DeanState {}

class DeanLoading extends DeanState {}

class DeanLoaded extends DeanState {
  final DeanStats stats;

  const DeanLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DeanError extends DeanState {
  final String message;

  const DeanError(this.message);

  @override
  List<Object?> get props => [message];
}
