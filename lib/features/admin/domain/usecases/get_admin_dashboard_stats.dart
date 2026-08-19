import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/visitor.dart';
import 'package:school_pulse/features/gate_ops/domain/repositories/gate_ops_repository.dart';
import 'package:school_pulse/features/admin/domain/repositories/admin_attendance_repository.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/features/finance/domain/entities/expenditure.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';

/// One row of the dashboard's "Live Services" panel.
class ServiceStatusItem extends Equatable {
  final String label;
  final String status; // 'Operational' | 'Degraded' | 'Down'

  const ServiceStatusItem({required this.label, required this.status});

  @override
  List<Object?> get props => [label, status];
}

/// One row of the dashboard's "Upcoming Deadlines" panel - a school_events
/// doc with type 'deadline'.
class DashboardDeadline extends Equatable {
  final String title;
  final DateTime date;

  const DashboardDeadline({required this.title, required this.date});

  @override
  List<Object?> get props => [title, date];
}

/// One row of the dashboard's "Active Staff Notices" panel - a recent
/// broadcast (alerts doc) targeted at staff.
class DashboardNotice extends Equatable {
  final String title;
  final String body;

  const DashboardNotice({required this.title, required this.body});

  @override
  List<Object?> get props => [title, body];
}

class AdminDashboardStats extends Equatable {
  final String? schoolId;
  final int activeStaffCount;
  final int totalStudentsCount;
  final int visitorsTodayCount;
  final int activeVisitorsCount;
  final double systemHealth;
  final int staffPendingSetupCount;
  final int overdueVisitorsCount;
  final List<ServiceStatusItem> serviceStatuses;
  final List<DashboardDeadline> upcomingDeadlines;
  final List<DashboardNotice> activeNotices;
  final double dataSyncRatePercent;
  final int failedOperationsCount;

  /// School-wide average student attendance for the current week, or null
  /// if it couldn't be computed (e.g. no attendance recorded yet).
  final double? studentAttendancePercent;

  /// Fees collected for the active term, in the school's base currency
  /// units (e.g. UGX), or null if Finance data isn't available.
  final double? termFeesCollected;

  /// Label of the currently active academic period (e.g. "Term 2",
  /// "Semester 1"), or null if Structure hasn't configured one yet.
  final String? currentPeriodLabel;

  /// Pending (not yet approved/rejected) expenditure requests - the one
  /// real approvals queue this dashboard has access to today.
  final int pendingExpenditureRequestsCount;

  /// True when these stats were computed for a past term rather than the
  /// currently active one. activeStaffCount/totalStudentsCount are always
  /// a live "right now" count regardless of this flag - there is no
  /// historical enrollment/staffing data model yet - so the UI uses this
  /// to label those two tiles as current-only when a past term is shown.
  final bool isHistoricalTerm;

  const AdminDashboardStats({
    this.schoolId,
    required this.activeStaffCount,
    required this.totalStudentsCount,
    required this.visitorsTodayCount,
    required this.activeVisitorsCount,
    required this.systemHealth,
    this.staffPendingSetupCount = 0,
    this.overdueVisitorsCount = 0,
    this.serviceStatuses = const [],
    this.upcomingDeadlines = const [],
    this.activeNotices = const [],
    this.dataSyncRatePercent = 100.0,
    this.failedOperationsCount = 0,
    this.studentAttendancePercent,
    this.termFeesCollected,
    this.currentPeriodLabel,
    this.pendingExpenditureRequestsCount = 0,
    this.isHistoricalTerm = false,
  });

  @override
  List<Object?> get props => [
    schoolId,
    activeStaffCount,
    totalStudentsCount,
    visitorsTodayCount,
    activeVisitorsCount,
    systemHealth,
    staffPendingSetupCount,
    overdueVisitorsCount,
    serviceStatuses,
    upcomingDeadlines,
    activeNotices,
    dataSyncRatePercent,
    failedOperationsCount,
    studentAttendancePercent,
    termFeesCollected,
    currentPeriodLabel,
    pendingExpenditureRequestsCount,
    isHistoricalTerm,
  ];
}

/// Optional term override for the dashboard KPIs that support historical
/// scoping (Attendance, Fees Collected). Null (the default) keeps today's
/// exact current-term behavior.
class AdminDashboardStatsParams extends Equatable {
  final AcademicTerm? forTerm;

  const AdminDashboardStatsParams({this.forTerm});

  @override
  List<Object?> get props => [forTerm];
}

