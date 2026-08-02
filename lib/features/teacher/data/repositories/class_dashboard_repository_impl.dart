import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_dashboard_summary.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/class_dashboard_repository.dart';
import '../../domain/repositories/class_student_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../datasources/class_teacher_local_data_source.dart';
import '../datasources/class_teacher_remote_data_source.dart';
import '../models/class_teacher_isar_models.dart';

class ClassDashboardRepositoryImpl implements ClassDashboardRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassTeacherLocalDataSource localDataSource;
  final ClassStudentRepository studentRepository;
  final ClassTeacherAssignmentService assignmentService;
  final NetworkInfo networkInfo;

  ClassDashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.studentRepository,
    required this.assignmentService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ClassDashboardSummary>> getDashboard({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classStudentsView,
    );
    if (authorized.isLeft()) {
      return authorized.fold(
        Left.new,
        (_) => const Left(PermissionDeniedFailure()),
      );
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a class.',
      ));
    }

    if (!await networkInfo.isConnected) {
      final cached = await _cached(context, classId);
      if (cached != null) return Right(cached);
      return const Left(NetworkFailure(
        'You are offline and this class has not been loaded on this device yet.',
      ));
    }

    try {
      final today = DateTime.now();

      // Fired together rather than in sequence: five independent reads that
      // all have to land before the home tab can render, so serialising them
      // would make the dashboard four round trips slower for no benefit.
      final rosterFuture = studentRepository.getClassStudents(
        context: context,
        forceRefresh: forceRefresh,
      );
      final attendanceFuture = remoteDataSource.getTodaysAttendance(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        date: today,
        streamId: context.streamId,
      );
      final scheduleFuture = _scheduleOrEmpty(context, classId, today);
      final activityFuture = _activityOrEmpty(context, classId);
      final pendingFuture = remoteDataSource.getPendingCounts(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        termId: context.termId,
        staffId: context.staffId,
        streamId: context.streamId,
      );

      final roster = await rosterFuture;
      final attendance = await attendanceFuture;
      final schedule = await scheduleFuture;
      final activity = await activityFuture;
      final pending = await pendingFuture;

      final totalStudents = roster.fold((_) => 0, (students) => students.length);

      // Absences are derived from the roster rather than trusted from the
      // session document: a student admitted after the register was taken
      // would otherwise silently vanish from the totals.
      final resolvedAttendance = attendance == null
          ? const ClassAttendanceToday()
          : attendance.absentCount == 0 &&
                  attendance.isSubmitted &&
                  totalStudents > attendance.markedCount
              ? ClassAttendanceToday(
                  hasSession: attendance.hasSession,
                  isSubmitted: attendance.isSubmitted,
                  presentCount: attendance.presentCount,
                  absentCount: totalStudents - attendance.markedCount,
                  lateCount: attendance.lateCount,
                  excusedCount: attendance.excusedCount,
                  submittedAt: attendance.submittedAt,
                )
              : attendance;

      final summary = ClassDashboardSummary(
        totalStudents: totalStudents,
        attendance: resolvedAttendance,
        pendingAssignments: pending.openAssignments,
        pendingReports: pending.pendingReports,
        pendingBehaviourFollowUps: pending.behaviourFollowUps,
        unreadMessages: pending.unreadMessages,
        todaysSchedule: schedule,
        recentActivities: activity,
      );

      await localDataSource.cacheDashboard(
        ClassDashboardCacheIsar.fromEntity(
          summary,
          schoolId: context.schoolId,
          classId: classId,
          streamId: context.streamId,
          academicYearId: context.academicYearId,
        ),
      );

      return Right(summary);
    } catch (_) {
      final cached = await _cached(context, classId);
      if (cached != null) return Right(cached);
      return const Left(ServerFailure(
        'Could not load your class dashboard. Pull down to retry.',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache({String? schoolId}) async {
    try {
      await localDataSource.clear(schoolId: schoolId);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('Could not clear the saved dashboard.'));
    }
  }

  /// The timetable is context, not the point of the screen: a school that has
  /// not published one yet still gets working figures rather than an error.
  Future<List<Lesson>> _scheduleOrEmpty(
    ActiveResponsibilityContext context,
    String classId,
    DateTime date,
  ) async {
    try {
      return await remoteDataSource.getClassSchedule(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        date: date,
        streamId: context.streamId,
      );
    } catch (_) {
      return const [];
    }
  }

  Future<List<ClassActivityEntry>> _activityOrEmpty(
    ActiveResponsibilityContext context,
    String classId,
  ) async {
    try {
      return await remoteDataSource.getRecentActivity(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
      );
    } catch (_) {
      return const [];
    }
  }

  Future<ClassDashboardSummary?> _cached(
    ActiveResponsibilityContext context,
    String classId,
  ) async {
    final row = await localDataSource.getDashboard(
      classId: classId,
      academicYearId: context.academicYearId,
      streamId: context.streamId,
    );
    if (row == null || row.schoolId != context.schoolId) return null;
    return row.toEntity();
  }
}
