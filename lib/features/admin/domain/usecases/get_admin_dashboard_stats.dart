import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/visitor_repository.dart';

class AdminDashboardStats extends Equatable {
  final int activeStaffCount;
  final int totalStudentsCount;
  final int visitorsTodayCount;
  final int activeVisitorsCount;
  final double systemHealth;
  final int staffPendingSetupCount;
  final int overdueVisitorsCount;

  const AdminDashboardStats({
    required this.activeStaffCount,
    required this.totalStudentsCount,
    required this.visitorsTodayCount,
    required this.activeVisitorsCount,
    required this.systemHealth,
    this.staffPendingSetupCount = 0,
    this.overdueVisitorsCount = 0,
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
      ];
}

class GetAdminDashboardStats implements UseCase<AdminDashboardStats, NoParams> {
  final AuthRepository authRepository;
  final StudentRepository studentRepository;
  final VisitorRepository visitorRepository;

  GetAdminDashboardStats({
    required this.authRepository,
    required this.studentRepository,
    required this.visitorRepository,
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

      return Right(AdminDashboardStats(
        activeStaffCount: activeStaff,
        totalStudentsCount: totalStudents,
        visitorsTodayCount: todayVisitors.length,
        activeVisitorsCount: activeVisitors.length,
        systemHealth: 100.0, // This could be calculated from error logs in a real system
        staffPendingSetupCount: staffPendingSetup,
        overdueVisitorsCount: overdueVisitors,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
