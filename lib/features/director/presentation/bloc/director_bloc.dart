import 'package:flutter_bloc/flutter_bloc.dart';
import 'director_event.dart';
import 'director_state.dart';
import '../../domain/entities/director_dashboard_stats.dart';

class DirectorBloc extends Bloc<DirectorEvent, DirectorState> {
  DirectorBloc() : super(DirectorInitial()) {
    on<DirectorDashboardRequested>(_onDashboardRequested);
  }

  Future<void> _onDashboardRequested(
    DirectorDashboardRequested event,
    Emitter<DirectorState> emit,
  ) async {
    emit(DirectorDashboardLoading());
    try {
      // Mock data for now - in a real app, this would come from a repository
      // that aggregates data from various services (Finance, Academic, etc.)
      final stats = DirectorDashboardStats(
        totalStudents: 1250,
        totalStaff: 85,
        totalClasses: 24,
        totalDepartments: 12,
        activeAcademicYear: '2023/2024',
        currentTerm: 'Term 2',
        schoolGrowthPercentage: 15.5,
        expectedFees: 450000,
        collectedFees: 320000,
        outstandingFees: 130000,
        collectionPercentage: 71.1,
        monthlyRevenue: 45000,
        termRevenue: 320000,
        yearRevenue: 850000,
        totalExpenditure: 180000,
        budgetUtilization: 65.0,
        pendingFinancialApprovals: 5,
        overallSchoolAverage: 68.5,
        passRate: 92.0,
        improvementTrend: 4.2,
        topClasses: const [
          ClassPerformance(
            className: 'Senior 4 Blue',
            average: 78.5,
            trend: 2.1,
          ),
          ClassPerformance(
            className: 'Senior 6 Arts',
            average: 75.2,
            trend: 1.5,
          ),
        ],
        weakClasses: const [
          ClassPerformance(
            className: 'Senior 1 Green',
            average: 52.4,
            trend: -1.2,
          ),
          ClassPerformance(
            className: 'Senior 2 Alpha',
            average: 55.8,
            trend: 0.5,
          ),
        ],
        staffAttendanceRate: 94.5,
        parentPortalUsageRate: 62.0,
        activeIncidents: 3,
      );

      emit(DirectorDashboardLoaded(stats));
    } catch (e) {
      emit(DirectorDashboardError(e.toString()));
    }
  }
}
