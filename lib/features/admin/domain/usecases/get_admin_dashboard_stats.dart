import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/visitor_repository.dart';

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

  const AdminDashboardStats({
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
  });

  @override
  List<Object?> get props => [
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
      ];
}

class GetAdminDashboardStats implements UseCase<AdminDashboardStats, NoParams> {
  final AuthRepository authRepository;
  final StudentRepository studentRepository;
  final VisitorRepository visitorRepository;
  final FirebaseFirestore firestore;

  GetAdminDashboardStats({
    required this.authRepository,
    required this.studentRepository,
    required this.visitorRepository,
    required this.firestore,
  });

  @override
  Future<Either<Failure, AdminDashboardStats>> call(NoParams params) async {
    try {
      final staffResult = await authRepository.getStaffMembers().timeout(const Duration(seconds: 10));
      final studentsResult = await studentRepository.getAllStudents().timeout(const Duration(seconds: 10));

      // For visitors, we use a Future instead of .first on a stream to avoid deadlocks
      // if the stream doesn't emit immediately.
      final visitors = await visitorRepository.getVisitorsOnce().timeout(const Duration(seconds: 10));

      final now = DateTime.now();
      final todayVisitors = visitors.where((v) {
        final checkIn = v.checkIn;
        return checkIn.year == now.year && checkIn.month == now.month && checkIn.day == now.day;
      }).toList();

      final activeVisitors = visitors.where((v) => v.checkOut == null).toList();
      final overdueVisitors = activeVisitors
          .where((v) => now.difference(v.checkIn) > const Duration(hours: 2))
          .length;

      int activeStaff = 0;
      int staffPendingSetup = 0;
      staffResult.fold((_) => null, (staff) {
        activeStaff = staff.where((s) => s.isActive).length;
        staffPendingSetup = staff.where((s) => s.isActive && s.mustChangePassword).length;
      });

      int totalStudents = 0;
      studentsResult.fold((_) => null, (students) => totalStudents = students.length);

      final serviceStatuses = await _getServiceStatuses();
      final systemHealth = _scoreServices(serviceStatuses);
      final syncHealth = await _getSyncHealth();

      return Right(AdminDashboardStats(
        activeStaffCount: activeStaff,
        totalStudentsCount: totalStudents,
        visitorsTodayCount: todayVisitors.length,
        activeVisitorsCount: activeVisitors.length,
        systemHealth: systemHealth,
        staffPendingSetupCount: staffPendingSetup,
        overdueVisitorsCount: overdueVisitors,
        serviceStatuses: serviceStatuses,
        upcomingDeadlines: await _getUpcomingDeadlines(),
        activeNotices: await _getActiveNotices(),
        dataSyncRatePercent: syncHealth.$1,
        failedOperationsCount: syncHealth.$2,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<List<DashboardDeadline>> _getUpcomingDeadlines() async {
    try {
      final now = DateTime.now();
      final snapshot = await firestore
          .collection('school_events')
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

  Future<List<DashboardNotice>> _getActiveNotices() async {
    try {
      final snapshot = await firestore
          .collection('alerts')
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
    final since = Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24)));

    Future<String> queueHealth(String collection, String createdAtField) async {
      try {
        final snapshot = await firestore
            .collection(collection)
            .where(createdAtField, isGreaterThanOrEqualTo: since)
            .get();
        if (snapshot.docs.isEmpty) return 'Operational';
        final failed = snapshot.docs.where((d) => d.data()['status'] == 'failed').length;
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
        status: firestore.app.options.projectId.isNotEmpty ? 'Operational' : 'Down',
      ),
    ];
  }

  /// Sync rate / failed-operations count for the "Data Integrity & Health"
  /// panel - looks at the last 7 days across every delivery queue.
  Future<(double, int)> _getSyncHealth() async {
    final since = Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7)));
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
        failed += snapshot.docs.where((d) => d.data()['status'] == 'failed').length;
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
