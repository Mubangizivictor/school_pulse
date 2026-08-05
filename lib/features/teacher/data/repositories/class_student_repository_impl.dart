import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/permissions/permission.dart';

import '../../domain/entities/active_responsibility_context.dart';
import '../../domain/entities/class_student_summary.dart';
import '../../domain/repositories/class_student_repository.dart';
import '../../domain/services/class_teacher_assignment_service.dart';
import '../datasources/class_teacher_local_data_source.dart';
import '../datasources/class_teacher_remote_data_source.dart';
import '../models/class_teacher_isar_models.dart';

class ClassStudentRepositoryImpl implements ClassStudentRepository {
  final ClassTeacherRemoteDataSource remoteDataSource;
  final ClassTeacherLocalDataSource localDataSource;
  final ClassTeacherAssignmentService assignmentService;
  final NetworkInfo networkInfo;

  ClassStudentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.assignmentService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ClassStudentSummary>>> getClassStudents({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classStudentsView,
    );
    if (authorized.isLeft()) {
      return authorized.fold(Left.new, (_) => const Right([]));
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    // The roster is the one thing that must survive a classroom with no
    // signal, so the cache is a first-class path rather than a fallback for
    // errors: offline reads it, online refreshes it.
    if (!forceRefresh && !await networkInfo.isConnected) {
      return Right(await _cached(context, classId));
    }

    try {
      final students = await remoteDataSource.getClassRoster(
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );

      await localDataSource.cacheClassStudents(
        students.map(ClassStudentIsar.fromEntity).toList(),
        schoolId: context.schoolId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );

      return Right(students);
    } catch (_) {
      final cached = await _cached(context, classId);
      if (cached.isNotEmpty) return Right(cached);
      // Raw Firestore text never reaches the user - it leaks collection paths
      // and internal ids.
      return const Left(
        ServerFailure('Could not load your class list. Pull down to retry.'),
      );
    }
  }

  @override
  Future<Either<Failure, ClassStudentSummary>> getClassStudent({
    required ActiveResponsibilityContext context,
    required String studentId,
  }) async {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classStudentProfileView,
    );
    if (authorized.isLeft()) {
      return authorized.fold(
        Left.new,
        (_) => const Left(PermissionDeniedFailure()),
      );
    }

    final classId = context.classId;
    if (classId == null || classId.isEmpty) {
      return const Left(
        ValidationFailure('This responsibility is not tied to a class.'),
      );
    }

    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getClassStudent(studentId);
      // Membership is re-checked even on the cached path: a stale row from a
      // class this teacher no longer holds must not open a profile.
      if (cached != null &&
          cached.schoolId == context.schoolId &&
          cached.classId == classId) {
        return Right(cached.toEntity());
      }
      return const Left(
        NetworkFailure(
          'You are offline and this student is not saved on this device.',
        ),
      );
    }

    try {
      final student = await remoteDataSource.getClassStudent(
        schoolId: context.schoolId,
        studentId: studentId,
        classId: classId,
        academicYearId: context.academicYearId,
        streamId: context.streamId,
      );

      if (student == null) {
        return const Left(
          PermissionDeniedFailure('That student is not in your class.'),
        );
      }

      return Right(student);
    } catch (_) {
      return const Left(ServerFailure('Could not load this student.'));
    }
  }

  @override
  Stream<List<ClassStudentSummary>> watchClassStudents({
    required ActiveResponsibilityContext context,
  }) {
    final authorized = assignmentService.authorize(
      context,
      permission: Permission.classStudentsView,
    );
    final classId = context.classId;
    if (authorized.isLeft() || classId == null || classId.isEmpty) {
      return const Stream.empty();
    }

    return remoteDataSource.watchClassRoster(
      schoolId: context.schoolId,
      classId: classId,
      academicYearId: context.academicYearId,
      streamId: context.streamId,
    );
  }

  @override
  Future<Either<Failure, void>> clearCache({String? schoolId}) async {
    try {
      await localDataSource.clear(schoolId: schoolId);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('Could not clear the saved class list.'));
    }
  }

  Future<List<ClassStudentSummary>> _cached(
    ActiveResponsibilityContext context,
    String classId,
  ) async {
    final rows = await localDataSource.getClassStudents(
      schoolId: context.schoolId,
      classId: classId,
      academicYearId: context.academicYearId,
      streamId: context.streamId,
    );
    final students = rows.map((r) => r.toEntity()).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return students;
  }
}
