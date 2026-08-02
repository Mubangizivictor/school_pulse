import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_performance.dart';
import '../../domain/policies/class_performance_policy.dart';
import '../../domain/repositories/class_attendance_repository.dart';
import '../../domain/repositories/class_performance_repository.dart';
import '../../domain/repositories/class_student_repository.dart';
import '../../domain/repositories/class_work_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../datasources/class_teacher_remote_data_source.dart';

class ClassPerformanceRepositoryImpl implements ClassPerformanceRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassStudentRepository studentRepository;
  final ClassAttendanceRepository attendanceRepository;
  final ClassWorkRepository workRepository;
  final ClassTeacherAssignmentService assignmentService;
  final NetworkInfo networkInfo;

  ClassPerformanceRepositoryImpl({
    required this.remoteDataSource,
    required this.studentRepository,
    required this.attendanceRepository,
    required this.workRepository,
    required this.assignmentService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ClassPerformanceSummary>> getPerformance({
    required ActiveResponsibilityContext context,
    AttentionThresholds? thresholds,
  }) async {
    final guard = assignmentService.authorize(
      context,
      permission: Permission.classPerformanceView,
    );
    if (guard.isLeft()) {
      return guard.fold(Left.new, (_) => const Left(PermissionDeniedFailure()));
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a class.',
      ));
    }

    if (context.termId.isEmpty) {
      return const Left(ValidationFailure(
        'Your school has not opened a term yet, so there is nothing to '
        'measure performance over.',
      ));
    }

    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(
        'You are offline. Class performance needs a connection.',
      ));
    }

    try {
      final roster = await studentRepository.getClassStudents(context: context);
      final students = roster.getOrElse(() => const []);
      if (students.isEmpty) {
        return const Right(ClassPerformanceSummary());
      }

      final marks = await remoteDataSource.getApprovedClassMarks(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        termId: context.termId,
        streamId: context.streamId,
      );

      // Behaviour follow-ups are one of the reasons a student is surfaced, so
      // they come from the same source the behaviour screen shows rather than
      // being recounted here.
      final behaviour =
          await workRepository.getBehaviourRecords(context: context);
      final followUpsByStudent = <String, int>{};
      for (final record in behaviour.getOrElse(() => const [])) {
        if (!record.isOpenFollowUp) continue;
        followUpsByStudent[record.studentId] =
            (followUpsByStudent[record.studentId] ?? 0) + 1;
      }

      final attendanceRates = await _attendanceRates(context, students.length);

      // Group the flat mark rows into per-student and per-subject views. One
      // pass each; the class is tens of students, not thousands.
      final byStudent = <String, Map<String, List<double>>>{};
      final subjectNames = <String, String>{};
      for (final row in marks) {
        subjectNames[row.subjectId] =
            row.subjectName.isEmpty ? row.subjectId : row.subjectName;
        byStudent
            .putIfAbsent(row.studentId, () => {})
            .putIfAbsent(row.subjectId, () => [])
            .add(row.percentage);
      }

      final summaries = students.map((student) {
        final subjects = byStudent[student.studentId] ?? const {};
        final percentages = <String, double>{
          for (final entry in subjects.entries)
            entry.key:
                entry.value.reduce((a, b) => a + b) / entry.value.length,
        };

        return StudentPerformanceSummary(
          studentId: student.studentId,
          studentName: student.name,
          subjectPercentages: percentages,
          // Subjects the class sits that this student has no approved mark
          // in - chased as missing data, never averaged in as a zero.
          missingSubjects: subjectNames.keys
              .where((id) => !percentages.containsKey(id))
              .length,
          attendanceRate: attendanceRates[student.studentId],
          openBehaviourFollowUps: followUpsByStudent[student.studentId] ?? 0,
        );
      }).toList();

      final subjectSummaries = subjectNames.entries.map((entry) {
        final scores = summaries
            .map((s) => s.subjectPercentages[entry.key])
            .whereType<double>()
            .toList();

        return SubjectPerformanceSummary(
          subjectId: entry.key,
          subjectName: entry.value,
          average: scores.isEmpty
              ? null
              : scores.reduce((a, b) => a + b) / scores.length,
          studentsWithMarks: scores.length,
          studentsExpected: students.length,
          highest: scores.isEmpty ? null : scores.reduce((a, b) => a > b ? a : b),
          lowest: scores.isEmpty ? null : scores.reduce((a, b) => a < b ? a : b),
        );
      }).toList()
        ..sort((a, b) => a.subjectName.compareTo(b.subjectName));

      final resolved = thresholds ?? AttentionThresholds.defaults;

      return Right(ClassPerformanceSummary(
        students: summaries,
        subjects: subjectSummaries,
        needingAttention:
            ClassPerformancePolicy.needingAttention(summaries, resolved),
      ));
    } catch (_) {
      return const Left(ServerFailure(
        'Could not load class performance. Pull down to retry.',
      ));
    }
  }

  /// Per-student attendance rate over the term, from the Attendance engine's
  /// own registers. Computed from the same sessions the history screen shows,
  /// so the two can never disagree.
  Future<Map<String, double>> _attendanceRates(
    ActiveResponsibilityContext context,
    int rosterSize,
  ) async {
    final now = DateTime.now();
    final history = await attendanceRepository.getHistory(
      context: context,
      from: now.subtract(const Duration(days: 120)),
      to: now,
    );

    final sessions = history.getOrElse(() => const []);
    if (sessions.isEmpty) return const {};

    final present = <String, int>{};
    final marked = <String, int>{};

    for (final session in sessions) {
      if (!session.isSubmitted) continue;
      for (final entry in session.entries) {
        if (!entry.isMarked) continue;
        marked[entry.studentId] = (marked[entry.studentId] ?? 0) + 1;
        // Lateness counts as attendance, matching the register's own reading.
        if (entry.statusCode == 'present' || entry.statusCode == 'late') {
          present[entry.studentId] = (present[entry.studentId] ?? 0) + 1;
        }
      }
    }

    return {
      for (final entry in marked.entries)
        if (entry.value > 0)
          entry.key: ((present[entry.key] ?? 0) / entry.value) * 100,
    };
  }
}
