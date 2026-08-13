import 'package:equatable/equatable.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminDashboardStats extends AdminDashboardEvent {}

class WatchAuditLogs extends AdminDashboardEvent {
  final String? schoolId;

  const WatchAuditLogs({this.schoolId});

  @override
  List<Object> get props => [schoolId ?? ''];
}
