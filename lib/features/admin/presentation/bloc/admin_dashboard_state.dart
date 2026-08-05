import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_admin_dashboard_stats.dart';

import '../../data/models/audit_log.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardStats stats;
  final List<AuditLog> recentLogs;

  const AdminDashboardLoaded({required this.stats, this.recentLogs = const []});

  @override
  List<Object> get props => [stats, recentLogs];

  AdminDashboardLoaded copyWith({
    AdminDashboardStats? stats,
    List<AuditLog>? recentLogs,
  }) {
    return AdminDashboardLoaded(
      stats: stats ?? this.stats,
      recentLogs: recentLogs ?? this.recentLogs,
    );
  }
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object> get props => [message];
}
