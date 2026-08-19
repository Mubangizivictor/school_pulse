import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import '../../domain/usecases/get_admin_dashboard_stats.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetAdminDashboardStats getAdminDashboardStats;
  final AuditRepository auditRepository;

  AdminDashboardBloc({
    required this.getAdminDashboardStats,
    required this.auditRepository,
  }) : super(AdminDashboardInitial()) {
    on<LoadAdminDashboardStats>((event, emit) async {
      emit(AdminDashboardLoading());
      final result = await getAdminDashboardStats(
        AdminDashboardStatsParams(forTerm: event.forTerm),
      );
      if (isClosed) return;
      result.fold((failure) => emit(AdminDashboardError(failure.message)), (
        stats,
      ) {
        if (state is AdminDashboardLoaded) {
          emit((state as AdminDashboardLoaded).copyWith(stats: stats));
        } else {
          emit(AdminDashboardLoaded(stats: stats));
        }
        if (!isClosed) add(WatchAuditLogs(schoolId: stats.schoolId));
      });
    });

    on<WatchAuditLogs>((event, emit) async {
      final schoolId = event.schoolId;
      if (schoolId == null || schoolId.isEmpty) return;
      await emit.forEach(
        auditRepository.watchRecentLogs(schoolId: schoolId),
        onData: (logs) {
          if (state is AdminDashboardLoaded) {
            return (state as AdminDashboardLoaded).copyWith(recentLogs: logs);
          }
          return state;
        },
      );
    });
  }
}
