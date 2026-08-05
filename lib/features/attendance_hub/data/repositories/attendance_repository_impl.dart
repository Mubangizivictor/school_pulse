import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_students_by_class.dart';
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
  ) async {
    try {
      switch (category) {
        case AttendanceCategory.students:
          final classes = await structureRepository
              .watchClasses(schoolId)
              .first;
          return Right(
            classes
                .where((c) => c.isActive)
                .map((c) => AttendanceScope(id: c.id, name: c.name))
                .toList(),
          );
        case AttendanceCategory.staff:
        case AttendanceCategory.gate:
        case AttendanceCategory.meals:
        case AttendanceCategory.library:
        case AttendanceCategory.transport:
        case AttendanceCategory.visitors:
        case AttendanceCategory.hostel:
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
  ) async {
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
    AttendanceCategory? category,
    DateTime? from,
    DateTime? to,
    String? scopeId,
  }) async {
    try {
      final records = await remoteDataSource.getRecords(
        schoolId: schoolId,
        category: category,
        from: from,
        to: to,
        scopeId: scopeId,
      );
      return Right(records);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
