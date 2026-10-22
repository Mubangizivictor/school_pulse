import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import '../../domain/entities/attendance_access_context.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_scope.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart'
    show AttendanceLocalDataSource, LocalDuplicateAttendanceException;
import '../datasources/attendance_remote_data_source.dart'
    show
        AttendanceRemoteDataSource,
        DuplicateAttendanceException,
        buildAttendanceRecordId;
import '../models/attendance_record_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final StructureRepository structureRepository;
  final StudentRepository studentRepository;
  final GetStaffMembers getStaffMembers;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.structureRepository,
    required this.studentRepository,
    required this.getStaffMembers,
  });

  @override
  Future<Either<Failure, List<AttendanceScope>>> getScopes(
    String schoolId,
    AttendanceCategory category,
    AttendanceAccessContext access,
  ) async {
    if (!access.allowedDomains.contains(category)) {
      return const Right([]);
    }
    try {
      switch (category) {
        case AttendanceCategory.students:
          final classes = await structureRepository
              .watchClasses(schoolId)
              .first;
          final visible =
              access.canViewAllForCategory(AttendanceCategory.students)
              ? classes.where((c) => c.isActive)
              : classes.where((c) => c.isActive && access.canAccessClass(c.id));
          return Right(
            visible
                .map((c) => AttendanceScope(id: c.id, name: c.name))
                .toList(),
          );
        case AttendanceCategory.hostel:
          if (access.canViewAllForCategory(AttendanceCategory.hostel)) {
            return Right([
              AttendanceScope(id: category.name, name: category.label),
            ]);
          }
          return Right(
            access.allowedDormitoryIds
                .map((id) => AttendanceScope(id: id, name: id))
                .toList(),
          );
        case AttendanceCategory.staff:
        case AttendanceCategory.gate:
        case AttendanceCategory.meals:
        case AttendanceCategory.library:
        case AttendanceCategory.transport:
        case AttendanceCategory.visitors:
        case AttendanceCategory.custom:
          return Right([
            AttendanceScope(id: category.name, name: category.label),
          ]);
      }
    } catch (e) {
      return Left(ServerFailure('Failed to load attendance scopes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttendancePerson>>> getRoster(
    String schoolId,
    AttendanceCategory category,
    String scopeId,
    AttendanceAccessContext access,
  ) async {
    if (!access.canActOnScope(category, scopeId)) {
      return const Right([]);
    }
    try {
      switch (category) {
        case AttendanceCategory.students:
          // getAllStudents(schoolId) is already tenant-scoped. Do not apply a
          // second legacy Student.schoolId equality check here: older student
          // objects may carry stale embedded tenant metadata even though the
          // canonical document was returned through the authenticated school's
          // repository query. The selected Structure class id is the roster
          // boundary.
          final allResult = await studentRepository.getAllStudents(
            schoolId: schoolId,
          );
          return await allResult.fold(
            Left.new,
            (students) => Right(
              students
                  .where(
                    (s) =>
                        s.classId == scopeId &&
                        s.status.name.toLowerCase() == 'active',
                  )
                  .map(
                    (s) => AttendancePerson(
                      id: s.id,
                      name: s.name,
                      subtitle: s.studentCode,
                    ),
                  )
                  .toList(),
            ),
          );
        case AttendanceCategory.staff:
          final result = await getStaffMembers(NoParams());
          return await result.fold(
            Left.new,
            (staff) => Right(
              staff
                  .where((u) => u.schoolId == schoolId)
                  .map(
                    (u) => AttendancePerson(
                      id: u.id,
                      name: u.name,
                      subtitle: u.staffCode,
                    ),
                  )
                  .toList(),
            ),
          );
        case AttendanceCategory.gate:
        case AttendanceCategory.meals:
        case AttendanceCategory.library:
        case AttendanceCategory.transport:
        case AttendanceCategory.visitors:
        case AttendanceCategory.hostel:
        case AttendanceCategory.custom:
          return const Right([]);
      }
    } catch (e) {
      return Left(ServerFailure('Failed to load attendance roster: $e'));
    }
  }

  Future<Failure?> _validateStudentPlacement(AttendanceRecord record) async {
    if (record.category != AttendanceCategory.students) return null;

    final allResult = await studentRepository.getAllStudents(
      schoolId: record.schoolId,
    );
    return allResult.fold<Failure?>((failure) => failure, (students) {
      final matches = students.where((s) => s.id == record.personId).toList();
      if (matches.isEmpty) {
        return const ValidationFailure(
          'This student is not in the current school roster.',
          field: 'student',
        );
      }
      final student = matches.first;
      if (student.status.name.toLowerCase() != 'active') {
        return const ValidationFailure(
          'This student is not active and cannot be marked present.',
          field: 'student',
        );
      }
      if (student.classId != record.scopeId) {
        return ValidationFailure(
          'This student belongs to a different class. Select the student\'s actual class before marking attendance.',
          field: 'scope',
        );
      }
      return null;
    });
  }

  @override
  Future<Either<Failure, AttendanceRecord>> markAttendance(
    AttendanceRecord record,
  ) async {
    // Correctness must not depend only on NFC/QR identity metadata. Before a
    // student attendance write, validate the canonical student placement
    // against the selected class. This makes it impossible for a P4 card to
    // create a P5 attendance record even if an old identity cache is stale.
    final placementFailure = await _validateStudentPlacement(record);
    if (placementFailure != null) return Left(placementFailure);

    final pendingRecord = record.copyWith(
      syncStatus: AttendanceSyncStatus.pending,
    );

    final AttendanceRecord cached;
    try {
      cached = await localDataSource.cacheIfAbsent(pendingRecord);
    } on LocalDuplicateAttendanceException {
      return const Left(
        ValidationFailure(
          'Attendance already recorded for this session',
          field: 'duplicate',
        ),
      );
    }

    if (!await networkInfo.isConnected) {
      return Right(cached);
    }

    final recordId = buildAttendanceRecordId(
      category: cached.category,
      scopeId: cached.scopeId,
      sessionType: cached.sessionType,
      date: cached.date,
      personId: cached.personId,
    );
    try {
      await remoteDataSource.markAttendance(
        AttendanceRecordModel.fromEntity(cached),
      );
      await localDataSource.markSynced(recordId);
      return Right(cached.copyWith(syncStatus: AttendanceSyncStatus.synced));
    } on DuplicateAttendanceException {
      return const Left(
        ValidationFailure(
          'Attendance already recorded for this session',
          field: 'duplicate',
        ),
      );
    } catch (_) {
      return Right(cached);
    }
  }

  /// Same retention/staleness window `NotificationImageCache.maxAge` already
  /// uses for its on-device cache - reused here rather than inventing a new
  /// number, per the offline-queue lifecycle policy.
  static const _retention = Duration(days: 30);

  @override
  Future<void> syncPendingAttendance(String schoolId) async {
    // Evict on every sweep (cheap no-op when nothing qualifies) so
    // `permanentlyBlocked`/old `completed` rows don't accumulate forever on
    // a device that is opened regularly but rarely fully restarted.
    await localDataSource.evictStale(retention: _retention);

    if (!await networkInfo.isConnected) return;
    final pending = await localDataSource.getPending(schoolId);
    final now = DateTime.now();
    for (final record in pending) {
      final recordId = buildAttendanceRecordId(
        category: record.category,
        scopeId: record.scopeId,
        sessionType: record.sessionType,
        date: record.date,
        personId: record.personId,
      );

      // Stale: queued for longer than the retention window without ever
      // reaching the server. Retrying it further would risk writing a very
      // old mark as if it just happened - block it instead.
      if (now.difference(record.createdAt) > _retention) {
        await localDataSource.markPermanentlyBlocked(
          recordId,
          reason: 'This attendance mark is too old to sync automatically.',
        );
        continue;
      }

      await localDataSource.markSyncing(recordId);
      try {
        await remoteDataSource.pushRecord(
          schoolId,
          recordId,
          AttendanceRecordModel.fromEntity(record).toFirestore(),
        );
        await localDataSource.markSynced(recordId);
      } on FirebaseException catch (e) {
        // Firestore rules deny (permission-denied) or the target doc's path
        // no longer resolves (not-found) are permanent, 403-equivalent
        // rejections - the writer's access was revoked, the learner/class
        // was removed, or the school changed underneath them. Anything else
        // (unavailable, deadline-exceeded, aborted, etc.) is transient and
        // gets the normal backoff retry.
        if (e.code == 'permission-denied' || e.code == 'not-found') {
          await localDataSource.markPermanentlyBlocked(
            recordId,
            reason:
                'You no longer have permission to sync this attendance mark.',
          );
        } else {
          await localDataSource.markRetryableFailure(
            recordId,
            error: e.message ?? e.code,
          );
        }
      } catch (e) {
        await localDataSource.markRetryableFailure(
          recordId,
          error: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> clearLocalQueue() => localDataSource.clearAll();

  @override
  Future<Either<Failure, List<AttendanceRecord>>> markBatch(
    List<AttendanceRecord> records,
  ) async {
    try {
      for (final record in records) {
        final placementFailure = await _validateStudentPlacement(record);
        if (placementFailure != null) return Left(placementFailure);
      }
      final saved = await remoteDataSource.markBatch(
        records.map(AttendanceRecordModel.fromEntity).toList(),
      );
      return Right(saved);
    } on DuplicateAttendanceException catch (e) {
      return Left(ValidationFailure(e.message, field: 'duplicate'));
    } catch (e) {
      return Left(ServerFailure('Failed to save attendance: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>> getRecords({
    required String schoolId,
    required AttendanceAccessContext access,
    AttendanceCategory? category,
    DateTime? from,
    DateTime? to,
    String? scopeId,
  }) async {
    if (scopeId != null &&
        category != null &&
        !access.canActOnScope(category, scopeId)) {
      return const Right([]);
    }
    try {
      final records = await remoteDataSource.getRecords(
        schoolId: schoolId,
        category: category,
        from: from,
        to: to,
        scopeId: scopeId,
      );
      final visible = records.where((r) {
        if (!access.allowedDomains.contains(r.category)) return false;
        return access.canActOnScope(r.category, r.scopeId);
      }).toList();
      return Right(visible);
    } catch (e) {
      return Left(ServerFailure('Failed to load attendance records: $e'));
    }
  }
}
