import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// [forTerm] null keeps the dashboard's default behavior (the currently
/// active term). Passing a different AcademicTerm re-fetches Attendance
/// and Fees Collected scoped to that term's date range - see
/// GetAdminDashboardStats for which KPIs actually support this.
class LoadAdminDashboardStats extends AdminDashboardEvent {
  final AcademicTerm? forTerm;

  const LoadAdminDashboardStats({this.forTerm});

  @override
  List<Object?> get props => [forTerm];
}

class WatchAuditLogs extends AdminDashboardEvent {
  final String? schoolId;

  const WatchAuditLogs({this.schoolId});

  @override
  List<Object> get props => [schoolId ?? ''];
}
