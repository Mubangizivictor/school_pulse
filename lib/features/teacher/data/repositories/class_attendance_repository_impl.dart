import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/lesson_attendance.dart';
import '../../domain/repositories/class_attendance_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../datasources/class_teacher_remote_data_source.dart';

class ClassAttendanceRepositoryImpl implements ClassAttendanceRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassTeacherAssignmentService assignmentService;
  final NetworkInfo networkInfo;

  ClassAttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.assignmentService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, LessonAttendanceStatus>>> getStatusesForDate({
    required ActiveResponsibilityContext context,
    required DateTime date,
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classAttendanceView,
    );
    if (authorized.isLeft()) {
      return authorized.fold(Left.new, (_) => const Right({}));
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(ValidationFailure(
        'This responsibility is not tied to a class.',
      ));
    }

    if (!await networkInfo.isConnected) {
      // An empty map is honest here: nobody is claimed present or absent, so
      // the roster shows every student as unmarked rather than inventing a
      // register the device has not seen.
      return const Right({});
    }

    try {
      final raw = await remoteDataSource.getSessionStatuses(
        schoolId: context.schoolId,
        classId: classId,
        date: date,
        streamId: context.streamId,
      );

      return Right({
        for (final entry in raw.entries)
          entry.key: LessonAttendanceStatus.fromId(entry.value),
      });
    } catch (_) {
      return const Left(ServerFailure(
        "Could not load today's register. Pull down to retry.",
      ));
    }
  }
}
