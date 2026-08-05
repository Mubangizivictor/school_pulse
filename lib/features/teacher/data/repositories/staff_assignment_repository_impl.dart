import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';

import '../../domain/entities/staff_role_assignment.dart';
import '../../domain/repositories/staff_assignment_repository.dart';
import '../datasources/subject_teacher_local_data_source.dart';
import '../datasources/subject_teacher_remote_data_source.dart';
import '../models/subject_teacher_isar_models.dart';

/// Key holding the last responsibility the teacher picked. Namespaced per
/// user so a shared device does not restore one teacher's selection into
/// another teacher's session.
String _selectedAssignmentKey(String userId) =>
    'subject_teacher.selected_assignment.$userId';

class StaffAssignmentRepositoryImpl implements StaffAssignmentRepository {
  final SubjectTeacherRemoteDataSource remoteDataSource;
  final SubjectTeacherLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences preferences;

  /// The user whose selection the persistence methods act on. Supplied by the
  /// caller rather than read from auth here, so this stays a plain repository.
  final String Function() currentUserId;

  StaffAssignmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.preferences,
    required this.currentUserId,
  });

  @override
  Future<Either<Failure, List<StaffRoleAssignment>>> getAssignments({
    required String schoolId,
    required String userId,
    bool forceRefresh = false,
  }) async {
    final online = await networkInfo.isConnected;

    if (online) {
      try {
        final remote = await remoteDataSource.getAssignmentsForUser(
          schoolId: schoolId,
          userId: userId,
        );
        // Replace rather than merge: an assignment the admin deleted is
        // absent from the server response, and merging would leave the stale
        // row on the device granting access it no longer has.
        await localDataSource.clearAssignments(schoolId: schoolId);
        await localDataSource.cacheAssignments(
          remote.map(StaffRoleAssignmentIsar.fromEntity).toList(),
        );
        return Right(remote);
      } catch (e) {
        if (forceRefresh) return Left(ServerFailure(e.toString()));
        // Fall through to the cache - a flaky connection should not empty the
        // switcher mid-lesson.
      }
    } else if (forceRefresh) {
      return const Left(NetworkFailure('No internet connection.'));
    }

    try {
      final cached = await localDataSource.getAssignments(
        userId: userId,
        schoolId: schoolId,
      );
      return Right(cached.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StaffRoleAssignment>>> getValidAssignments({
    required String schoolId,
    required String userId,
    String? academicYearId,
    bool forceRefresh = false,
  }) async {
    final result = await getAssignments(
      schoolId: schoolId,
      userId: userId,
      forceRefresh: forceRefresh,
    );

    return result.map((assignments) {
      final now = DateTime.now();
      return assignments.where((a) {
        if (!a.isCurrentlyValid(asOf: now)) return false;
        if (academicYearId != null &&
            academicYearId.isNotEmpty &&
            a.academicYearId != academicYearId) {
          return false;
        }
        return true;
      }).toList()..sort(_byResponsibilityOrder);
    });
  }

  /// Subject assignments first (the panel's primary job), then class
  /// teaching, then everything else; alphabetical inside each group so the
  /// switcher order is stable between launches.
  static int _byResponsibilityOrder(
    StaffRoleAssignment a,
    StaffRoleAssignment b,
  ) {
    int rank(StaffResponsibilityType t) => switch (t) {
      StaffResponsibilityType.subjectTeacher => 0,
      StaffResponsibilityType.classTeacher => 1,
      _ => 2,
    };
    final byRank = rank(a.roleType).compareTo(rank(b.roleType));
    if (byRank != 0) return byRank;
    return a.displayLabel.toLowerCase().compareTo(b.displayLabel.toLowerCase());
  }

  @override
  Stream<List<StaffRoleAssignment>> watchAssignments({
    required String schoolId,
    required String userId,
  }) {
    return remoteDataSource
        .watchAssignmentsForUser(schoolId: schoolId, userId: userId)
        .asyncMap((assignments) async {
          await localDataSource.clearAssignments(schoolId: schoolId);
          await localDataSource.cacheAssignments(
            assignments.map(StaffRoleAssignmentIsar.fromEntity).toList(),
          );
          return assignments..sort(_byResponsibilityOrder);
        });
  }

  @override
  Future<Either<Failure, StaffRoleAssignment>> verifyAssignment({
    required String schoolId,
    required String assignmentId,
    required String userId,
  }) async {
    if (!await networkInfo.isConnected) {
      // Offline, the cached row is the best available evidence. It still has
      // to pass the same status and date checks - a cache does not extend an
      // assignment that has expired since it was written.
      final cached = await localDataSource.getAssignments(
        userId: userId,
        schoolId: schoolId,
      );
      final match = cached
          .map((e) => e.toEntity())
          .where((a) => a.id == assignmentId)
          .firstOrNull;
      if (match == null) {
        return const Left(
          AssignmentInvalidFailure(
            'This responsibility is not available offline.',
          ),
        );
      }
      if (!match.isCurrentlyValid())
        return const Left(AssignmentInvalidFailure());
      return Right(match);
    }

    try {
      final assignment = await remoteDataSource.getAssignment(
        schoolId: schoolId,
        assignmentId: assignmentId,
      );
      if (assignment == null) {
        return const Left(
          AssignmentInvalidFailure('This responsibility has been removed.'),
        );
      }
      // Ownership is re-checked server-side too, but catching it here gives a
      // clear message instead of a rules rejection.
      if (assignment.userId != userId) {
        return const Left(
          PermissionDeniedFailure(
            'This responsibility belongs to another staff member.',
          ),
        );
      }
      if (!assignment.isCurrentlyValid()) {
        return Left(
          AssignmentInvalidFailure(switch (assignment.status) {
            AssignmentStatus.suspended =>
              'This responsibility has been suspended by the school admin.',
            AssignmentStatus.removed => 'This responsibility has been removed.',
            _ => 'This responsibility is outside its active dates.',
          }),
        );
      }
      return Right(assignment);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> persistSelectedAssignment(
    String assignmentId,
  ) async {
    try {
      await preferences.setString(
        _selectedAssignmentKey(currentUserId()),
        assignmentId,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getPersistedAssignmentId() async {
    try {
      return Right(
        preferences.getString(_selectedAssignmentKey(currentUserId())),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache({String? schoolId}) async {
    try {
      await localDataSource.clearAssignments(schoolId: schoolId);
      await localDataSource.clearEnrollments(schoolId: schoolId);
      await preferences.remove(_selectedAssignmentKey(currentUserId()));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