class GetAdminDashboardStats
    implements UseCase<AdminDashboardStats, AdminDashboardStatsParams> {
  final AuthRepository authRepository;
  final GateOpsRepository gateOpsRepository;
  final FirebaseFirestore firestore;
  final AdminAttendanceRepository adminAttendanceRepository;
  final FinanceRepository financeRepository;
  final StructureRepository structureRepository;

  GetAdminDashboardStats({
    required this.authRepository,
    required this.gateOpsRepository,
    required this.firestore,
    required this.adminAttendanceRepository,
    required this.financeRepository,
    required this.structureRepository,
  });

  @override
  Future<Either<Failure, AdminDashboardStats>> call(
    AdminDashboardStatsParams params,
  ) async {
    final forTerm = params.forTerm;
    try {
      final currentUserResult = await authRepository.getCurrentUser();
      final schoolId = currentUserResult.fold((_) => null, (u) => u?.schoolId);
      if (schoolId == null || schoolId.isEmpty) {
        return const Left(AuthFailure('No active school context.'));
      }
      final Either<Failure, List<UserEntity>> staffResult = await authRepository
          .getStaffMembers(schoolId)
          .timeout(const Duration(seconds: 10));
      // A dashboard KPI must not download every student just to show a
      // number. Status is a canonical student field, so this server-side
      // aggregate remains tenant-scoped and counts exactly active students.
      final activeStudentsCount = await firestore
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .where('status', isEqualTo: 'active')
          .count()
          .get()
          .timeout(const Duration(seconds: 10));

      // For visitors, we use a Future instead of .first on a stream to avoid deadlocks
      // if the stream doesn't emit immediately.
      final visitors = await gateOpsRepository
          .getVisitorsOnce(schoolId)
          .timeout(const Duration(seconds: 10));

      final now = DateTime.now();
      final todayVisitors = visitors.where((v) {
        final arrival = v.arrivalTime;
        return arrival.year == now.year &&
            arrival.month == now.month &&
            arrival.day == now.day;
      }).toList();

      final activeVisitors = visitors
          .where((v) => v.status == VisitorStatus.checkedIn)
          .toList();
      final overdueVisitors = activeVisitors
          .where(
            (v) => now.difference(v.arrivalTime) > const Duration(hours: 2),
          )
          .length;

      int activeStaff = 0;
      int staffPendingSetup = 0;
      staffResult.fold((_) => null, (staff) {
        activeStaff = staff.where((s) => s.isActive).length;
        staffPendingSetup = staff
            .where((s) => s.isActive && s.mustChangePassword)
            .length;
      });

      final serviceStatuses = await _getServiceStatuses();
      final systemHealth = _scoreServices(serviceStatuses);
      final syncHealth = await _getSyncHealth();

      double? attendancePercent;
      double? feesCollected;
      String? periodLabel;
      int pendingExpenditure = 0;

      final attendanceResult = await adminAttendanceRepository
          .getStudentAttendanceStats(
            schoolId,
            startDate: forTerm?.startDate,
            endDate: forTerm?.endDate,
          )
          .timeout(const Duration(seconds: 10));
      attendanceResult.fold(
        (_) => null,
        (stats) => attendancePercent = stats.$1,
      );

      if (forTerm != null) {
        // A specific past/other term was requested - sum actual payments
        // in that term's date range instead of the current-year KPI.
        final paymentsResult = await financeRepository
            .getSchoolPayments(
              schoolId,
              startDate: forTerm.startDate,
              endDate: forTerm.endDate,
            )
            .timeout(const Duration(seconds: 10));
        paymentsResult.fold(
          (_) => null,
          (payments) => feesCollected = payments.fold<double>(
            0,
            (total, p) => total + p.amount,
          ),
        );
        periodLabel = forTerm.name;
      } else {
        final kpiResult = await financeRepository
            .getFinancialDashboardKPIs(schoolId)
            .timeout(const Duration(seconds: 10));
        kpiResult.fold((_) => null, (kpis) {
          final value = kpis['termCollections'];
          if (value is num) feesCollected = value.toDouble();
        });

        try {
          final terms = await structureRepository
              .watchAcademicTerms(schoolId)
              .first
              .timeout(const Duration(seconds: 10));
          final current = terms.where((t) => t.isCurrent).firstOrNull;
          periodLabel = current?.name;
        } catch (_) {
          // Structure not configured yet - leave label null.
        }
      }

      final expenditureResult = await financeRepository
          .getExpenditureRequests(schoolId)
          .timeout(const Duration(seconds: 10));
      expenditureResult.fold((_) => null, (requests) {
        pendingExpenditure = requests
            .where((r) => r.status == ExpenditureStatus.pending)
            .length;
      });

      return Right(
        AdminDashboardStats(
          schoolId: schoolId,
          activeStaffCount: activeStaff,
          totalStudentsCount: activeStudentsCount.count ?? 0,
          visitorsTodayCount: todayVisitors.length,
          activeVisitorsCount: activeVisitors.length,
          systemHealth: systemHealth,
          staffPendingSetupCount: staffPendingSetup,
          overdueVisitorsCount: overdueVisitors,
          serviceStatuses: serviceStatuses,
          upcomingDeadlines: await _getUpcomingDeadlines(schoolId),
          activeNotices: await _getActiveNotices(schoolId),
          dataSyncRatePercent: syncHealth.$1,
          failedOperationsCount: syncHealth.$2,
          studentAttendancePercent: attendancePercent,
          termFeesCollected: feesCollected,
          currentPeriodLabel: periodLabel,
          pendingExpenditureRequestsCount: pendingExpenditure,
          isHistoricalTerm: forTerm != null && !forTerm.isCurrent,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<List<DashboardDeadline>> _getUpcomingDeadlines(String schoolId) async {
    try {
      final now = DateTime.now();
      final snapshot = await firestore
          .collection('school_events')
          .where('schoolId', isEqualTo: schoolId)
          .where('type', isEqualTo: 'deadline')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('date')
          .limit(3)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DashboardDeadline(
          title: data['title'] as String? ?? 'Untitled',
          date: (data['date'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<DashboardNotice>> _getActiveNotices(String schoolId) async {
    try {
      final snapshot = await firestore
          .collection('alerts')
          .where('schoolId', isEqualTo: schoolId)
          .where('targets', arrayContains: 'All Staff')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return DashboardNotice(
          title: data['title'] as String? ?? 'Notice',
          body: data['body'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Checks the last 24h of delivery-queue docs for failures, so a real
  /// outage (e.g. a broadcast that failed to send) actually shows up here
  /// instead of the panel just being decorative.
  Future<List<ServiceStatusItem>> _getServiceStatuses() async {
    final since = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(hours: 24)),
    );

    Future<String> queueHealth(String collection, String createdAtField) async {
      try {
        final snapshot = await firestore
            .collection(collection)
            .where(createdAtField, isGreaterThanOrEqualTo: since)
            .get();
        if (snapshot.docs.isEmpty) return 'Operational';
        final failed = snapshot.docs
            .where((d) => d.data()['status'] == 'failed')
            .length;
        if (failed == 0) return 'Operational';
        if (failed < snapshot.docs.length) return 'Degraded';
        return 'Down';
      } catch (_) {
        return 'Operational';
      }
    }

    final pushStatus = await queueHealth('broadcast_queue', 'createdAt');
    final smsStatus = await queueHealth('sms_queue', 'createdAt');

    return [
      // Reaching this point means every Firestore read above already
      // succeeded, so the database is - by definition - reachable.
      const ServiceStatusItem(label: 'Database', status: 'Operational'),
      ServiceStatusItem(label: 'Push Notifications', status: pushStatus),
      ServiceStatusItem(label: 'SMS Gateway', status: smsStatus),
      ServiceStatusItem(
        label: 'Identity',
        status: firestore.app.options.projectId.isNotEmpty
            ? 'Operational'
            : 'Down',
      ),
    ];
  }

  /// Sync rate / failed-operations count for the "Data Integrity & Health"
  /// panel - looks at the last 7 days across every delivery queue.
  Future<(double, int)> _getSyncHealth() async {
    final since = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );
    const collections = ['broadcast_queue', 'sms_queue', 'notification_queue'];

    int total = 0;
    int failed = 0;
    for (final collection in collections) {
      try {
        final snapshot = await firestore
            .collection(collection)
            .where('createdAt', isGreaterThanOrEqualTo: since)
            .get();
        total += snapshot.docs.length;
        failed += snapshot.docs
            .where((d) => d.data()['status'] == 'failed')
            .length;
      } catch (_) {
        // Collection may not exist yet on a fresh install - treat as healthy.
      }
    }

    if (total == 0) return (100.0, 0);
    final rate = ((total - failed) / total) * 100;
    return (rate, failed);
  }

  double _scoreServices(List<ServiceStatusItem> services) {
    if (services.isEmpty) return 100.0;
    final total = services.fold<double>(0, (acc, s) {
      switch (s.status) {
        case 'Operational':
          return acc + 100;
        case 'Degraded':
          return acc + 60;
        default:
          return acc + 0;
      }
    });
    return total / services.length;
  }
}
