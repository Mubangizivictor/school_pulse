import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_students_by_class.dart';
import '../../domain/entities/attendance_access_context.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_scope.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart'
    show AttendanceRemoteDataSource, DuplicateAttendanceException;
import '../models/attendance_record_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final StructureRepository structureRepository;
  final GetStudentsByClass getStudentsByClass;
  final GetStaffMembers getStaffMembers;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.structureRepository,
    required this.getStudentsByClass,
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
          // Institution-wide operators (schoolAdmin/director/headTeacher/
          // deputyHead, or anyone granted attendance.override) see every
          // active class - everyone else only sees the classes their
          // Class/Subject Teacher assignments actually name.
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
          // No dormitory Structure entity is wired into this repository yet
          // (see boarding_entities.dart in the matron feature) - the scope
          // picker offers exactly the dormitories the operator is assigned
          // to, using their id as both id and name until Structure exposes
          // dormitory display names centrally.
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
          // Single implicit scope - these categories aren't organized by
          // class, so the roster is the whole category rather than a
          // sub-group the operator has to pick first.
          return Right([
            AttendanceScope(id: category.name, name: category.label),
          ]);
      }
    } catch (_) {
      return Left(ServerFailure());
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
          final result = await getStudentsByClass(scopeId);
          return result.fold(
            (failure) => Left(failure),
            (students) => Right(
              students
                  .map(
                    (s) => AttendancePerson(
                      id: s.id,
                      name: s.name,
                      subtitle: s.studentId,
                    ),
                  )
                  .toList(),
            ),
          );
        case AttendanceCategory.staff:
          final result = await getStaffMembers(NoParams());
          return result.fold(
            (failure) => Left(failure),
            (staff) => Right(
              staff
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
          // No pre-existing roster source for these categories yet - the
          // operator identifies the person via NFC/QR scan or manual search
          // rather than picking from a pre-loaded list.
          return const Right([]);
      }
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AttendanceRecord>> markAttendance(
    AttendanceRecord record,
  ) async {
    try {
      final saved = await remoteDataSource.markAttendance(
        AttendanceRecordModel.fromEntity(record),
      );
      return Right(saved);
    } on DuplicateAttendanceException catch (e) {
      return Left(ValidationFailure(e.message, field: 'duplicate'));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>> markBatch(
    List<AttendanceRecord> records,
  ) async {
    try {
      final saved = await remoteDataSource.markBatch(
        records.map(AttendanceRecordModel.fromEntity).toList(),
      );
      return Right(saved);
    } on DuplicateAttendanceException catch (e) {
      return Left(ValidationFailure(e.message, field: 'duplicate'));
    } catch (_) {
      return Left(ServerFailure());
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
    // A specific scopeId the operator isn't authorised for is rejected
    // outright rather than silently returning an empty list, so Previous
    // Attendance can distinguish "nothing recorded" from "not your scope".
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
      // Firestore rules allow any staff member to read every category's
      // records school-wide (see attendance_records match block) - this is
      // the actual enforcement point for Previous Attendance, matching the
      // same AttendanceAccessContext every other surface uses.
      final visible = records.where((r) {
        if (!access.allowedDomains.contains(r.category)) return false;
        return access.canActOnScope(r.category, r.scopeId);
      }).toList();
      return Right(visible);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
