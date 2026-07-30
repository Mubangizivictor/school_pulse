import 'package:equatable/equatable.dart';
import '../../domain/entities/director_approval.dart';
import '../../domain/entities/director_dashboard_stats.dart';

abstract class DirectorState extends Equatable {
  const DirectorState();

  @override
  List<Object?> get props => [];
}

class DirectorInitial extends DirectorState {}

class DirectorDashboardLoading extends DirectorState {}

class DirectorDashboardLoaded extends DirectorState {
  final DirectorDashboardStats stats;

  const DirectorDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DirectorDashboardError extends DirectorState {
  final String message;

  const DirectorDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class DirectorApprovalsLoading extends DirectorState {}

class DirectorApprovalsLoaded extends DirectorState {
  final List<DirectorApproval> approvals;

  const DirectorApprovalsLoaded(this.approvals);

  @override
  List<Object?> get props => [approvals];
}

class DirectorApprovalsError extends DirectorState {
  final String message;

  const DirectorApprovalsError(this.message);

  @override
  List<Object?> get props => [message];
}
